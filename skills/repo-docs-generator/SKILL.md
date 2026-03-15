---
name: repo-docs-generator
description: >
  Generates a structured three-document documentation package from a codebase or repository: a Technical Overview (with architecture and data flow diagrams), a Deployment & Troubleshooting Guide, and a non-technical User Guide. Use this skill whenever a user shares a repo, codebase, or application and asks for documentation, docs, a technical overview, a user guide, a runbook, a deployment guide, or any combination of these. Also trigger when a user says things like "document this", "write docs for this", "generate documentation", or "I need docs for this project." Always conduct a turn-based interview before writing anything.
---

# Repo Documentation Generator

This skill produces a three-document documentation package from a provided codebase. It always conducts a structured, turn-based interview before writing any documentation.

> **Core Rule — Enforced Throughout:** This is a turn-based interaction. Ask one question or make one request at a time. Wait for a response. Never list multiple questions. Never advance to the next phase until the current one is complete.

---

## Phase 1 — Receive the Repository and Gather Context

The user will provide a codebase via uploaded files, a ZIP archive, pasted code, or a repository link.

When the repository arrives:
1. Acknowledge receipt.
2. Briefly describe what you see — language(s), apparent structure, key files or components.
3. Do not make assumptions about what the application does or who uses it.
4. Ask this single question and wait for a response before doing anything else:

> *"Before I start — are there any additional materials I should factor in? Things like existing architecture diagrams, a README, design specs, a runbook, API docs, or stakeholder notes would all be useful. You can upload files, paste content directly, or just describe what's available."*

Once the user responds (even if the answer is "nothing"), proceed to Phase 2.

---

## Phase 2 — Clarifying Interview (3–7 Questions, One at a Time)

Ask between 3 and 7 clarifying questions, scaling to the complexity of what you observed. A small CLI tool may need only 3; a multi-service platform may need the full 7. Ask them **one at a time**. After each answer, briefly acknowledge what you learned, then ask the next question.

Base your questions on what you actually observed in the code and any supplemental materials. Do not use a generic fixed list — tailor them to what you see. Draw from these areas, selecting the most relevant gaps:

- What does this application do, and what problem does it solve?
- Who are the intended readers of each document — developers, operators, executives, end users?
- What external systems, APIs, services, or databases does it integrate with?
- What is the deployment environment — cloud, on-prem, containerized, hybrid?
- Are there known pain points, failure modes, or gotchas that should be highlighted?
- Who operates this day-to-day, and how technical are they?
- Are there naming conventions, internal terminology, or a glossary the docs should use?
- What is the authentication/authorization model?
- Are there data sensitivity or compliance constraints that affect deployment or usage?
- What is the versioning/release cadence?
- Is there existing monitoring or alerting in place?

**After the final question is answered**, summarize your understanding in 3–5 sentences and ask:

> *"Does this capture it accurately, or is there anything I've missed before I start writing?"*

Wait for explicit confirmation before proceeding. If the user corrects or adds something, incorporate it and confirm again.

---

## Phase 3 — Generate the Documentation Package

Once the user confirms your understanding, generate all three documents. Output them as Markdown with a Table of Contents at the top of each. Use Mermaid diagrams where they add clarity — but if the codebase is simple enough that a diagram would be trivial, omit it rather than forcing one.

Scale document depth to the codebase. A single-service app should produce concise, focused documents; a multi-service platform warrants deeper treatment of each component.

**Output location:** Before generating, suggest `./docs/` as the default output folder and ask:

> *"I'll save the documents to `./docs/`. Does that work, or would you prefer a different location?"*

Wait for confirmation, then use the agreed-upon path.

**Monorepos and multi-app repositories:** If the repo contains multiple distinct applications, ask whether to produce one documentation set per application or one unified set before generating.

```
docs/
├── technical-overview.md
├── deployment-and-troubleshooting.md
└── user-guide.md
```

---

### Document 1: `technical-overview.md`

**Audience:** Developers, architects, technically skilled readers.

