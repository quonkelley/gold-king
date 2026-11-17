# GoldKing — Decision Log

**Status:** Active  
**Version:** 0.1  
**Created:** November 11, 2026

## Purpose

This document records important GoldKing design and production decisions, including why they were made, what previous ideas they affect, and what remains unresolved.

This document does **not** replace:

- `GOLDKING_CONTEXT.md` — Established Canon and narrative foundation
- `GOLDKING_GAMEPLAY_FOUNDATION.md` — Current gameplay/design foundation
- `GOLDKING_PROTOTYPE_LOG.md` — Evidence and findings from playable prototypes

The decision log exists primarily to answer:

> **What did we decide, why did we decide it, and is that decision still active?**

---

# Status Definitions

### Established Canon
Finalized narrative or world information treated as current project truth.

### Approved Direction
A design or production choice Quon or Jason has agreed to move forward with.

Approved Direction does not mean permanent. Prototype findings may justify revisiting it.

### Prototype Assumption
A mechanic or implementation intentionally being built to test an idea.

It should not be treated as finalized design until supported by playtesting.

### Strong Recommendation
A recommended direction that has not yet been approved.

### Open Question
Important issue that remains unresolved.

### Deferred
A decision intentionally postponed until the project has enough information to make it intelligently.

### Rejected
An idea that was considered and intentionally not pursued.

---

# Approved Decisions

## 2026-11-11 — 2.5D Top-Down Presentation

**Category:** Visual Direction / Gameplay Presentation

**Decision:**  
GoldKing will use a **2.5D top-down presentation with 3D environments and 2D characters**.

The terrain, structures, props, and level geometry will exist in 3D space. Primary characters and enemies will use stylized 2D artwork and animation inside that environment.

**Status:** Approved Direction

**Reasoning:**  
This approach preserves environmental depth, elevation, exploration, physical treasure, and strong visual composition while allowing expressive 2D character art.

It also avoids the larger production burden associated with creating, rigging, and animating the entire character cast in full 3D.

**Existing Decisions Affected:**  
Resolves the earlier exploration of pure 2D, full 3D, and hybrid presentation approaches.

**Questions Still Open:**

- Exact sprite/billboard implementation
- Character animation workflow
- Final rendering style
- Lighting and shadows for 2D characters
- Final proportions and visual style

---

## 2026-11-11 — Controlled Gameplay Camera

**Category:** Camera / Presentation

**Decision:**  
Normal gameplay will use a **controlled top-down/elevated camera** rather than free player-controlled camera rotation.

The camera may still pan, zoom, shift, or temporarily change framing for authored moments such as bosses, conversations, entrances, landmarks, and cinematics.

**Status:** Approved Direction

**Reasoning:**  
A controlled camera improves:

- Combat readability
- Gold and treasure readability
- Environmental composition
- Secret placement
- Level-design predictability
- Production scope

It also allows levels to be designed specifically around what the player can see.

**Existing Decisions Affected:**  
Supports the 2.5D presentation decision.

**Questions Still Open:**

- Perspective vs. orthographic projection
- Exact camera angle
- Exact camera distance
- Follow behavior
- Boss framing
- Conversation framing

---

## 2026-11-11 — Hybrid Persistent World Structure

**Category:** World Structure / Exploration

**Decision:**  
GoldKing will use a **hybrid persistent-world structure** rather than a giant seamless open world or a board/tile-based travel system.

The wider world should have recognizable geography containing regions, roads, settlements, ruins, mythological locations, the Gold King's former kingdom, and expedition destinations.

GoldKing will **not** use a `For the King`-style tile map as its primary navigation system.

**Status:** Approved Direction

**Reasoning:**  
The hybrid structure supports exploration and a believable world without requiring the small development team to create a massive seamless open world.

It also leaves room for roguelite systems without requiring the world itself to become a randomized dungeon.

**Existing Decisions Affected:**  
Rejects the previously discussed tile/board-based travel approach.

**Questions Still Open:**

- World-map presentation
- Destination selection
- Playable travel
- Fast travel
- Region scale
- How expeditions connect to the larger geography

---

## 2026-11-11 — Continuous, Open-Feeling Zones

**Category:** Level Design / Exploration

**Decision:**  
Explorable areas and expeditions should generally use **continuous connected spaces** rather than functioning primarily as sequences of isolated combat rooms.

Outdoor locations should feel genuinely open.

Interior locations may naturally become tighter, more structured, or more room-oriented where appropriate.

**Status:** Approved Direction

**Reasoning:**  
GoldKing should support:

- Exploration
- Hidden paths
- Secrets
- Easter eggs
- Mythology
- Environmental storytelling
- Optional encounters
- Landmarks
- Discovery

