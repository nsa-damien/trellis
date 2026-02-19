# OpenSearch Patterns for Media Search

## Table of Contents
- [Index Mappings](#index-mappings)
- [HNSW Tuning](#hnsw-tuning)
- [kNN Query Patterns](#knn-query-patterns)
- [Filtered Vector Search](#filtered-vector-search)
- [Bulk Indexing](#bulk-indexing)
- [Common Issues](#common-issues)

## Index Mappings

### asset_embeddings

```json
{
  "settings": {
    "index": { "knn": true },
    "number_of_shards": 1,
    "number_of_replicas": 0
  },
  "mappings": {
    "properties": {
      "id":          { "type": "keyword" },
      "vector":      { "type": "knn_vector", "dimension": 1024,
                       "method": { "name": "hnsw", "space_type": "cosinesimil",
                                   "engine": "nmslib",
                                   "parameters": { "ef_construction": 512, "m": 16 } } },
      "text":        { "type": "text", "fields": { "keyword": { "type": "keyword" } } },
      "asset_id":    { "type": "keyword" },
      "asset_type":  { "type": "keyword" },
      "tags":        { "type": "keyword" },
      "collections": { "type": "keyword" },
      "timestamp":   { "type": "date" }
    }
  }
}
```

### transcript_embeddings

```json
{
  "mappings": {
    "properties": {
      "id":         { "type": "keyword" },
      "vector":     { "type": "knn_vector", "dimension": 1024,
                      "method": { /* same HNSW config */ } },
      "text":       { "type": "text", "fields": { "keyword": { "type": "keyword" } } },
      "asset_id":   { "type": "keyword" },
      "start_time": { "type": "float" },
      "end_time":   { "type": "float" },
      "timestamp":  { "type": "date" }
    }
  }
}
```

### Recommended Additional Fields for transcript_embeddings

Consider adding to improve filtering and debugging:

```json
{
  "speaker_id":    { "type": "keyword" },
  "language":      { "type": "keyword" },
  "chunk_index":   { "type": "integer" },
  "total_chunks":  { "type": "integer" },
  "confidence":    { "type": "float" }
}
```

## HNSW Tuning

| Parameter | Current | Effect of increase | Guidance |
|-----------|---------|-------------------|----------|
| `ef_construction` | 512 | Better recall, slower indexing | 256-512 is good. >512 rarely helps |
| `m` | 16 | More connections, higher memory | 16 is standard. 32 for >1M docs |
| `ef_search` | 512 | Better recall, slower queries | Start at `k * 2` minimum. 256-512 for quality |

**Current settings are aggressive for quality.** For production with latency constraints:
- Reduce `ef_search` to 256 if queries are slow
- `ef_construction` only matters at index time — high values are fine

### Engine Choice

Current: `nmslib`. OpenSearch 3.x also supports:
- **faiss**: Better for large datasets (>10M vectors), supports IVF+PQ compression
- **lucene**: Native engine, supports pre-filtering (filters applied before kNN, not post-filter)

**Recommendation for pre-filtered search**: Switch to `lucene` engine. With `nmslib`, filters are applied AFTER kNN retrieval, which can return fewer than `k` results when many vectors are filtered out. Lucene applies filters during the search.

## kNN Query Patterns

### Basic kNN
```json
{
  "size": 20,
  "min_score": 0.3,
  "query": {
    "knn": {
      "vector": {
        "vector": [0.1, 0.2, ...],
        "k": 20
      }
    }
  }
}
```

### kNN with Post-Filter (nmslib)
```json
{
  "size": 20,
  "query": {
    "bool": {
      "must": [
        { "knn": { "vector": { "vector": [...], "k": 100 } } }
      ],
      "filter": [
        { "term": { "asset_type": "video" } },
        { "range": { "start_time": { "gte": 0, "lte": 300 } } }
      ]
    }
  }
}
```

**Important**: With nmslib, `k` should be larger than `size` when filters are present, because filtering happens AFTER retrieval. Use `k = size * 3` or `k = 100` as a floor.

### kNN with Pre-Filter (lucene engine)
```json
{
  "size": 20,
  "query": {
    "knn": {
      "vector": {
        "vector": [...],
        "k": 20,
        "filter": {
          "bool": {
            "must": [
              { "term": { "asset_type": "video" } }
            ]
          }
        }
      }
    }
  }
}
```

Pre-filtering is more accurate but requires the `lucene` engine.

## Filtered Vector Search

### Time-Range Filtering for Transcripts
```json
{
  "query": {
    "bool": {
      "must": [
        { "knn": { "vector": { "vector": [...], "k": 50 } } }
      ],
      "filter": [
        { "term": { "asset_id": "abc-123" } },
        { "range": { "start_time": { "gte": 60, "lte": 180 } } }
      ]
    }
  }
}
```

### Multi-Asset Filtering
```json
{
  "filter": [
    { "terms": { "asset_id": ["id1", "id2", "id3"] } }
  ]
}
```

## Bulk Indexing

Use the `_bulk` API for batch operations:

```typescript
const body = items.flatMap(item => [
  { index: { _index: 'transcript_embeddings', _id: item.id } },
  {
    vector: item.embedding,
    text: item.text,
    asset_id: item.assetId,
    start_time: item.startTime,
    end_time: item.endTime,
    timestamp: Date.now(),
  },
]);
await client.bulk({ body });
```

**Batch size**: 50-100 documents per bulk request. Larger batches risk timeouts with 1024-dim vectors.

### Refresh Strategy
- During bulk indexing: `refresh: false` or `refresh: 'wait_for'`
- After bulk completes: explicit `POST /index/_refresh`
- For real-time search: keep default refresh interval (1s)

## Common Issues

### "Fewer results than expected with filters"
**Cause**: nmslib post-filtering. kNN retrieves `k` nearest, then filters.
**Fix**: Increase `k` (e.g., `k = limit * 5`) or switch to lucene engine for pre-filtering.

### "Scores don't match between runs"
**Cause**: HNSW is approximate. Results can vary slightly.
**Fix**: Increase `ef_search` for more deterministic results. Not a bug.

### "Index creation fails with dimension mismatch"
**Cause**: Existing index has different vector dimension than new embeddings.
**Fix**: Delete and recreate index, or use a new index name. Cannot change dimensions in-place.

### "Slow kNN queries"
**Cause**: Large `ef_search`, too many shards, or segment count.
**Fix**: Force-merge to 1 segment per shard: `POST /index/_forcemerge?max_num_segments=1`

### "Out of memory during indexing"
**Cause**: 1024-dim vectors consume ~4KB each. 1M vectors ≈ 4GB RAM.
**Fix**: Monitor JVM heap. Use circuit breakers. Consider dimension reduction or quantization for >5M vectors.
