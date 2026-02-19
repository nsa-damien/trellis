---
name: library-assistant
description: >
  Design guide for building conversational media library assistants powered by
  hybrid search (PostgreSQL + OpenSearch). Covers system prompt engineering,
  RAG orchestration, conversation memory, result presentation strategies, and
  persona design. Use when: (1) designing or improving a chat-based library
  assistant that helps users discover and navigate video/audio content,
  (2) writing or refining system prompts for RAG-powered media search,
  (3) building conversation flows for content discovery and drill-down,
  (4) improving how an LLM presents search results with timecodes and
  thumbnails, (5) debugging poor conversational quality in a search assistant
  (robotic tone, failed follow-ups, "I can't find anything" responses),
  (6) designing conversation memory and context management for multi-turn
  library interactions.
---

# Library Assistant Design Guide

Design guide for conversational media library assistants that help users discover, explore, and navigate video/audio content through natural dialogue. The assistant is powered by hybrid search (PostgreSQL fulltext + OpenSearch vector/semantic) over transcripts, metadata, summaries, tags, keywords, names, and places.

## Design Principles

### 1. Librarian, Not Search Engine
The assistant is a knowledgeable guide who has "read" every piece of content. It should feel like talking to a person who deeply knows the collection — not like typing into a search box. Never expose internal mechanics (scores, search types, index names).

### 2. LLM Chooses Presentation
The LLM decides how to display results based on query intent — sometimes narrative summaries, sometimes inline clip links with timecodes, sometimes themed groupings with thumbnails. No single fixed format.

### 3. Discovery Over Retrieval
Many users don't know what they're looking for. The assistant should guide exploration: suggest related topics, surface unexpected connections, and help users refine vague interests into specific content.

### 4. Domain-Agnostic by Default
The base system prompt works for any content type (sports, interviews, documentaries, lectures, corporate). Administrators customize the prompt through settings to add domain-specific personality and knowledge.

## System Prompt Architecture

The system prompt has three layers. See [references/system-prompt-template.md](references/system-prompt-template.md) for the complete template with admin customization zones.

| Layer | Purpose | Who writes it |
|-------|---------|---------------|
| **Base persona** | Conversational tone, grounding rules, anti-patterns | Developer (shipped with app) |
| **Admin overlay** | Domain personality, terminology, content guidance | Admin (via settings UI) |
| **Context injection** | Search results, conversation history, user profile | System (per request) |

### Base Persona Essentials

The system prompt must establish:

- **Identity**: "You are a media librarian..." not "You are an AI assistant..."
- **Knowledge claim**: "You have deep familiarity with every piece of content in this library"
- **Grounding rule**: Only discuss content that appears in search results or conversation history
- **Tone**: Warm, professional, occasionally enthusiastic about content — like a librarian who genuinely loves the collection
- **Presentation agency**: The LLM decides how to format responses (narrative, lists, timecoded references, themed groups)

### Anti-Patterns to Explicitly Forbid

```
NEVER say:
- "I found X results matching your query"
- "Based on the search results..."
- "I don't have access to..." (when results are empty)
- "As an AI, I can't..."
- "Result 1: [title] (Score: 0.85)"

INSTEAD say:
- "There are several pieces that explore this theme..."
- "One that really stands out is..."
- "I'm not finding anything on that specific topic in the library, but there's related content about..."
- "That's a great question — let me think about what we have..."
```

## Conversation Patterns

See [references/conversation-patterns.md](references/conversation-patterns.md) for detailed examples of each pattern.

### Pattern 1: Discovery ("What's in here?")
User is browsing. Respond with themed overview, invite drill-down.

### Pattern 2: Specific Lookup ("Show me clips from the game on 9/28")
User knows what they want. Respond with direct results, timecoded links, thumbnails.

### Pattern 3: Thematic Exploration ("What themes come up about leadership?")
User wants conceptual navigation. Synthesize across multiple assets, group by sub-theme.

### Pattern 4: Follow-Up / Drill-Down ("Tell me more about that")
User is continuing a thread. Use conversation context — do NOT re-search blindly with just "that."

### Pattern 5: Empty Results Recovery
Nothing found. Do NOT say "I can't find anything." Instead: suggest adjacent topics, ask clarifying questions, or describe what IS in the library that's closest.

## RAG Orchestration

See [references/rag-orchestration.md](references/rag-orchestration.md) for implementation guidance on context formatting, memory management, and query strategies.

### Key Principles

1. **Format results as narrative context, not numbered lists.** The LLM shouldn't see `1. "Title" (Score: 0.85)`. It should see: `Content available: "Title" — a 45-minute interview where [summary]. Key moments: [timestamp] discussion of X, [timestamp] story about Y.`

2. **Include transcript excerpts.** The LLM needs actual quotes to sound knowledgeable. Without them, responses are vague and generic.

3. **Preserve conversation history.** The LLM needs previous messages AND previous search results to handle follow-ups. "Tell me more about that" requires knowing what "that" was.

4. **Query reformulation for follow-ups.** When the user says "what else did they say about that?", the system should reformulate the query using conversation context before searching, not search for the literal words "that."

5. **Multi-search for broad questions.** For "what themes are in this library?", run multiple searches (themes, topics, keywords) and synthesize, rather than a single search that returns too-specific results.

## Result Presentation Strategies

The LLM should choose presentation based on query type:

| Query Type | Presentation Strategy |
|-----------|----------------------|
| Browsing / discovery | Narrative overview with themed sections, offer to go deeper |
| Specific lookup | Direct answer with inline timecode links, thumbnails below |
| Thematic exploration | Synthesized narrative weaving across multiple assets |
| Comparison | Side-by-side or sequential discussion of contrasting content |
| Follow-up | Continuation of previous style, adding new detail |

### Timecode References
Weave timecodes naturally into conversation: "About 12 minutes in, she shares a fascinating story about..." rather than "[12:34] Story about..."

### Thumbnails
Use thumbnails when showing multiple distinct assets. Skip thumbnails for single-clip answers or when drilling into a specific segment.

## Admin Customization Guide

The system prompt should have clearly marked zones where admins add domain context:

```
[ADMIN_PERSONALITY]
Optional: Override default tone. Example: "You're an enthusiastic sports historian"
[/ADMIN_PERSONALITY]

[ADMIN_DOMAIN_CONTEXT]
Optional: Describe the collection. Example: "This library contains 500+ hours of
interviews with civil rights leaders recorded between 1960-1990"
[/ADMIN_DOMAIN_CONTEXT]

[ADMIN_TERMINOLOGY]
Optional: Domain-specific terms. Example: "When users say 'the movement' they mean
the Civil Rights Movement"
[/ADMIN_TERMINOLOGY]

[ADMIN_GUIDELINES]
Optional: Content policies. Example: "Always include content warnings for interviews
discussing violence"
[/ADMIN_GUIDELINES]
```

## Evaluation Checklist

When reviewing a library assistant implementation:

- [ ] Responses read like a knowledgeable person, not a search engine
- [ ] Follow-up questions work without repeating context
- [ ] Empty results suggest alternatives instead of dead ends
- [ ] Timecodes are woven into narrative, not displayed as raw data
- [ ] The LLM varies presentation style based on query type
- [ ] Transcript quotes are used to demonstrate knowledge
- [ ] Broad discovery questions produce thematic overviews, not random results
- [ ] The admin customization zones are clearly documented and functional