The world should feel like a place being explored rather than a collection of combat arenas connected by doors.

**Existing Decisions Affected:**  
Differentiates GoldKing structurally from games such as `The Binding of Isaac` and `Enter the Gungeon`.

**Questions Still Open:**

- Typical zone size
- Interior/exterior transitions
- Navigation systems
- Map UI
- Frequency of locked combat encounters
- How large individual expeditions should become

---

## 2026-11-11 — Roguelite Features Without Requiring Traditional Roguelite Level Structure

**Category:** Game Structure / Replayability

**Decision:**  
GoldKing can use **roguelite-inspired expedition, failure, risk/reward, and persistent-progression systems** while preserving authored exploration and a geographically coherent world.

The game does not need to imitate traditional randomized room-based roguelites.

**Status:** Approved Direction

**Reasoning:**  
This allows GoldKing to combine the replayability and progression strengths of roguelites with a stronger sense of world, adventure, discovery, and story.

**Existing Decisions Affected:**  
Clarifies the earlier idea of GoldKing becoming a roguelite.

**Questions Still Open:**

- How strongly the final game identifies as a roguelite
- Run length
- Temporary run upgrades
- Build crafting
- Reset rules
- Replay structure
- Degree of randomization

---

## 2026-11-11 — Persistent Settlement Without City-Builder Maintenance

**Category:** Progression / Settlement / Scope

**Decision:**  
After exile, the Gold King begins from a small makeshift camp near the kingdom he once ruled.

This location will function as a **persistent settlement, story, and progression hub**.

The settlement may visibly grow as the player progresses, but GoldKing will **not** become a traditional city-building or settlement-maintenance game.

The player should not routinely manage:

- Worker assignments
- Hunger
- Production chains
- Daily chores
- Building placement
- Resource queues
- Constant base defense
- NPC maintenance

**Status:** Approved Direction

**Reasoning:**  
Settlement growth can visually communicate the Gold King's rise from exile while supporting progression and story.

Deep management systems would compete with the core adventure fantasy and dramatically increase scope.

**Existing Decisions Affected:**  
Refines the original settlement-development concept.

**Questions Still Open:**

- Settlement progression stages
- Available structures
- Exact investment mechanics
- How much growth happens automatically
- Whether the settlement eventually becomes a town, stronghold, city, or kingdom

---

## 2026-11-11 — Expedition and Settlement Gameplay Loops

**Category:** Core Game Structure

**Decision:**  
GoldKing will currently be designed around two complementary gameplay phases.

### Expedition Loop

**Explore → Fight → Discover → Collect Gold/Treasure → Grow Stronger and More Burdened → Decide Whether to Push Further → Return or Fail**

### Settlement Loop

**Return → Secure Haul → See Changes → Interact With Characters → Invest/Unlock → Prepare → Choose Next Destination → Depart**

The settlement should provide a lower-pressure contrast to expeditions without becoming a chore-driven management game.

**Status:** Approved Direction

**Status Note (2026-11-12):** The two-phase structure is approved. The "Grow Stronger and More Burdened" and "Return or Fail" steps depend on the Prototype Assumptions *Gold Power vs. Burden* and *Losing Unsecured Gold and Treasure* below, and are not finalized mechanics.

**Status Note (2026-11-14):** Per *Gold Power With Wealth-Driven External Danger* (above), "More Burdened" now means greater exposure to external danger, attention, and vulnerability, not an automatic movement penalty from ordinary gold. The loop structure itself is unchanged.

**Reasoning:**  
The two loops can continuously feed one another.

Expeditions create discoveries, wealth, characters, and progression opportunities that make returning home exciting.

Settlement progression creates new abilities, opportunities, goals, and story developments that make the player want to leave again.

Games such as `Dave the Diver` and `Cult of the Lamb` are structural references for this complementary-loop philosophy, not templates to copy mechanically.

**Existing Decisions Affected:**  
Provides the current macro gameplay structure.

**Questions Still Open:**

- Typical length of each phase
- Exact return sequence
- Expedition selection
- Preparation systems
- Character progression
- Settlement investment options

---

## 2026-11-11 — Focused Expedition Loot Philosophy

**Category:** Loot / Economy / Scope

**Decision:**  
GoldKing should avoid a large generic crafting-resource economy.

The primary things brought back from expeditions should be:

### Gold

The central common form of wealth and a major gameplay resource.

### Treasure

Valuable and interesting discoveries that may contribute to wealth, collecting, display, decisions, or special interactions.

### Special Items / Relics

Items that matter because they contribute to things such as:

- Story
- Powers
- Abilities
- Characters
- Mythology
- Exploration
- World access
- Permanent progression

Generic bulk inventories of materials such as wood, stone, leather, herbs, and ore should only be introduced if a future mechanic provides a compelling reason for them.

**Status:** Approved Direction

**Reasoning:**  
A focused loot economy reinforces GoldKing's identity and avoids unnecessary crafting and inventory complexity.

**Existing Decisions Affected:**  
Narrows the earlier resource-management concept for the settlement.

**Questions Still Open:**

- Treasure selling
- Treasure collecting/display
- Relic categories
- Equipment loot
- Treasury mechanics
- Whether large treasures physically burden the player

## 2026-11-14 — Gold Power With Wealth-Driven External Danger

**Category:** Core Gameplay / Gold Systems / Risk and Reward

**Decision:**  
Accumulating ordinary gold should remain highly desirable and contribute to the Gold King's increasing power.

Greater accumulated wealth should also create the potential for greater external danger, attention, and vulnerability.

Automatic movement-speed penalties from accumulating ordinary gold are no longer the intended core downside.

**Status:** Approved Direction (approved by Quon, 2026-11-14, after reviewing P003)

**Reasoning:**  
P003 showed that speed penalties can create an enjoyable short-session trade-off, but raised concerns about long-expedition pacing, gold desirability, and encounter design.

Wealth-driven external danger provides another way to reinforce greed and temptation without making ordinary gold collection automatically impair traversal.

**Existing Decisions Affected:**
- Supersedes the automatic gold-based physical-burden part of the *Gold Power vs. Burden* Prototype Assumption below. That assumption is kept as historical evidence, not deleted.
- Supersedes the matching physical-burden wording in `GOLDKING_GAMEPLAY_FOUNDATION.md` §5 and §7.
- Clarifies the "Grow Stronger and More Burdened" step of the Expedition Loop (see its status note).
- Gold spill and theft remain Prototype Assumptions for P004.
- Narrative canon is unchanged.

**Evidence:** `GOLDKING_PROTOTYPE_LOG.md`, P003 (Playtests 1 and 2; outcome Iterate).

**Questions Still Open:**

- Exact gold power scaling
- Which enemies respond to accumulated wealth
- Whether thieves become more frequent or more aggressive
- How external threats escalate
- How threat escalation is communicated
- Whether environmental or mythological entities react to wealth
- How players mitigate or respond to threats
- Whether an optional gold-powered heavy form exists
- Whether large treasures or equipment create separate encumbrance

The optional gold-powered heavy form and treasure/equipment encumbrance are **Experimental Ideas**, not approved systems. This decision does not define a dynamic-difficulty director, enemy-spawning formula, or threat meter.

---

## 2026-11-15 — Light, Primarily Automated Settlement Progression

**Category:** Settlement Progression / Scope

**Decision:**  
GoldKing's current settlement direction remains light, primarily automated, and focused on supporting the expedition-action experience. Growth should visibly reflect the King's accomplishments without requiring routine construction or settlement maintenance.

**Status:** Approved Direction (reaffirmed by Quon, 2026-11-15)

**Reasoning:**  
The settlement should feel increasingly alive, impressive, personal, and functional while preserving adventure, exploration, and action as central gameplay activities.

**Existing Decisions Affected:**  
Clarifies and reaffirms *Persistent Settlement Without City-Builder Maintenance* (2026-11-11). Does not overturn the rejection of traditional city-builder maintenance. Details are in `GOLDKING_GAMEPLAY_FOUNDATION.md` §6.

Settlement characters/followers and specialist services are recorded there as **Experimental Ideas**; reputation, influence, and legendary status are **Open Questions**. Neither is approved by this decision.

**Questions Still Open:**

- Exact structures
- Followers
- Specialist services
- Progression stages
- Optional customization
- Whether greater management depth becomes desirable later

---

## 2026-11-15 — Immediate Prototype Priority: Extraction Rewards (P006)

**Category:** Production Priority / Prototype Sequencing

**Decision:**  
The next prototype investigation (P006) focuses on extraction rewards, before combat implementation begins.

Research question: does giving successfully extracted gold a meaningful, persistent benefit improve:

1. Extraction satisfaction
2. Motivation to begin another expedition
3. Return-or-continue decisions

These outcomes should be evaluated separately.

**Status:** Approved Direction (production/design priority, approved by Quon, 2026-11-15). This is **not** approval of a P006 feature specification.

**Reasoning:**  
P005 (Iterate) found that extraction was understood but the secured haul did not feel rewarding enough, and replay desire was moderate. The P005 closeout recommended investigating one meaningful benefit for extracted gold before expanding expedition size, enemy variety, or progression systems.

