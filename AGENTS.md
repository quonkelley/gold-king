# AGENTS.md — GoldKing Repository Instructions

## Purpose

This file provides durable, repository-level guidance for AI coding agents working on **GoldKing**.

Keep this file concise and operational. Do not turn it into a duplicate game design document. Detailed canon, gameplay direction, decisions, and prototype findings live in `/docs`.

When instructions conflict, follow this priority:

1. Direct instructions from Quon or Jason in the current task.
2. This `AGENTS.md`.
3. Relevant authoritative project documents in `/docs`.
4. Existing code and established project conventions.
5. Agent assumptions.

Do not silently invent missing requirements.

---

## Project Snapshot

**Project:** GoldKing  
**Engine:** Godot 4.7.2 stable  
**Language:** Typed GDScript  
**Development stage:** Early prototype / pre-production transition  
**Team size:** Small independent team  
**Primary presentation:** 2.5D top-down; 3D environments with 2D characters  
**Camera:** Controlled top-down/elevated gameplay camera  
**Current priority:** Prove the core gameplay through small playable prototypes before expanding scope.

GoldKing is a folklore- and mythology-inspired game about a good-hearted but deeply flawed king whose obsession with gold caused him to neglect his kingdom. Gold is intended to function as more than currency: it is tied to power, burden, temptation, progression, and the game's themes.

Do not invent new canon, story facts, characters, powers, factions, endings, or world rules unless the current task explicitly asks for creative exploration.

---

## Authoritative Project Documents

Read only the documents relevant to the task. Do **not** load every project document before every small edit.

### Narrative, world, character, tone, or lore work
Read:

`docs/GOLDKING_CONTEXT.md`

This is the authority for **Established Canon**.

### Gameplay, presentation, level structure, world structure, or progression work
Read:

`docs/GOLDKING_GAMEPLAY_FOUNDATION.md`

### Whether something has been approved, deferred, rejected, or remains experimental
Read:

`docs/GOLDKING_DECISION_LOG.md`

### Prototype conclusions and playtest evidence
Read:

`docs/GOLDKING_PROTOTYPE_LOG.md`

Once this file contains findings, prototype evidence should take priority over assumptions made during brainstorming.

### Feature implementation
If a relevant specification exists, read:

`docs/features/<feature>.md`

Implement the approved feature specification rather than expanding the feature from inference.

### Architecture
If `docs/ARCHITECTURE.md` exists, consult it for established ownership boundaries and system relationships.

Do not create architectural rules merely because this file does not yet exist.

---

## Decision Status Rules

Project information may be labeled as:

- **Established Canon** — finalized narrative/world information.
- **Approved Direction** — agreed design or production direction.
- **Prototype Assumption** — deliberately implemented to test.
- **Strong Recommendation** — recommended but not approved.
- **Experimental Idea** — speculative exploration.
- **Open Question** — unresolved.
- **Deferred** — intentionally postponed.
- **Rejected** — intentionally not pursued.

Never promote an Open Question, Strong Recommendation, Experimental Idea, or Prototype Assumption into Approved Direction or Established Canon on your own.

If an implementation requires deciding an unresolved design question, stop at the smallest reasonable implementation and explicitly identify the unresolved choice.

---

## Core Development Philosophy

GoldKing is a small-team game. Optimize for **learning, clarity, and iteration**, not speculative scale.

During prototyping:

- Prefer the smallest implementation that answers the current design question.
- Use placeholders freely.
- Do not polish systems whose underlying design has not been validated.
- Do not build generalized frameworks for hypothetical future features.
- Prefer deleting failed experiments over preserving them through unnecessary abstraction.
- Keep tuning values easy to change.
- Separate objective correctness from subjective game feel.
- Treat human playtesting as mandatory for gameplay conclusions.

A feature working technically does **not** prove that it feels good.

Never report subjective claims such as "movement feels great," "combat is balanced," or "the level is fun" based only on code or automated tests.

---

## Required Workflow for Code Changes

For non-trivial implementation tasks:

