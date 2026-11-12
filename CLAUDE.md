# GoldKing — Claude Code Instructions

## Purpose

This file provides Claude Code with project-specific operating instructions for the GoldKing repository.

Treat `AGENTS.md` as the primary repository-level development contract.

Do not duplicate or replace the authoritative project documents. Read only the documents relevant to the current task.

---

## Start Here

Before substantial repository work:

1. Read `AGENTS.md`.
2. Inspect the relevant existing files.
3. Read only the GoldKing documents needed for the task.
4. Do not edit immediately on non-trivial tasks.
5. First explain what currently exists and propose the smallest reasonable change.

---

## Authoritative Project Documents

### Narrative, world, character, tone, or lore

Read:

`docs/GOLDKING_CONTEXT.md`

This is the authority for Established Canon.

Do not invent missing canon.

---

### Gameplay, presentation, level structure, progression, or world structure

Read:

`docs/GOLDKING_GAMEPLAY_FOUNDATION.md`

Use this for the current approved gameplay/design foundation.

---

### Decision status

Read:

`docs/GOLDKING_DECISION_LOG.md`

Use this to determine whether an idea is:

- Established Canon
- Approved Direction
- Prototype Assumption
- Strong Recommendation
- Experimental Idea
- Open Question
- Deferred
- Rejected

Never promote an unresolved or experimental idea into an approved decision on your own.

---

### Prototype evidence

Read:

`docs/GOLDKING_PROTOTYPE_LOG.md`

Prototype findings should be treated as stronger evidence than assumptions made during brainstorming.

Do not rewrite prototype history to match later decisions.

---

### Feature implementation

If a relevant feature specification exists, read:

`docs/features/<feature>.md`

Implement the approved feature specification rather than expanding the feature from inference.

---

### Architecture

If this file exists, read it when relevant:

`docs/ARCHITECTURE.md`

Document architecture that actually exists.

Do not invent architecture merely because the project may need it someday.

---

## Default Workflow

For non-trivial implementation tasks, follow this sequence.

### 1. Inspect

Before editing:

- Read the relevant scripts and scenes.
- Identify which system currently owns the behavior.
- Identify dependencies and related files.
- Check the relevant project docs.

Do not assume ownership from filenames alone.

---

### 2. Plan

Before implementation:

- Summarize the current implementation.
- State the primary task objective.
- List the minimum files that should change.
- Identify objective acceptance criteria.
- Call out any unresolved design decision the task depends on.
- Avoid unrelated cleanup.

If architecture, gameplay behavior, or project scope would materially change, stop after the plan and wait for human approval.

---

### 3. Implement Narrowly

When approved to proceed:

- Make the smallest reasonable change.
- Use typed GDScript.
- Follow existing project conventions.
- Prefer Godot-native solutions.
- Avoid speculative abstractions.
- Do not add adjacent features that were not requested.
- Do not modify unrelated files.

Do not introduce frameworks for hypothetical future needs.

---

### 4. Validate

After implementation:

- Run the smallest relevant validation.
- Run relevant tests when they exist.
- Check Godot parser/runtime errors when practical.
- Verify scene/resource paths if changed.
- Report exactly what was tested.

Do not claim a test was run if it was not.

Do not claim that gameplay "feels good" based on automated validation.

---

### 5. Report

At completion, summarize:

- Files changed
- Behavior added or modified
- Validation performed
- Known limitations
- What still requires human play/visual/audio/narrative review
- Any new open questions

Keep the summary concise and factual.

---

## GoldKing-Specific Guardrails

### Canon

Do not invent:

- New story facts
- Character history
- Kingdom history
- Factions
- Powers
- Endings
- Mythological rules
- Relationships
- World rules

unless the current task explicitly asks for creative exploration.

If implementation requires an unresolved narrative fact, use a neutral placeholder or identify the issue instead of inventing canon.

---

### Prototype Assumptions

Prototype assumptions are deliberately temporary.

Do not turn them into permanent architecture unless:

- prototype evidence supports them, and
- the direction has been approved.

Current prototype assumptions must remain easy to tune, replace, or remove.

---

### Scope

GoldKing is a small-team project.

Prefer:

- simple
- modular
- testable
- readable
- data-driven where tuning is expected