**Existing Decisions Affected:**  
Acts on the P005 Strong Recommendation (`GOLDKING_PROTOTYPE_LOG.md`, P005 §19). Does not change P005's outcome. No other decision changes.

**Strong Recommendations / Prototype candidates (not approved):**

- A visible growing hoard
- One settlement milestone

**Subsequent priority (Strong Recommendation, not authorized):** a combat-foundation experiment after P006. Its scope and prototype number are not set. Quon's current combat preferences are recorded in `GOLDKING_GAMEPLAY_FOUNDATION.md` §9 as unresolved exploration, not Approved Direction.

**Update 2026-11-16:** This combat-foundation experiment is now **P007 — Combat Foundation**. Quon approved its scope and feature specification (`docs/features/p007_combat_foundation.md`) and authorized implementation on 2026-11-16. Its tuning and mechanics remain Prototype Assumptions; §9 of the Gameplay Foundation is unchanged.

**Update 2026-11-16 (Iteration 1):** After P007 Human Playtest 1, Quon approved **P007 Iteration 1 — Lightweight Target Focus** as a controlled experiment (spec §10). It narrows the spec's target-lock / aim-assist exclusion for that experiment only. Target focus remains an Experimental Idea; no targeting or combat direction is approved by this.

**Questions Still Open:**

- The exact reward or benefit
- Thresholds
- Number of expeditions required
- Persistence implementation
- Milestone behavior

**Update 2026-11-17:** P007 concluded with outcome Iterate, and the foundational prototype cycle (P001–P007) concluded. See the 2026-11-17 decision below and the Prototype Log.

---

## 2026-11-17 — Transition to a First Integrated Playable Experience

**Category:** Production Priority / Development Workflow

**Decision:**  
Transition from the initial standalone-prototype cycle (P001–P007, concluded 2026-11-17) toward **planning** a First Integrated Playable Experience.

**Status:** Approved Direction (approved by Quon, 2026-11-17).

**Reasoning:**  
Existing prototypes provide enough promising groundwork to begin testing exploration, combat, treasure, extraction, settlement progression, and game feel together.

**Workflow direction:**

- Prefer larger, coherent playable milestones when combining established mechanics.
- Continue using scoped prototypes for significant new uncertainties.
- Introduce focused presentation and feedback work when necessary to evaluate gameplay meaningfully.
- Do not require production-level polish for every gameplay test.
- Preserve historical evidence and avoid treating experimental implementation details as permanent architecture.
- Allow implementation latitude within approved milestone boundaries while retaining explicit review for major changes.

**Scope boundary:**  
This decision authorizes **planning** the next milestone only. It does not authorize implementation and does not approve the First Integrated Playable's content, architecture, art pipeline, or feature list. No milestone specification or prototype identifier is assigned.

**Existing Decisions Affected:**  
Concludes the incremental prototype sequencing that began with P001 (`GOLDKING_PROTOTYPE_LOG.md`, *Foundational Prototype Cycle*). Does not change any P001–P007 outcome. The Prototype Log remains available for future focused prototypes.

**Not decided by this entry (remain Prototype Assumptions or Open Questions):**

- Opponent-focused combat is a promising experimental result from P007, not an Approved Direction.
- Eight-direction facing as the final combat model; the target-focus controls and acquisition/release ranges; sword timing, arc, reach, and damage; dodge timing and invulnerability; the Training Enemy's behavior and balance; current combat indicators and placeholder visuals; the current prototype scene and script architecture.

**Questions Still Open:**

- The First Integrated Playable's scope, content, and success criteria
- Which prototype implementations are reused, rebuilt, or discarded
- How much presentation and feedback work the milestone needs to evaluate combat and game feel
- Combat targeting model for multiple enemies

---

# Deferred Decisions

## 2026-11-11 — Procedural Generation

**Category:** Replayability / Level Generation

**Decision:**  
Do **not** commit GoldKing to procedural level generation yet.

Initial prototypes and early zones should be **hand-authored**.

**Status:** Deferred

**Reasoning:**  
The project needs to first discover what makes a good GoldKing environment.

Authored exploration currently better supports:

- Recognizable geography
- Secrets
- Environmental storytelling
- Mythology
- Easter eggs
- Meaningful landmarks
- World continuity

Procedural or systemic variation can be reconsidered later if repeated expeditions require additional variation.

**Possible Future Direction:**

> **Authored macro-world, variable micro-content.**

Possible variable elements could eventually include:

- Enemy groups
- Treasure placement
- Rare encounters
- Elite enemies
- Events
- Weather
- Temporary obstacles
- Small optional side locations