1. **Inspect before editing.**
   - Read the relevant existing scenes/scripts.
   - Identify which system currently owns the behavior.
   - Check the relevant project docs.

2. **Propose the minimum change.**
   - State which files need modification.
   - Avoid unrelated cleanup.
   - Do not introduce new architecture unless the task requires it.

3. **Use acceptance criteria.**
   - Follow the current feature specification when one exists.
   - If no written criteria exist, infer only objective criteria necessary to complete the requested task.

4. **Implement narrowly.**
   - Keep diffs small and reviewable.
   - Do not add adjacent features "while you are here."

5. **Validate mechanically.**
   - Run the smallest relevant validation/tests.
   - Check Godot parser/runtime errors when possible.
   - Report exactly what was tested.

6. **Leave subjective evaluation to humans.**
   - Identify what still needs human play, visual, audio, or narrative review.

7. **Summarize the change.**
   - Files changed.
   - Behavior added/changed.
   - Tests/checks run.
   - Known limitations.
   - Relevant open questions.

---

## GDScript Rules

Use **typed GDScript** for production and prototype gameplay code unless the task explicitly requires otherwise.

Prefer:

```gdscript
var carried_gold: int = 0
var move_speed: float = 6.0

func add_gold(amount: int) -> void:
    carried_gold += amount
```

Avoid unnecessary dynamic typing when the type is known.

General rules:

- Prefer clear code over clever code.
- Favor composition and normal Godot scene/node patterns over custom framework layers.
- Keep functions focused.
- Use descriptive names.
- Avoid global state unless there is a clear project-level ownership reason.
- Do not introduce autoload singletons casually.
- Do not add an event bus, service locator, dependency-injection framework, gameplay-tag framework, or custom state-machine framework unless an approved feature actually needs it.
- Prefer Godot-native APIs and patterns before adding third-party dependencies.
- Keep frequently tuned gameplay values exported or otherwise data-driven when practical.
- Comments should explain **why**, not narrate obvious code.
- Remove dead code rather than leaving speculative code paths.

---

## Godot Scene and Resource Rules

Godot scenes and resources are part of the codebase and must be treated as reviewable source.

- `.tscn` and `.tres` files may be edited directly when the change is simple and the serialized structure is understood.
- For visually complex authored scenes, prefer human editor work or a clearly validated tool workflow.
- Do not rewrite large scene/resource files unnecessarily.
- Preserve node names and paths relied on by scripts unless the task explicitly includes a migration.
- Check for broken resource paths after moving or renaming assets.
- Do not assume an editor/MCP operation succeeded merely because a tool returned success.
- Prefer direct, inspectable changes over opaque automation.

---

## Testing and Validation

Automate what can be judged objectively.

Good automation targets include:

- State transitions
- Gold totals and transfers
- Interaction range/rules
- Damage calculations
- Save/load state
- Inventory/treasure rules
- Scene/resource loading
- Broken references
- Regression bugs
- Data validation

Human review is required for:

- Movement feel
- Combat feel
- Camera comfort
- Animation quality
- Visual readability
- Level pacing
- Exploration quality
- Difficulty/balance
- Humor and dialogue
- Narrative/emotional impact
- Art direction

When tests exist for modified behavior, run the relevant tests.

If tests do not yet exist, do not create a giant test framework just to satisfy a tiny prototype task. Add focused regression coverage when the behavior is stable enough to benefit from it.

### CLI validation

Godot should be callable from the repository environment when practical.

**Target version:** Godot 4.7.2 stable.