Each document should include a "Last generated" timestamp and the commit hash or version it was generated from at the top.

Required sections:
- **Executive Summary** — Plain-language description of what the application does and why it exists
- **System Architecture** — Description of all systems involved + Mermaid architecture diagram (if warranted by complexity)
- **Component Breakdown** — Each major component: its role, tech stack, and dependencies
- **Data Flow** — How data moves through the system + Mermaid data flow diagram (if warranted by complexity)
- **External Integrations** — Third-party systems, APIs, or services and how they connect
- **Key Configuration & Environment Variables** — Notable settings that affect behavior
- **Known Limitations or Technical Debt** — Document any limitations, technical debt, or architectural constraints observable in the code. If none are apparent, state that explicitly rather than omitting the section.

---

### Document 2: `deployment-and-troubleshooting.md`

**Audience:** DevOps engineers, sysadmins, technical operators.

Required sections:
- **Deployment Overview** — Architecture and environment summary
- **Deployment Steps** — Step-by-step deploy/update instructions
- **System Communication Points** — Every communication boundary between components: what talks to what, how (protocol/format), and what healthy looks like
- **Common Failure Modes** — Known or likely failure scenarios, organized by component or integration
- **Where to Look When Things Go Wrong** — For each major area:
  - Log locations or aggregation tools
  - Health check endpoints or monitoring dashboards
  - Key signals that indicate a problem
  - Escalation path if unresolvable at this level
- **Dependency Health Checks** — How to verify external services are functioning
- **Rollback Procedure** — Steps to safely roll back a failed deployment

---

### Document 3: `user-guide.md`

**Audience:** Non-technical operators and end users. No jargon. Define any unavoidable terms on first use.

**Adapt to the application type:**
- For GUI/web applications, use the sections below as written.
- For CLIs, replace "Understanding the Interface" with a **Command Reference** and use terminal examples instead of screenshot placeholders.
- For APIs or libraries, replace "Understanding the Interface" with an **Endpoint Catalog** or **Usage Examples** section.

Required sections:
- **What This Application Does** — Simple, plain-language explanation of its purpose
- **Getting Started** — How to access or launch the application
- **Core Workflows** — Step-by-step walkthroughs of the main tasks, written as numbered instructions. Use `[Image: description]` placeholders where screenshots would help (GUI apps only).
- **Understanding the Interface** — Key screens or UI elements described in plain language (see adaptation note above)
- **Common Questions & Issues** — FAQ-style section covering likely confusion points or minor errors
- **What to Do If Something Looks Wrong** — Non-technical guidance on identifying a problem and who to contact
- **Glossary** — Definitions of any terms the user needs to know

---

## Output Format Rules

- All three documents must be valid Markdown
- Each document must open with a **Table of Contents** using anchor links
- Each document must include a **"Last generated"** timestamp and commit hash or version at the top
- Use **Mermaid** for diagrams (` ```mermaid ` fenced blocks) where they add clarity — omit trivial diagrams
- Use **consistent terminology** across all three documents
- **Cross-reference bidirectionally:** the Technical Overview should reference the Deployment Guide for operational procedures and the User Guide for end-user workflows; the Deployment Guide should reference the Technical Overview for architecture context; the User Guide should reference the other documents where deeper detail is available
- When code and provided supplemental materials conflict, **flag the discrepancy** with a note describing both versions rather than silently choosing one
- If information cannot be determined from the provided materials, use this placeholder:
  > ⚠️ **[TO BE CONFIRMED]:** *Description of what's needed and why*

---

## Phase 4 — Offer Additional Documentation

After delivering all three documents, proactively recommend any additional documents suggested by gaps you identified during generation. Then ask:

> *"Would you like me to generate any additional documentation? Based on what I saw, I'd specifically recommend [list any gap-driven suggestions]. Other options include a changelog template, API reference, onboarding guide, security overview, or data dictionary. Just let me know what would be useful."*

Wait for a response. If the user requests additional docs, generate them using the same Markdown format and Table of Contents convention. Ask one clarifying question at a time if needed before writing.
