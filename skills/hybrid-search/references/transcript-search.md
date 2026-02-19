# Transcript Search & Chunking

## Table of Contents
- [Chunking Strategy](#chunking-strategy)
- [Embedding Pipeline](#embedding-pipeline)
- [Timecode Resolution](#timecode-resolution)
- [Transcript Aggregation](#transcript-aggregation)
- [Transcript Intelligence](#transcript-intelligence)
- [SQL Transcript Search](#sql-transcript-search)
- [Improvement Opportunities](#improvement-opportunities)

## Chunking Strategy

### Current Implementation

Transcripts are chunked by sentence boundaries:

```typescript
chunkText(text: string, maxTokens: number = 8000): string[] {
  const maxChars = maxTokens * 4;  // ~4 chars per token
  // Split on sentence boundaries: .!?
  // Accumulate sentences until maxChars exceeded
  // No overlap between chunks
}
```

**Characteristics**:
- Max chunk size: 8000 tokens (~32K chars)
- Split on `.!?` boundaries
- No overlap between chunks
- No speaker-turn awareness
- No timestamp preservation in chunk text

### Recommended Improvements

#### 1. Smaller Chunks for Better Precision
8000 tokens is large. Embedding models produce better representations for shorter, focused text. Recommended: **500-1000 tokens** per chunk.

```typescript
// Better chunking parameters
const CHUNK_SIZE = 512;           // tokens
const CHUNK_OVERLAP = 50;         // tokens overlap
const MIN_CHUNK_SIZE = 100;       // don't create tiny fragments
```

#### 2. Overlap Between Chunks
Add 10-20% overlap to avoid losing context at boundaries:

```typescript
function chunkWithOverlap(sentences: string[], maxTokens: number, overlapTokens: number): string[] {
  const chunks: string[] = [];
  let current: string[] = [];
  let currentTokens = 0;

  for (const sentence of sentences) {
    const sentenceTokens = estimateTokens(sentence);
    if (currentTokens + sentenceTokens > maxTokens && current.length > 0) {
      chunks.push(current.join(' '));
      // Keep last N tokens worth of sentences for overlap
      while (currentTokens > overlapTokens && current.length > 1) {
        currentTokens -= estimateTokens(current.shift()!);
      }
    }
    current.push(sentence);
    currentTokens += sentenceTokens;
  }
  if (current.length > 0) chunks.push(current.join(' '));
  return chunks;
}
```

#### 3. Speaker-Turn Aware Chunking
For interview/conversation transcripts, chunk on speaker turns:

```typescript
// If transcript has speaker labels, prefer splitting on speaker changes
function chunkBySpeaker(segments: TranscriptSegment[], maxTokens: number): Chunk[] {
  // Group consecutive segments by same speaker
  // If a speaker turn exceeds maxTokens, split within it
  // Preserve speaker identity in chunk metadata
}
```

#### 4. Timestamp-Aware Chunks
Store the actual time range covered by each chunk:

```typescript
interface TranscriptChunk {
  text: string;
  startTime: number;  // seconds
  endTime: number;    // seconds
  speakerId?: string;
  chunkIndex: number;
  overlapWithPrevious: boolean;
}
```

## Embedding Pipeline

### Current Flow
1. `BatchEmbeddingService.getTranscriptChunks()` loads `Transcript.fullText`
2. `chunkText()` splits into chunks
3. Each chunk → `BedrockService.generateEmbedding()` (Cohere/Titan)
4. `OpensearchService.insertEmbeddings()` stores in `transcript_embeddings`

### Cohere Embed v3 Specifics

```typescript
// Document embedding (indexing time)
{
  texts: [chunkText],
  input_type: 'search_document',
  embedding_types: ['float'],
  truncate: 'END',
}

// Query embedding (search time) — SHOULD use search_query
{
  texts: [queryText],
  input_type: 'search_query',  // Different from search_document
  embedding_types: ['float'],
  truncate: 'END',
}
```

**Cohere v3 max input**: ~512 tokens (truncates with `truncate: 'END'`). If chunks are larger than 512 tokens, Cohere silently truncates. This means large chunks waste text beyond the truncation point.

**Recommendation**: Set chunk size to **400-500 tokens** to stay within Cohere's effective window.

### Caching
Embeddings are cached in Redis with 7-day TTL using SHA256 hash of input text as key. Cache is checked before rate limiter, which is good for avoiding unnecessary API calls.

## Timecode Resolution

After semantic search returns matching chunks, timecodes are resolved:

1. kNN search returns `transcript_embeddings` documents with `start_time`/`end_time`
2. For each match, find the corresponding `TranscriptSegment` in PostgreSQL
3. Return `startTimeSeconds`/`endTimeSeconds` in highlights

### Current Resolution Logic
```
semantic result → asset_id + start_time
  → find TranscriptSegment where assetId matches and startTime is closest
  → return segment's startTime/endTime for player navigation
```

### Edge Case: Multiple Chunks Per Segment
When chunks are smaller than segments, multiple chunks may map to the same segment. The current logic takes the best-scoring chunk's timecode per asset, which is correct.

### Edge Case: Chunk Spans Multiple Segments
When chunks are larger than segments, a single chunk covers multiple segments. The returned timecode should be the start of the first segment in the chunk, but precision is lost for matches in later parts of the chunk.

**Fix**: Store per-sentence timecodes in chunk metadata to enable sub-chunk timecode resolution.

## Transcript Aggregation

The dedicated transcript search supports aggregating nearby matches:

```typescript
{
  transcriptAggregation: {
    enabled: true,
    timeWindowSeconds: 30,    // merge segments within 30s
    contextWords: 20,         // include 20 words before/after
    minSegmentGap: 5,         // only merge if gap < 5s
  }
}
```

**Output**: `AggregatedTranscriptSegment` with:
- `timecodeRange`: { start, end } covering all merged segments
- `matchedText`: the matching text
- `contextBefore` / `contextAfter`: surrounding words for context
- `segmentCount`: how many raw segments were merged

This is useful for showing meaningful transcript excerpts in search results rather than isolated sentence fragments.

## Transcript Intelligence

`TranscriptSummaryMemory` stores extracted metadata per transcript:
- `summaryText`: AI-generated summary
- `topics`: array of topic strings
- `keywords`: array of keyword strings

Both SQL and semantic strategies query this for relevance boosting:

**SQL strategy**: Matches topics/keywords against search terms, adds weighted boost to final score.

**Semantic strategy**: Computes keyword/topic overlap ratio, adds additive boost to `relevanceScore`.

This allows queries like "climate change" to boost assets whose transcript intelligence mentions climate-related topics, even if the exact phrase isn't in the matched chunk.

## SQL Transcript Search

PostgreSQL fulltext search on transcripts uses:
- `Transcript.searchVector` (tsvector column with GIN index)
- `ts_rank` for relevance scoring
- `LIKE` pattern matching for phrase matching
- Logarithmic scaling for occurrence count: `1 + log(1 + occurrences) * 0.3`
- `LATERAL` join on `TranscriptSegment` for first-match timecode

The SQL approach finds exact text matches and is better for:
- Specific quotes ("she said the project was cancelled")
- Technical terms that embedding models may not handle well
- Proper nouns and rare words

## Improvement Opportunities

### 1. Reduce Chunk Size
Current 8000-token chunks are too large for Cohere v3 (512-token effective window). Reducing to 400-500 tokens:
- Eliminates wasted text beyond truncation
- Produces more precise embeddings
- Improves timecode resolution accuracy
- Increases number of vectors (more storage, but better recall)

### 2. Add Chunk Overlap
10-20% overlap between chunks prevents losing context at boundaries. A query matching text that spans a chunk boundary currently misses it entirely.

### 3. Speaker-Annotated Embeddings
Prepend speaker identity to chunk text before embedding:
```
"[Speaker: John Smith] I think the project timeline needs to be extended because..."
```
This helps semantic search distinguish who said what.

### 4. Hierarchical Retrieval
Two-phase approach:
1. **Coarse**: Search asset-level embeddings (summary + topics) to find relevant assets
2. **Fine**: Search transcript chunks within those assets for specific segments

This reduces the search space and improves both speed and relevance.

### 5. Re-ranking with Cross-Encoder
After initial kNN retrieval, re-rank top-N results with a cross-encoder model (e.g., Cohere Rerank) for higher precision. Cross-encoders are too slow for full-index search but excellent for re-ranking 20-50 candidates.

### 6. Parallel Chunk + Segment Indexing
Currently, chunks are indexed but individual segments aren't embedded. For fine-grained timecode search, consider:
- Short chunks (200 tokens) for precision timecodes
- Long chunks (1000 tokens) for broader context matching
- Search both, merge by asset, return the best timecode
