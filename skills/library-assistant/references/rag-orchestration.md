# RAG Orchestration

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [Context Formatting](#context-formatting)
- [Conversation Memory](#conversation-memory)
- [Query Strategy Selection](#query-strategy-selection)
- [Follow-Up Query Reformulation](#follow-up-query-reformulation)
- [Multi-Search for Broad Questions](#multi-search-for-broad-questions)
- [Result Enrichment](#result-enrichment)
- [Token Budget Management](#token-budget-management)
- [Common Failures and Fixes](#common-failures-and-fixes)

## Architecture Overview

```
User Message
  │
  ├─ Is this a follow-up? ──yes──► Reformulate query from conversation context
  │                                  │
  │                                  ▼
  ├─ Is this broad/discovery? ──yes──► Multi-search strategy
  │                                     │
  │                                     ▼
  ├─ Is this specific lookup? ──yes──► Targeted search with filters
  │                                     │
  │                                     ▼
  │                              Search Backend
  │                          (SQL + Semantic + Hybrid)
  │                                     │
  │                                     ▼
  │                          Enrich results with:
  │                          - Transcript excerpts
  │                          - Timecodes
  │                          - Summaries
  │                          - Related metadata
  │                                     │
  │                                     ▼
  │                          Format as narrative context
  │                                     │
  │                                     ▼
  │                          Assemble LLM prompt:
  │                          System Prompt
  │                          + Conversation History
  │                          + Search Results Context
  │                          + User Message
  │                                     │
  │                                     ▼
  │                              LLM Response
  │                                     │
  │                                     ▼
  │                          Store in conversation memory:
  │                          - User message
  │                          - Search results used
  │                          - Assistant response
```

## Context Formatting

### Principle: Results as Knowledge, Not Data

The LLM should receive search results as if they're its own knowledge base, not as raw data to regurgitate.

### Bad: Data Dump
```
Search Results:
[{"id":"abc123","title":"Interview with John Smith","score":0.85,"matchType":"transcript",
"highlights":[{"field":"transcript","snippet":"leadership is about...","startTimeSeconds":745}]}]
```

### Bad: Numbered List
```
Results for "leadership":
1. "Interview with John Smith" (Score: 0.85)
   - Transcript match at 12:25: "leadership is about..."
2. "Panel Discussion" (Score: 0.72)
   - Metadata match: tags include "leadership"
```

### Good: Narrative Context
```
CONTENT RELATED TO THIS QUERY:

"Interview with John Smith" — 45-minute interview, March 2024
John Smith is a former tech CEO who spent 20 years building two companies.
Summary: Candid discussion of leadership philosophy, shaped by early career failures.
Tags: leadership, career transitions, mentorship, failure, tech industry
Relevant transcript moments:
  [12:25] "Leadership isn't a title, it's a practice. I learned that the hard way after my first company imploded because I confused authority with influence."
  [24:15] "The best leaders I've known are the ones who made themselves unnecessary. They built teams that didn't need them."
  [38:00] Discusses work-life balance and admits to burnout: "I was productive but I wasn't present."

"Panel Discussion: Modern Management" — 60-minute panel, January 2024
Four executives debate traditional vs. modern management approaches.
Summary: Energetic debate. Notable disagreement on remote work. Surprising convergence on mentorship.
Tags: management, remote work, servant leadership, organizational culture
Panelists: Sarah Lee (Finance), Marcus Johnson (Tech), Lisa Wong (Healthcare), Robert Hayes (Manufacturing)
Relevant moments:
  [8:00] Opening positions from each panelist
  [31:45] Heated exchange between Johnson and Hayes about remote work: "Marcus, you're living in a bubble" / "Robert, you're living in the past"
  [52:00] All four agree on mentorship importance, which moderator calls "the only thing you've agreed on"
```

### Formatting Guidelines

1. **Lead with identity**: Title, duration, date, who is in it
2. **Summary in 1-2 sentences**: What's the overall content about
3. **Tags/keywords inline**: Help the LLM connect themes
4. **Transcript excerpts with timecodes**: Actual quotes the LLM can reference
5. **Editorial notes**: Add context like "heated exchange" or "surprising admission" that helps the LLM characterize the content
6. **No scores or match types**: The LLM doesn't need to know how something was found

## Conversation Memory

### What to Store Per Turn

```typescript
interface ConversationTurn {
  role: 'user' | 'assistant';
  content: string;
  // Store the search context that informed this response
  searchContext?: {
    query: string;          // The actual query sent to search
    searchType: string;     // fulltext, semantic, hybrid
    resultIds: string[];    // Asset IDs returned
    resultSummaries: Array<{
      assetId: string;
      title: string;
      relevantTopics: string[];  // What topics from this asset were discussed
    }>;
  };
  timestamp: Date;
}
```

### Why Store Search Context

Without it, follow-ups fail:

```
Turn 1: User asks about leadership → Search returns 5 assets → LLM discusses 3
Turn 2: User says "tell me more about the second one"
```

If Turn 1's search results aren't stored, the system can't resolve "the second one." It would need to re-search, and "the second one" isn't a useful query.

With stored context, the system knows "the second one" = the Panel Discussion, and can either:
- Expand from the already-retrieved context (no new search needed)
- Search specifically for that asset's content

### Memory Window Strategy

For most conversations, keep the last **6-8 turns** in full context. For longer conversations:

1. **Recent turns** (last 4): Full content + search context
2. **Earlier turns** (4-8): Summarized content + asset IDs referenced
3. **Very old turns** (8+): Topic list only ("discussed: leadership, failure themes, Dr. Patel's interview")

### Detecting Follow-Ups

Heuristics for identifying follow-up vs. new query:

| Signal | Follow-up? | Action |
|--------|-----------|--------|
| Pronouns: "that", "it", "she", "they" | Yes | Resolve from context |
| "More about..." / "Tell me more" | Yes | Expand current thread |
| "What about X?" (new topic) | No | New search |
| "Earlier you mentioned..." | Yes (distant) | Search conversation history |
| "Going back to..." | Yes (distant) | Restore prior context |
| Complete new question | No | New search |

## Query Strategy Selection

### Decision Matrix

| User Query Pattern | Strategy | Example |
|-------------------|----------|---------|
| Broad browsing | Faceted aggregation + theme search | "What's in this library?" |
| Specific asset | SQL with title/name filter | "Find the John Smith interview" |
| Date-specific | SQL with date filter | "Clips from September 2025" |
| Thematic | Semantic search on summaries + keywords | "What do people say about failure?" |
| Quote lookup | SQL fulltext on transcript | "Who said 'leadership is a practice'?" |
| Follow-up | Context resolution, optional re-search | "Tell me more about that" |
| Comparative | Multiple searches, merged | "How do views on AI differ?" |
| People/places | Metadata filter + semantic | "Interviews from Japan" |

### Search Type Recommendations

| Query Characteristic | Preferred Search Type | Why |
|---------------------|----------------------|-----|
| Exact terms, names, dates | `fulltext` (SQL) | Precise matching, filters work well |
| Conceptual, thematic | `semantic` | Embeddings capture meaning beyond exact words |
| General purpose | `hybrid` | Best recall, covers both exact and conceptual |
| Vague or exploratory | `semantic` with low threshold | Cast a wide net for discovery |

## Follow-Up Query Reformulation

When a user's message is a follow-up, transform it into a searchable query using conversation context.

### Before Reformulation
```
Conversation: [discussed failure themes, mentioned Dr. Patel]
User: "What else did she say?"
Raw query: "What else did she say?" → Terrible search query
```

### After Reformulation
```
Resolved: "she" = Dr. Patel (from conversation context)
Reformulated query: "Dr. Aisha Patel interview topics beyond failure"
Additional context: Already discussed failure segment (30:00-42:00)
```

### Reformulation Process

1. **Resolve references**: Replace pronouns and demonstratives with actual entities from context
2. **Identify the continuation request**: What new information is being asked for?
3. **Exclude already-discussed content**: If possible, avoid returning the same segments
4. **Construct searchable query**: Combine resolved entity + new information need

```typescript
function reformulateFollowUp(
  userMessage: string,
  conversationHistory: ConversationTurn[]
): { query: string; filters: any; excludeAssetIds?: string[] } {
  // Extract entities from recent conversation
  const recentContext = conversationHistory.slice(-4);
  const mentionedAssets = recentContext.flatMap(t => t.searchContext?.resultSummaries || []);
  const discussedTopics = recentContext.flatMap(t => t.searchContext?.resultSummaries?.flatMap(r => r.relevantTopics) || []);

  // Resolve pronouns to entities
  // "she" / "he" → most recently mentioned person
  // "that" / "it" → most recently discussed asset or topic
  // "the second one" → second item from most recent result list

  // Build reformulated query
  // Combine resolved entity + user intent + exclude already-seen
}
```

## Multi-Search for Broad Questions

For discovery queries, a single search is insufficient. Run multiple searches and synthesize.

### Example: "What themes are in this library?"

```
Search 1: Aggregate tags → get top 20 tags by frequency
Search 2: Aggregate keywords from transcript intelligence store → get top themes
Search 3: Semantic search for "main topics themes subjects" → get representative assets
Search 4: Faceted search → asset types, date distribution, creator distribution
```

Assemble the results into a rich context the LLM can use to paint a picture of the collection.

### Example: "What do people disagree about?"

```
Search 1: Semantic search for "disagreement debate controversy argument"
Search 2: Search transcript intelligence for topics tagged with conflict/debate
Search 3: Look for panel discussions (asset type + metadata) which inherently have multiple viewpoints
```

## Result Enrichment

Raw search results often lack the detail needed for conversational responses. Enrich before sending to the LLM.

### Enrichment Pipeline

```
Raw search results (id, score, snippet)
  │
  ├─ Hydrate with full asset metadata (title, date, duration, tags, creator)
  │
  ├─ Fetch transcript summary from transcript intelligence store
  │
  ├─ Fetch 2-3 representative transcript excerpts with timecodes
  │   (not just the matching snippet — also key moments from summary)
  │
  ├─ Resolve participant/speaker names if available
  │
  ├─ Add editorial context from tags/keywords
  │
  └─ Format as narrative context block
```

### How Much to Enrich

| Number of Results | Detail Level | Rationale |
|------------------|-------------|-----------|
| 1-2 results | Full enrichment: summary, 3-5 excerpts, all metadata | User likely wants depth |
| 3-5 results | Medium: summary, 1-2 key excerpts each | Balance breadth and depth |
| 6+ results | Light: title, summary, 1 best excerpt | Overview, let user drill down |

## Token Budget Management

### Budget Allocation

For a typical 8K-16K context window:

| Component | Allocation | Notes |
|-----------|-----------|-------|
| System prompt | 800-1200 tokens | Base + admin customization |
| Conversation history | 2000-4000 tokens | Last 4-6 turns, summarize older |
| Search results context | 3000-6000 tokens | Scale by result count |
| User message | 100-500 tokens | Current query |
| Response budget | 2000-4000 tokens | Leave room for the answer |

### Compression Strategies

When approaching the limit:
1. **Summarize older conversation turns** (keep last 2 in full)
2. **Reduce excerpts per result** (1 instead of 3)
3. **Trim search results** (top 3 instead of top 5)
4. **Shorten summaries** (1 sentence instead of 2-3)

Never compress: the system prompt, the user's current message, or the most recent assistant response.

## Common Failures and Fixes

### "I can't find anything about that"

**Cause**: Search returned empty results and the LLM has no fallback content.

**Fix**: Always run a secondary broader search when primary returns empty. Feed the LLM both "nothing matched exactly" AND "here's what's closest" so it can pivot gracefully.

### Robotic Response Style

**Cause**: Search results formatted as structured data (JSON, numbered lists with scores). The LLM mirrors the input format.

**Fix**: Format results as narrative context. The LLM's output quality is directly proportional to the quality of the input context formatting.

### Follow-Ups Return Unrelated Content

**Cause**: Follow-up messages sent as literal search queries. "Tell me more about that" doesn't search well.

**Fix**: Implement query reformulation using conversation context. Resolve pronouns and references before searching.

### Responses Are Generic

**Cause**: Search results lack transcript excerpts. The LLM only has titles and summaries to work with.

**Fix**: Include 2-3 transcript excerpts with timecodes per result. The LLM needs specific quotes and moments to sound knowledgeable.

### Same Format Every Response

**Cause**: System prompt doesn't grant presentation agency, or examples in prompt are all one format.

**Fix**: Explicitly instruct the LLM to choose presentation format based on query type. Include examples of different formats in the system prompt or few-shot examples.

### Conversation Drifts Off-Topic

**Cause**: No grounding instruction in system prompt, or grounding is too weak.

**Fix**: Add explicit grounding rule: "Only discuss content that appears in the provided search results or was discussed earlier in this conversation. If users ask about topics not in the library, redirect to what IS available."