**Verified executable (Quon's macOS environment):**

```bash
/Applications/Godot.app/Contents/MacOS/Godot --version
```

Godot is not on `PATH` in that environment. Use the full path.

Check the reported version before implementation work. If it does not report 4.7.2, report the mismatch rather than changing the documented target. As of 2026-11-12 the local install reports `4.7.1.stable.official.a13da4feb`, so an upgrade is required before P001 implementation.

Project-specific headless validation and test commands will be added here once P001 and the testing workflow exist. No headless project checks or tests exist yet.

Until then, do not invent commands or claim validation was performed when it was not.

---

## Scope and Feature Discipline

Before adding a system, ask:

- Does this answer the current prototype question?
- Does GoldKing need this now?
- Is there a simpler implementation?
- Are we duplicating an existing system?
- Is this production architecture being added before the design is proven?

Do not expand GoldKing into adjacent genres accidentally.

In particular, current approved direction explicitly avoids:

- A traditional city-builder/maintenance game.
- A For-the-King-style tile-based world map.
- Isaac-style isolated combat rooms as the primary level format.
- A generic bulk crafting-resource economy.
- Procedural generation as a requirement for the first prototype.

Consult the Decision Log before changing these boundaries.

---

## AI-Specific Guardrails

AI is an implementation and analysis tool, not the owner of GoldKing's identity.

Human-owned decisions include:

- Game pillars
- Gold King's characterization
- Story themes
- Major narrative decisions
- Final art direction
- Combat feel
- Level composition and exploration rhythm
- Progression philosophy
- Major architecture approval

Agents may:

- Implement a bounded approved feature.
- Suggest alternatives.
- Generate tests.
- Diagnose errors.
- Create tooling.
- Perform repetitive refactors.
- Update documentation to reflect decisions already made.

Agents must not:

- Invent canon to make implementation easier.
- Turn a prototype assumption into a permanent system.
- Add features outside scope without being asked.
- Hide uncertainty behind confident language.
- Make unrelated refactors during a scoped task.
- Replace human playtesting with automated assertions.
- Treat generated art, dialogue, music, or level layouts as final creative direction without human approval.

If repeated agent mistakes reveal a missing repository rule, recommend updating this file.

Do not add large amounts of defensive instruction preemptively.

---

## Dependencies and Plugins

Do not add:

- Godot addons
- MCP integrations
- External libraries
- Native extensions
- Package managers
- SDKs
- Cloud services

without explicit approval.

For experimental tooling:

- Keep it isolated from core game logic.
- Prefer version-pinned dependencies.
- Ensure the project can still function without the experimental AI integration unless explicitly approved otherwise.

---

## Git and Change Safety

- Work on the task's current branch/worktree.
- Do not push directly to `main`.
- Do not rewrite Git history.
- Do not force-push.
- Do not delete branches or tags without explicit instruction.
- Do not commit secrets, API keys, credentials, or local-machine paths.
- Do not modify unrelated files.
- Keep commits focused when asked to commit.
- Never publish, deploy, release, or upload a build without explicit human instruction.

Before destructive filesystem or Git operations, require explicit approval.

---

## Documentation Updates

Do not update design documents merely because code was implemented.

Update documentation when:

- Quon or Jason approves a design decision.
- A prototype produces a meaningful finding.
- Existing architecture has materially changed.
- A feature specification has changed.
- A repeated workflow problem justifies a new agent instruction.

Use:

- `GOLDKING_DECISION_LOG.md` for approved/deferred/rejected decisions.
- `GOLDKING_PROTOTYPE_LOG.md` for prototype evidence.
- `GOLDKING_CONTEXT.md` only for established narrative/world canon.
- `GOLDKING_GAMEPLAY_FOUNDATION.md` for current gameplay/design foundation.
- `ARCHITECTURE.md` for architecture that actually exists.

Do not duplicate the same information across several files unless there is a clear reason.

---

## Repository Structure

Expected early structure:

```text
GoldKing/
├── AGENTS.md
├── README.md
├── project.godot
├── docs/
│   ├── GOLDKING_CONTEXT.md
│   ├── GOLDKING_GAMEPLAY_FOUNDATION.md
│   ├── GOLDKING_DECISION_LOG.md
│   ├── GOLDKING_PROTOTYPE_LOG.md
│   └── features/
├── game/
├── assets/
├── tests/
└── tools/
```

This structure may evolve. Do not create empty architecture solely to make the repository match this example.

---

## Final Working Principle

> Chats are the workshop.  
> Project documents are the memory.  
> Playable prototypes are the evidence.

Build the smallest thing that lets the team learn the next important truth about GoldKing.
