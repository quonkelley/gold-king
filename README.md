# GoldKing

GoldKing is an independent folklore- and mythology-inspired action-adventure game being developed by Quon and Jason.

The game follows the **Gold King**, a charismatic, good-hearted, deeply flawed ruler whose obsession with gold caused him to neglect his kingdom. After being overthrown and cast out, he begins again with nothing.

The long-term goal is to reclaim what he lost — but the deeper question is whether regaining a kingdom and becoming worthy of ruling it are the same thing.

> **Current stage:** Early prototype / pre-production transition

---

## Project Direction

GoldKing is currently being developed around these approved directions:

- **Engine:** Godot 4.7.2 stable
- **Language:** Typed GDScript
- **Presentation:** 2.5D top-down
- **Environment:** 3D world geometry and environments
- **Characters:** Stylized 2D characters inside the 3D world
- **Camera:** Controlled top-down/elevated gameplay camera
- **World structure:** Persistent hybrid world with continuous explorable zones
- **Progression:** Expedition and settlement loops
- **Design priority:** Exploration, gold collection, risk/reward, mythology, character growth, and a strong sense of rebuilding from exile
- **Prototype philosophy:** Prove mechanics with small playable tests before committing to large systems

GoldKing should feel like an adventure through a real mythic world that uses roguelite-inspired systems — not like a randomized dungeon generator with story layered on top.

---

## Core Creative Pillars

Current project pillars include:

### Gold as Power and Burden
Gold should be more than currency. It is intended to function as power, temptation, status, risk, and a reflection of the Gold King's internal struggle.

### The Rise After the Fall
The player begins humiliated, stripped of power, and outside the kingdom he once ruled. Progress should feel like rebuilding a fallen legend from nothing.

### Worth Versus Wealth
The game explores the difference between price and value, possessing power and deserving it, and gaining loyalty versus purchasing influence.

### Redemption Through Action
Reclaiming the throne should not automatically mean the Gold King has redeemed himself.

### Myth Reimagined
Folklore, mythology, cursed treasures, strange bargains, legendary creatures, ancient places, and Midas-inspired ideas form a major part of the game's creative foundation.

---

## Current Development Goal

The immediate goal is **not** to build the full game.

The current goal is to create a sequence of small prototypes that answer important design questions.

The first planned prototypes are:

1. **Player Movement & Controlled Camera**  
   Test whether the chosen 2.5D presentation produces intuitive and readable movement.

2. **Gold Collection**  
   Test whether collecting gold is immediately satisfying and readable.

3. **Gold Power vs. Burden**  
   Test whether increasing wealth can simultaneously make the player feel stronger and more endangered.

4. **Gold Spill & Theft**  
   Test whether losing and recovering gold during combat creates enjoyable urgency.

5. **Mini Expedition / Extraction**  
   Test the first small version of the expedition loop: exploration, accumulation, temptation, risk, and returning home with the haul.

See [`docs/GOLDKING_PROTOTYPE_LOG.md`](docs/GOLDKING_PROTOTYPE_LOG.md) for the current test plan and findings.

---

## Documentation

GoldKing uses a small set of authoritative documents instead of one giant game-design bible.

### Narrative and World Canon

[`docs/GOLDKING_CONTEXT.md`](docs/GOLDKING_CONTEXT.md)

Defines:

- Established narrative canon
- The Gold King's character
- Core premise
- Themes
- Tone
- Story guardrails
- Major narrative questions

This is the authority for **Established Canon**.

### Gameplay Foundation

[`docs/GOLDKING_GAMEPLAY_FOUNDATION.md`](docs/GOLDKING_GAMEPLAY_FOUNDATION.md)

Defines the current approved gameplay and presentation foundation, including:

- 2.5D presentation
- Level/world philosophy
- Expedition structure
- Settlement direction
- Loot philosophy
- Prototype implications

### Decision Log

[`docs/GOLDKING_DECISION_LOG.md`](docs/GOLDKING_DECISION_LOG.md)