Avoid:

- speculative framework layers
- premature optimization
- unnecessary inheritance hierarchies
- unnecessary global state
- unnecessary addons
- systems that exist only for hypothetical scale

---

## GDScript Rules

Use typed GDScript unless explicitly instructed otherwise.

Prefer explicit types when known.

Example:

```gdscript
var carried_gold: int = 0
var move_speed: float = 6.0

func add_gold(amount: int) -> void:
    carried_gold += amount
```

General rules:

- Prefer clarity over cleverness.
- Keep functions focused.
- Use descriptive names.
- Prefer composition and normal Godot node/scene patterns.
- Avoid autoload singletons unless project-level ownership clearly requires one.
- Avoid global event buses unless there is a demonstrated need.
- Avoid custom dependency injection frameworks.
- Avoid custom gameplay-tag frameworks.
- Avoid custom state-machine frameworks unless the feature genuinely requires one.
- Prefer exported values for frequently tuned gameplay parameters when practical.
- Comments should explain why, not restate obvious code.
- Remove dead code instead of preserving speculative branches.

---

## Godot Scene and Resource Rules

Godot scenes and resources are source-controlled project files.

- `.tscn` and `.tres` may be edited directly for simple, well-understood changes.
- Do not rewrite large scene/resource files unnecessarily.
- Preserve relied-on node paths unless the task explicitly includes a migration.
- Check broken references after moving or renaming assets.
- Prefer inspectable text changes over opaque automation.
- Do not assume a tool operation succeeded solely because it returned success.

For visually complex authored scenes, human editor work may be preferable.

---

## Subjective vs. Objective Evaluation

Claude may validate objective behavior such as:

- state transitions
- gold totals
- interaction rules
- damage calculations
- scene loading
- save/load state
- broken references
- regression conditions

Human review is required for:

- movement feel
- combat feel
- camera comfort
- animation quality
- visual readability
- level pacing
- exploration quality
- difficulty and balance
- humor and dialogue
- narrative/emotional impact
- art direction

Never substitute automated checks for human playtesting.

---

## Dependencies and Tools

Do not add or configure without explicit approval:

- Godot addons
- MCP integrations
- external libraries
- SDKs
- native extensions
- cloud services
- package managers

Do not make experimental AI tooling a production dependency.

The initial GoldKing workflow is external-agent-first.

Godot MCP/editor automation should only be introduced if a repeated workflow problem justifies it.

---

## Git Safety

Claude may inspect Git state freely.

Safe default read-only commands include:

```text
git status
git diff
git log
git branch
```

Do not perform destructive or publishing actions without explicit approval.

Do not:

- force-push
- rewrite history
- delete branches/tags
- run destructive reset/clean operations
- push directly to `main`
- publish builds
- deploy releases
- expose credentials
- modify files outside the repository

Keep changes scoped to the current task.

---

## Documentation Rules

Do not update design documents merely because code was implemented.

Update documentation only when the relevant condition is met:

### `docs/GOLDKING_CONTEXT.md`
Only for explicitly approved narrative/world canon changes.

### `docs/GOLDKING_GAMEPLAY_FOUNDATION.md`
For current approved gameplay/design foundation.

### `docs/GOLDKING_DECISION_LOG.md`
For approved, deferred, rejected, or otherwise formalized decisions.

### `docs/GOLDKING_PROTOTYPE_LOG.md`
For prototype evidence and findings.

### `docs/ARCHITECTURE.md`
For architecture that actually exists.

### `AGENTS.md`
For durable repository-wide working rules.

### `CLAUDE.md`
For Claude-specific operating guidance.

Avoid duplicating the same information across several files.

---

## Current Development Priority

GoldKing is entering playable prototyping.

The current prototype sequence begins with:

1. Player Movement & Controlled Camera
2. Gold Collection
3. Gold Power vs. Burden
4. Gold Spill & Theft
5. Mini Expedition / Extraction

Do not jump ahead and implement later prototype systems unless explicitly requested.

The immediate goal is to learn, not to complete the full game.

---

## Final Working Principle

> Chats are the workshop.  
> Project documents are the memory.  
> Playable prototypes are the evidence.

Build the smallest thing that lets the team learn the next important truth about GoldKing.