**Questions Still Open:**  
Whether GoldKing needs procedural generation at all.

---

# Prototype Assumptions

These ideas are important enough to test but are **not yet Approved Direction**.

## Gold Power vs. Burden

**Category:** Core Mechanic

**Status:** Prototype Assumption — **partly superseded (2026-11-14).** Kept as historical record.

**Status Note (2026-11-14):** P003 tested this assumption with automatic top-speed penalties and increased strike impact (see `GOLDKING_PROTOTYPE_LOG.md`, P003). After reviewing the results, Quon approved *Gold Power With Wealth-Driven External Danger* (Approved Decisions). Automatic physical burden from ordinary gold (reduced movement, dodge, recovery, or changed posture as a cost) is no longer the intended core downside. Gold-driven power is now part of that Approved Direction. Gold spilling when struck remains a Prototype Assumption for P004, and gold-seeking enemies fall under the new direction's open questions. The original text below is unchanged.

**Assumption:**  
Carrying more gold makes the Gold King increasingly powerful while simultaneously increasing physical burden and vulnerability.

Possible effects include:

- Increased damage
- Stronger gold abilities
- Reduced movement
- Reduced dodge effectiveness
- Longer recovery
- Changed posture
- Visible accumulation of wealth
- Gold spilling when struck
- Increased attention from gold-seeking enemies

**Prototype Question:**

> Can becoming richer feel increasingly powerful and increasingly dangerous at the same time without making the player want to avoid gold?

---

## Losing Unsecured Gold and Treasure

**Category:** Expedition Risk / Reward

**Status:** Prototype Assumption

**Assumption:**  
Gold and ordinary treasure collected during an expedition remain unsecured until successfully returned home.

Failing the expedition causes the current unsecured haul to be lost.

Previously secured wealth and permanent progression remain safe.

**Prototype Question:**

> Does losing the entire current haul create meaningful greed and extraction tension, or does it make failure feel excessively punishing?

**Questions Still Open:**

- Unique relic behavior
- Story-item behavior
- Recovery systems
- Voluntary retreat rules
- Mid-expedition banking
- Whether some upgrades can protect portions of the haul

---

## Midas-Inspired Gilding

**Category:** Combat / Powers / Exploration

**Status:** Open Question / Future Prototype

**Idea Under Consideration:**  
The Gold King may possess Midas-inspired supernatural abilities capable of gilding enemies, objects, or parts of the environment.

**Reason for Not Approving Yet:**  
The core movement, combat, collection, and gold-burden systems should be proven first.

---

# Rejected / Intentionally Avoided Directions

## Tile-Based World Navigation

**Status:** Rejected

GoldKing will not use a `For the King`-style tile or board map as its primary world-travel system.

---

## Traditional City-Builder Settlement Gameplay

**Status:** Rejected

GoldKing will not revolve around routine worker management, resource-production chains, placement optimization, hunger systems, or constant settlement maintenance.

---

## Isaac-Style Room Structure as the Primary Level Format

**Status:** Rejected

GoldKing should not primarily consist of entering isolated rooms, locking the doors, clearing enemies, and repeating the process.

Individual encounters may still use controlled arenas when appropriate.

---

# Major Open Questions

- Final combat system
- Melee vs. ranged balance
- Exact gold power scaling
- Wealth-driven external danger: which threats respond, how they escalate, and how this is communicated (see 2026-11-14 decision)
- Gold powers
- Midas/Gilding mechanics
- Travel implementation
- World-map presentation
- Procedural/systemic variation
- Expedition length
- Build crafting
- Permanent character progression
- Exact death/failure rules
- Treasure mechanics
- Equipment structure
- Final settlement size
- Settlement characters, followers, and specialist services (Experimental Ideas; see Gameplay Foundation §6)
- Whether reputation, influence, or legendary status is communicated mechanically, and how
- Combat identity: weapons, relic combinations, defensive mechanics (current preferences in Gameplay Foundation §9)
- Combat targeting and facing: P007 found opponent-focused facing promising (Iterate, 2026-11-17); the production targeting model, multiple-enemy targeting, and directional precision are open
- Expedition milestone layers and regional variety (Experimental Ideas; see Gameplay Foundation §10)
- Whether the settlement becomes a new kingdom
- Potential old-kingdom vs. new-kingdom narrative choice
- Final visual style
- Final Gold King character design
- Mythological regions
- Major creatures and bosses

---

# Development Principle

> **Chats are the workshop. Project documents are the memory. Playable prototypes are the evidence.**

When playable evidence contradicts an assumption or approved direction, reconsider the design rather than forcing the game to conform to an old document.