Records important decisions and their status:

- Approved Direction
- Prototype Assumption
- Deferred
- Rejected
- Open Question

Use this file to understand **what was decided and why**.

### Prototype Log

[`docs/GOLDKING_PROTOTYPE_LOG.md`](docs/GOLDKING_PROTOTYPE_LOG.md)

Records:

- Prototype hypotheses
- Test setup
- Success/failure signals
- Observations
- Playtest findings
- Conclusions
- Follow-up experiments

Playable evidence should be used to challenge assumptions when necessary.

### AI / Coding Agent Instructions

[`AGENTS.md`](AGENTS.md)

Contains repository-level instructions for AI coding agents, including:

- Development workflow
- Typed GDScript expectations
- Scope discipline
- Git safety
- Testing expectations
- Documentation ownership
- Rules against inventing canon or speculative architecture

Any coding agent working in this repository should read `AGENTS.md` before making substantial changes.

---

## Development Workflow

GoldKing follows a small, evidence-driven implementation loop:

```text
Human defines intent
        ↓
Feature specification + acceptance criteria
        ↓
Inspect existing project
        ↓
Implement the smallest useful change
        ↓
Mechanical validation / tests
        ↓
Human playtest and visual review
        ↓
Review code and results
        ↓
Commit
        ↓
Record important findings
```

For gameplay work:

> **Automate correctness. Judge feel by playing.**

AI tools may assist with implementation, testing, debugging, tooling, documentation, and repetitive work, but human developers retain ownership of:

- Game identity
- Story and character
- Combat feel
- Level composition
- Art direction
- Major architecture decisions
- Final creative judgment

---

## Repository Structure

Expected early repository structure:

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

The structure will evolve as the project develops.

Do not create systems, folders, or abstraction layers solely to make the repository look more complete.

---

## Getting Started

### Requirements

For the initial prototype workflow:

- **Godot 4.7.2 stable**
- Git
- A code editor or IDE of choice
- Optional external AI coding agent

Additional dependencies should not be added without a clear project need.

### Open the Project

Once the Godot project exists:

1. Clone or open the GoldKing repository.
2. Launch Godot 4.7.2.
3. Import/open the repository's `project.godot`.
4. Run the current prototype scene from the Godot editor.

Exact run, test, and command-line validation instructions will be added once the first Godot project and test tooling are initialized.

Do not invent undocumented setup commands.

---

## Feature Development

Before implementing a non-trivial feature, check for a specification under:

```text
docs/features/
```

Feature specifications should be small and focused.

A typical spec should include:

- Objective
- Approved constraints
- Acceptance criteria
- Human evaluation questions
- Explicit out-of-scope items

Prototype code is allowed to be temporary.

The goal of early development is to learn what GoldKing should become, not to prematurely build permanent architecture.

---

## Contributing

GoldKing is currently a small private-team project.

Before making significant changes:

1. Read [`AGENTS.md`](AGENTS.md).
2. Read only the project documentation relevant to the task.
3. Check the Decision Log before changing an established direction.
4. Use a focused branch/worktree for non-trivial changes.
5. Keep changes small and reviewable.
6. Do not introduce new dependencies without approval.
7. Do not invent unresolved game canon.
8. Record meaningful prototype findings instead of relying on memory.

More formal contribution guidelines can be added later if the team or repository expands.

---

## Current Non-Goals

GoldKing is **not currently trying to become**:

- A traditional city builder
- A settlement-maintenance simulator
- A tile-based world-navigation game
- A room-by-room Isaac-style dungeon crawler
- A generic crafting-resource game
- A fully procedurally generated world
- An autonomous AI-built game

These boundaries may only change through explicit design decisions or prototype evidence.

---

## Project Principle

> **Chats are the workshop.**  
> **Project documents are the memory.**  
> **Playable prototypes are the evidence.**

Build the smallest thing that lets the team learn the next important truth about GoldKing.
