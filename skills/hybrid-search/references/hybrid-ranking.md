# Hybrid Ranking & Score Merging

## Table of Contents
- [Score Normalization](#score-normalization)
- [Merge Strategies](#merge-strategies)
- [Adaptive Thresholds](#adaptive-thresholds)
- [Semantic-Only Penalty](#semantic-only-penalty)
- [Natural Language Mode](#natural-language-mode)
- [Reciprocal Rank Fusion (Alternative)](#reciprocal-rank-fusion-alternative)
- [Debugging Relevance](#debugging-relevance)
- [Improvement Opportunities](#improvement-opportunities)

## Score Normalization

Before merging, raw scores are normalized to 0-1:

| Source | Formula | Max raw score | Rationale |
|--------|---------|--------------|-----------|
| SQL | `score / 3.0` | ~3.0 | Additive weighted sum across title (40%), description (20%), tags (15%), metadata (10%), transcript (50%), transcript intel (45%) |
| Semantic | `min(score, 1.0)` | 1.0 | Cosine similarity is inherently 0-1 |
| Transcript | `score / 2.5` | ~2.5 | Boost + logarithmic occurrence scaling |

**Issue**: SQL normalization divisor of 3.0 is approximate. If field boosts are changed, the divisor should be recalculated. A safer approach is dynamic normalization:

```typescript
// Dynamic: normalize by actual max score in result set
const maxScore = Math.max(...results.map(r => r.score));
const normalized = results.map(r => ({ ...r, score: r.score / maxScore }));
```

## Merge Strategies

### Weighted Linear Combination (recommended default)

```
finalScore = (sqlScore * 0.35) + (semanticScore * 0.45) + (transcriptScore * 0.20)
```

Weights are renormalized to sum to 1.0 based on which backends actually ran:
- SQL only: SQL weight = 1.0
- SQL + Semantic: SQL = 0.438, Semantic = 0.562
- All three: as above (0.35, 0.45, 0.20)

**Multi-source boost**: Results found by N sources get a `1 + (N-1) * 0.10` multiplier.
- Found by 2 sources: 1.10x
- Found by 3 sources: 1.20x

**Tie-breaking**: When scores are within 0.0001, SQL-sourced results win (deterministic ordering).

### When Weighted Linear Fails

Weighted linear combination is simple but has known weaknesses:
- Sensitive to normalization quality (garbage-in, garbage-out)
- Fixed weights can't adapt to query intent (navigational vs. exploratory)
- Score distributions from SQL and semantic are fundamentally different shapes

## Adaptive Thresholds

Semantic minimum score varies by context:

| Context | Threshold | Rationale |
|---------|-----------|-----------|
| Default | 0.30 | Permissive baseline |
| Natural language + filters | 0.50 | Filters narrow scope, need higher confidence |
| Natural language, no filters | 0.42 | Moderate — semantic needs to be meaningful |
| Short query (1-3 terms) | +0.05 | Short queries produce noisier embeddings |

**Recommendation**: These thresholds are starting points — tune empirically. Log actual score distributions to validate:

```typescript
// Add to search response for monitoring
performance.scoreDistribution = {
  semantic: { min, max, median, p25, p75 },
  sql: { min, max, median, p25, p75 },
};
```

## Semantic-Only Penalty

When `preferLexicalWhenAvailable: true` and SQL results exist:

1. **Drop**: `dropSemanticOnlyWhenSqlPresent: true` — semantic-only results are removed entirely
2. **Penalize**: `semanticOnlyPenalty: 0.35-0.5` — multiplicative reduction

This prevents low-relevance semantic matches from polluting results when SQL found good matches. However, it can suppress valid conceptual matches that don't contain the exact query terms.

**When to relax**:
- Exploratory queries ("tell me about themes in this library")
- Conceptual queries ("exciting moments", "controversial discussions")
- When SQL returns few results (<5)

## Natural Language Mode

NL queries are parsed to extract filters, then dispatched as hybrid:

| Condition | SQL weight | Semantic weight | Semantic penalty |
|-----------|-----------|----------------|-----------------|
| With extracted filters | 0.70 | 0.30 | 0.35 |
| Without filters | 0.60 | 0.40 | 0.50 |

This favors SQL when structured filters are present (e.g., "videos from September 2025") but gives semantic more influence for open-ended queries.

## Reciprocal Rank Fusion (Alternative)

RRF is an alternative to weighted linear combination that doesn't require score normalization:

```
RRF_score(d) = Σ 1 / (k + rank_i(d))
```

Where `k` is a constant (typically 60) and `rank_i(d)` is the rank of document `d` in result list `i`.

**Advantages over weighted linear**:
- No normalization needed — works on ranks, not scores
- Robust to different score distributions
- Less sensitive to weight tuning

**Disadvantages**:
- Loses score magnitude information (a 0.99 and 0.51 semantic match get similar treatment if ranked adjacently)
- Harder to explain to users

**Implementation sketch**:
```typescript
function reciprocalRankFusion(
  resultSets: Array<{ id: string; rank: number }[]>,
  k: number = 60
): Map<string, number> {
  const scores = new Map<string, number>();
  for (const results of resultSets) {
    for (const { id, rank } of results) {
      scores.set(id, (scores.get(id) || 0) + 1 / (k + rank));
    }
  }
  return scores;
}
```

**Recommendation**: Consider RRF as an option alongside weighted linear. RRF tends to produce better results when score distributions are unreliable or when the normalization divisors are approximate.

## Debugging Relevance

### Enable Provenance
Set `includeProvenance: true` in the search request. This adds per-result explanations:
- Which backends matched
- Per-backend scores (pre-normalization)
- Field-level match details
- Boost factors applied

### Score Distribution Analysis
Expose a query explanation endpoint that returns:
- Raw query plans for each backend
- Execution timing breakdown
- Score histograms

### Common Patterns

**"Good results ranked low"**
1. Check if the result was found by only one backend (no multi-source boost)
2. Check score normalization — is the divisor appropriate?
3. Look for semantic-only penalty suppressing valid matches

**"Irrelevant results ranked high"**
1. Check SQL fuzzy matching — prefix matches can be noisy
2. Check if tag matches are over-weighted (tags boost is 2.4, highest)
3. Look for transcript matches on common words inflating scores

**"Semantic search returns nothing"**
1. Verify embeddings exist: `GET /transcript_embeddings/_count`
2. Check vector dimensions match between query and index
3. Lower `minimumScore` threshold
4. Test with a known document's text as query (should return itself with score ~1.0)

## Improvement Opportunities

### 1. Query-Time Embedding Input Type
A common mistake is using `input_type: 'search_document'` for all embedding calls. Query-time calls should use `input_type: 'search_query'` for Cohere models. This is the single highest-impact fix for semantic search quality.

### 2. Dynamic Score Normalization
Replace fixed divisors (3.0, 2.5) with per-result-set max-score normalization. This adapts to actual score distributions rather than theoretical maximums.

### 3. Score Calibration
Log score distributions per search type over time. Use percentile-based normalization instead of fixed divisors.

### 4. Contextual Weight Adjustment
Adjust merge weights based on query characteristics:
- Short keyword queries: favor SQL (0.6 SQL, 0.3 semantic)
- Long natural language: favor semantic (0.3 SQL, 0.6 semantic)
- With filters: favor SQL (0.7 SQL, 0.2 semantic)

### 5. Learning-to-Rank
If click-through data is available, train a simple LTR model (e.g., LambdaMART) to learn optimal score combination instead of fixed weights.

### 6. Transcript Chunk Overlap
Current chunking splits at sentence boundaries with no overlap. Adding 1-2 sentence overlap between chunks improves recall for queries that match content near chunk boundaries.
