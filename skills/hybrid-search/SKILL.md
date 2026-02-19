---
name: hybrid-search
description: >
  Expert guidance for building, improving, and debugging hybrid search systems
  that combine PostgreSQL full-text search with OpenSearch vector/semantic search
  over transcribed audio/video content. Covers Cohere Embed v3 (default) and
  other embedding models via AWS Bedrock, kNN index design, transcript chunking
  with timecode resolution, hybrid scoring/ranking strategies, and natural
  language query processing. Use when: (1) building or modifying search
  endpoints for a media asset library, (2) optimizing hybrid search ranking or
  result quality, (3) debugging poor semantic or fulltext results, (4) designing
  OpenSearch index mappings for transcript chunks, (5) configuring or switching
  embedding models, (6) implementing transcript segment search with timecodes,
  (7) tuning score normalization or merge weights, (8) working on natural
  language query parsing for search.
---

# Hybrid Search for Transcribed Media Content

## Architecture Overview

The search system has three backends that can run independently or combined:

| Backend | Engine | What it searches | Strengths |
|---------|--------|-----------------|-----------|
| **SQL fulltext** | PostgreSQL `ts_rank` + `to_tsquery` | title, description, tags, custom metadata, transcript text, transcript intelligence (summaries, topics, keywords) | Exact matches, structured filters, field boosting |
| **Semantic** | OpenSearch kNN (HNSW, cosinesimil) | Asset embeddings + transcript chunk embeddings | Meaning-based retrieval, handles synonyms, conceptual queries |
| **Hybrid** | Both in parallel, merged | All fields | Best recall, compensates for weaknesses of each |

Users select via `searchType: 'fulltext' | 'semantic' | 'hybrid' | 'natural'` or toggle individual backends via `searchTypes: { sql, semantic, transcript }`.

## Typical Component Architecture

```
Search Router / API Layer         — Endpoints, input validation, pagination
Search Orchestrator / Service     — Strategy dispatch, caching, search history
Search Strategies:
  SQL Fulltext Strategy           — PostgreSQL ts_rank + to_tsquery, LIKE
  Semantic Strategy               — OpenSearch kNN via embedding service
  Hybrid Strategy                 — Parallel SQL + semantic with fallback
  Transcript Strategy             — Dedicated transcript segment search
Result Merger                     — Score normalization + weighted merge
OpenSearch Client                 — Index CRUD, kNN queries
Embedding Service                 — Embedding generation (Cohere/Titan via Bedrock)
Batch Embedding Pipeline          — Bulk embedding for indexing
Configuration                     — Model IDs, dimensions, region settings
```

## Embedding Configuration

Default model: **Cohere Embed English v3** (`cohere.embed-english-v3`) — 1024 dimensions.

| Model | Dimensions | Input type | Notes |
|-------|-----------|------------|-------|
| `cohere.embed-english-v3` | 1024 | `search_document` / `search_query` | **Default.** Best quality for English. Uses `truncate: 'END'` |
| `cohere.embed-multilingual-v3` | 1024 | Same | Multilingual support |
| `amazon.titan-embed-text-v2:0` | 1024 | Plain text | AWS native, slightly lower quality |

Cohere v3 uses **asymmetric search** — documents are embedded with `input_type: 'search_document'`, queries with `input_type: 'search_query'`. This is critical for quality. Ensure your embedding service uses the correct input type for each context.

**Common mistake**: Using `search_document` for all embeddings including queries. If your embedding service doesn't distinguish between document and query input types, switching query-time calls to `search_query` typically improves results significantly.

## OpenSearch Index Design

Two indices, both using HNSW with cosine similarity:

```
asset_embeddings:      whole-asset vectors (title + description + tags)
transcript_embeddings: per-chunk vectors with start_time/end_time
```

HNSW parameters: `ef_construction: 512`, `m: 16`, `ef_search: 512`, engine: `nmslib`.

For transcript chunks, each document includes `start_time` and `end_time` (float, seconds) for timecode resolution back to the source media.

See [references/opensearch-patterns.md](references/opensearch-patterns.md) for index mapping details, filter patterns, and HNSW tuning.

## Hybrid Scoring & Ranking

Score normalization before merging (example values — tune to your implementation):
- **SQL**: `score / maxPossibleScore` (e.g., `/ 3.0` for an additive weighted sum across fields)
- **Semantic**: `min(score, 1.0)` (cosine similarity is inherently 0-1)
- **Transcript**: `score / maxPossibleScore` (e.g., `/ 2.5` with boost + log scaling)

Recommended starting weights: SQL 0.35, Semantic 0.45, Transcript 0.20. Multi-source boost: +10% per additional source.

See [references/hybrid-ranking.md](references/hybrid-ranking.md) for the full scoring pipeline, adaptive thresholds, and merge strategies.

## Transcript Search

Transcripts are chunked by sentence boundaries with a configurable token limit (default 8000 tokens ~32K chars). Each chunk gets an embedding stored in `transcript_embeddings` with timecodes.

Transcript aggregation merges nearby segment matches within a time window (default 30s) with context words (default 20 words before/after).

See [references/transcript-search.md](references/transcript-search.md) for chunking strategies, segment resolution, and aggregation patterns.

## Common Improvement Patterns

### Poor semantic results
1. Check if query embeddings use `input_type: 'search_query'` (not `search_document`)
2. Verify `minimumScore` threshold isn't too high (default 0.3, try 0.25 for short queries)
3. Check chunk size — very large chunks dilute embedding signal
4. Inspect HNSW `ef_search` — increase for better recall at cost of latency

### SQL results dominate hybrid
1. Check merge weights — semantic weight should be >= SQL weight for conceptual queries
2. Look at `semanticOnlyPenalty` — values near 0.5 aggressively suppress semantic-only results
3. Verify `dropSemanticOnlyWhenSqlPresent` isn't discarding valid semantic matches

### Slow search
1. Profile per-component timing in the search response to identify bottlenecks
2. Check embedding cache hit rate — cache misses mean embedding API calls per query
3. OpenSearch: verify index has enough replicas for read throughput
4. SQL: ensure a GIN index exists on the transcript search vector column

### Missing transcript timecodes
1. Verify transcript segments link to their corresponding OpenSearch embedding documents
2. Check that `start_time`/`end_time` are populated in the transcript embeddings index
3. Confirm segment resolution logic handles multiple chunks per asset correctly

## Quick Reference: Search Request Shape (Example)

A typical hybrid search request supports these parameters:

```typescript
{
  query: string,                    // 1-500 chars
  searchType: 'fulltext' | 'semantic' | 'hybrid' | 'natural',
  searchTypes?: { sql, semantic, transcript },  // override individual backends
  filters?: {
    assetType, status, tags, collections, uploadedBy,
    dateFrom, dateTo, fileSize, duration, customMetadata
  },
  sorting?: { sortBy, sortDirection },
  pagination?: { page, limit },
  minimumScore?: number,            // 0-1, semantic threshold
  fuzzyMatching?: boolean,          // prefix matching in SQL
  boostFields?: { title, description, tags, transcript },
  includeProvenance?: boolean,      // detailed match explanations
  booleanQuery?: { conditions },    // visual query builder
  confidenceThreshold?: number,     // post-filter on final scores
}
```
