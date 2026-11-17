# GoldKing — Prototype Log

**Status:** Active  
**Version:** 0.1  
**Created:** 2026-11-11  
**Purpose:** Record prototype hypotheses, test setups, observations, evidence, conclusions, and resulting design decisions for GoldKing.

This document exists to prevent prototype work from becoming undocumented experimentation.

The goal is not to preserve every implementation detail. The goal is to preserve **what we were trying to learn, what actually happened, and what changed because of it**.

---

# Working Principle

> **Chats are the workshop. Project documents are the memory. Playable prototypes are the evidence.**

Prototype findings should be treated as stronger evidence than assumptions made during brainstorming.

A prototype is successful when it answers an important design question — even if the answer is that the idea does not work.

---

# How to Use This Log

Before building a prototype:

1. Identify **one primary design question**.
2. Write the hypothesis or assumption being tested.
3. Define the smallest playable implementation capable of testing it.
4. State what is explicitly **out of scope**.
5. Define observable success/failure signals before testing.

After testing:

6. Record what actually happened.
7. Separate **observations** from **interpretations**.
8. Record notable player behavior and comments.
9. Decide whether to:
   - Promote the idea,
   - Iterate on it,
   - Reject it,
   - Defer it,
   - or mark the result Inconclusive.
10. Record the next test, if one is needed.

Do not rely on memory when evidence can be written down.

---

# Prototype Outcome Status

Use one of the following outcomes.

## Validated
The prototype produced strong enough evidence to support the tested direction.

This does **not** automatically mean the mechanic is production-ready. It means the underlying design assumption currently appears sound.

## Iterate
The core idea showed promise, but the implementation exposed problems that should be tested again.

## Rejected
The tested idea did not produce the desired player experience or created unacceptable design/scope problems.

Record why it failed so the same idea is not unknowingly reintroduced later.

## Inconclusive
The prototype did not provide enough evidence to make a decision.

Common causes:
- Too many variables changed at once.
- Prototype quality prevented a fair test.
- Testers did not encounter the relevant mechanic enough.
- The design question was too broad.
- Technical problems interfered with the test.

## Deferred
The question remains useful but is intentionally postponed until another system or design decision exists.

---

# Evidence Types

Not all evidence is equally useful. Record the source when possible.

## Direct Observation
What actually happened during play.

Examples:
- Player ignored the large gold pile.
- Player voluntarily returned to camp before the final encounter.
- Player repeatedly attempted to recover spilled coins while enemies were attacking.
- Player stopped using dodge after entering the highest gold-load state.

This is usually the most useful form of gameplay evidence.

## Measured Data
Numbers recorded during testing.

Examples:
- Time spent in expedition.
- Gold collected.
- Gold lost.
- Number of deaths.
- Number of voluntary extractions.
- Number of optional paths explored.
- Damage taken by gold tier.

Use measurements when they help answer the prototype question. Do not add telemetry simply because it is possible.

## Player Report
What the tester says they experienced.

Examples:
- “I felt too slow.”
- “I knew I should leave, but I wanted the chest.”
- “I didn't realize the enemy was stealing my coins.”

Player reports are valuable, but should be considered alongside observed behavior.

## Developer Interpretation
The team's explanation of why the observed behavior occurred.

Interpretation should be clearly separated from the observations themselves.

Example:

**Observation:** Player stopped collecting gold after entering the highest burden tier.

**Interpretation:** The highest burden tier may currently punish mobility more than its power increase rewards the player.

Do not rewrite an interpretation as if it were an observed fact.

---

# Prototype Index

| ID | Prototype | Primary Question | Status | Outcome | Date |
|---|---|---|---|---|---|
| P001 | Player Movement & Camera | Does the chosen 2.5D presentation produce intuitive, readable movement? | Complete | Validated (Medium) | 2026-11-12 |
| P002 | Gold Collection | Is collecting gold immediately satisfying and readable? | Concluded (current cycle) | Iterate (feedback polish deferred; working baseline accepted for P003) | 2026-11-13 |
| P003 | Gold Power vs. Burden | Can increasing wealth feel powerful and dangerous at the same time? | Concluded (current cycle) | Iterate (automatic movement burden superseded; wealth-driven external danger approved for future testing) | 2026-11-14 |
| P004 | Gold Spill & Theft | Can the threat of losing collected gold create exciting, readable tension without making the player regret collecting it? | Concluded (current cycle) | Iterate (promising external-threat mechanic; future expansion deferred) | 2026-11-14 |
| P005 | Mini Expedition / Extraction | Can a short expedition combining exploration, gold collection, external danger, and voluntary extraction create a satisfying loop the player wants to repeat? | Concluded (current cycle) | Iterate (promising expedition loop; extraction rewards need development) | 2026-11-15 |
| P006 | Meaningful Extraction Rewards | Does giving gold brought home from an expedition a persistent, meaningful use make extraction more satisfying and make the player want to embark on another expedition? | Concluded (current cycle) | Iterate (promising integrated expedition-to-settlement reward loop, Medium; individual elements, replay, and return-or-continue effects Low) | 2026-11-16 |

This index should remain compact. Detailed findings belong in each prototype entry below.

---

# Prototype Entry Template

Copy this section for each new prototype.

---

## PXXX — Prototype Name

**Status:** Planned / Building / Testing / Complete  
**Date Started:** YYYY-MM-DD  
**Date Concluded:** YYYY-MM-DD  
**Build / Commit:**  
**Testers:**  
**Related Decision(s):**  
**Related Feature Spec:**  

### 1. Primary Design Question

What is the **single most important question** this prototype exists to answer?

> Example: Can carrying more gold make the player feel substantially stronger while creating enough physical burden to make additional gold risky?

### 2. Hypothesis

What do we currently believe will happen?

> Example: Players will continue seeking gold even after entering a burdened state because the increased combat power remains exciting enough to justify the risk.

### 3. Why This Matters

What larger GoldKing pillar or design decision depends on this question?

Keep this short.

### 4. Prototype Scope

What is actually being built for this experiment?

- 
- 
- 

### 5. Out of Scope

What are we deliberately **not** testing?

- 
- 
- 

This is important. If something is outside the test, do not let it expand the prototype.

### 6. Variables Being Tested

What changes between conditions or iterations?

Examples:
- Gold-load thresholds.
- Damage multiplier.
- Movement speed.
- Dodge distance.
- Number of enemies.
- Treasure reward.

### 7. Controls / Things Held Constant

What should remain unchanged so the team can understand what caused the observed behavior?

Examples:
- Same arena.
- Same enemy type.
- Same base weapon.
- Same player health.

### 8. Success Signals

What observable behavior would support the hypothesis?

Use behavior where possible.

Examples:
- Player intentionally collects optional gold after entering a burden tier.
- Player notices the power increase without explanation.
- Player sometimes chooses to remain burdened instead of immediately reducing gold.

### 9. Failure Signals

What would suggest the design needs major revision or rejection?

Examples:
- Player begins avoiding gold as soon as burden is introduced.
- The optimal strategy is obviously to remain poor.
- The player cannot perceive any meaningful difference between gold states.

### 10. Optional Measurements

Only collect numbers that help answer the design question.

| Metric | Result |
|---|---|
|  |  |
|  |  |
|  |  |

### 11. Test Setup

Describe enough of the test that another team member could understand what the player experienced.

Include relevant:
- Scene/level
- Controls
- Starting state
- Important tuning values
- Number/type of encounters
- Test duration

Do not document irrelevant implementation details.

### 12. Observations

Record what actually happened.

Do not diagnose yet.

- 
- 
- 

### 13. Player Comments

Record useful comments or recurring themes.

Avoid treating one comment as universal truth.

- 
- 
- 

### 14. What Worked

- 
- 
- 

### 15. What Did Not Work

- 
- 
- 

### 16. Interpretation

What does the team currently think explains the observations?

Explicitly label uncertainty.

- 
- 
- 

### 17. Unexpected Findings

What did the prototype reveal that it was not originally designed to test?

Unexpected findings can become future prototype questions, but should not automatically expand the current prototype.

- 
- 
- 

### 18. Outcome

**Outcome:** Validated / Iterate / Rejected / Inconclusive / Deferred

**Confidence:** Low / Medium / High

**Conclusion:**

Write the shortest useful statement of what the prototype taught us.

### 19. Decision Impact

Does this finding affect an existing decision?

- No change
- Supports existing Approved Direction
- Suggests revisiting an Approved Direction
- Supports promoting a Prototype Assumption
- Rejects a Prototype Assumption
- Creates a new Open Question

If a formal project decision changes, update `GOLDKING_DECISION_LOG.md`.

### 20. Next Test

What is the **next smallest experiment** needed?

If no further prototype is necessary, write:

> None. Proceed to the next design question.

---

# Planned Prototype 001

## P001 — Player Movement & Controlled Camera

**Status:** Complete  
**Date Started:** 2026-11-12  
**Date Concluded:** 2026-11-12  
**Build / Commit:** `e91900a` (branch `feat/p001-movement-camera`)  
**Testers:** Quon  
**Related Decision(s):**
- 2.5D top-down presentation
- 3D environments + 2D characters
- Controlled gameplay camera

**Related Feature Spec:** `docs/features/p001_player_movement_camera.md`

### 1. Primary Design Question

Does GoldKing's chosen 2.5D presentation produce movement that feels intuitive, readable, and promising enough to continue developing?

### 2. Hypothesis

A 2D character moving through a 3D environment under a controlled top-down/elevated camera will preserve the readability of a top-down action game while giving GoldKing enough environmental depth to support exploration.

### 3. Why This Matters

The presentation and camera affect almost every later system:

- Combat
- Gold collection
- Exploration
- Enemy readability
- Secrets
- Level composition
- Character animation
- Environmental art

If the basic player/camera relationship does not work, later prototypes will provide misleading results.

### 4. Prototype Scope

Build only:

- One simple 3D test environment.
- One placeholder 2D Gold King character.
- Ground-plane movement.
- Collision.
- Controlled top-down/elevated camera.
- Basic facing/visual orientation sufficient for testing movement.
- Basic keyboard and gamepad movement, so the player/camera relationship can be checked with both expected input methods.

**Input (human decision, 2026-11-12):** P001 supports both keyboard and gamepad, kept deliberately minimal. Use abstract Godot input actions (`move_left`, `move_right`, `move_up`, `move_down`) rather than device checks. Initial bindings: WASD, arrow keys if trivial, and the left analog stick. This is a prototype implementation choice. It does not approve a final control scheme.

**Renderer (human decision, 2026-11-12):** The project's current Mobile renderer stays unchanged for P001. Reconsider it only if the prototype shows an actual visual, lighting, performance, or workflow problem. It is not a production renderer decision.

### 5. Out of Scope

Do **not** add:

- Combat.
- Dodge.
- Gold collection.
- Gold burden.
- Treasure.
- Midas/Gilding powers.
- Enemies.
- Dialogue.
- Final character art.
- Final animation.
- Settlement systems.
- Procedural generation.
- Input rebinding, settings UI, controller menus, dead-zone configuration UI, accessibility controls, or a final control scheme.

### 6. Variables Being Tested

Initial tuning may compare:

- Camera angle.
- Camera distance.
- Perspective vs. orthographic projection if necessary.
- Player movement speed.
- Acceleration/deceleration.
- Character visual facing behavior.

Change one major variable at a time where practical.

### 7. Controls / Things Held Constant

- Same test environment.
- Same player proxy.
- Same input scheme.
- No combat or gameplay distractions.

### 8. Success Signals

Evidence supporting the direction includes:

- Movement direction feels intuitive relative to the camera.
- The character remains visually readable against the 3D environment.
- The player can understand depth and collision boundaries.
- Exterior space feels meaningfully more dimensional than a flat 2D room.
- The camera does not require manual rotation to navigate the test space.
- The team wants to continue testing gameplay from this perspective rather than reconsider the presentation immediately.

### 9. Failure Signals

Evidence against the direction includes:

- Persistent confusion about movement directions.
- 2D character appears visually detached from the 3D ground.
- Environmental depth is difficult to read.
- Character visibility frequently fails behind geometry.
- Camera angle makes exploration or navigation feel excessively cramped.
- The presentation creates substantial technical/art problems without providing meaningful gameplay benefit.

### 10. Optional Measurements

This first test is primarily qualitative.

Potential measurements if useful:

| Metric | Result |
|---|---|
| Navigation mistakes caused by camera/depth | — |
| Times player wants to rotate camera | — |
| Visibility problems noticed | — |

### 11. Test Setup

Implemented on branch `feat/p001-movement-camera`. All values below are prototype starting defaults for tuning, not design decisions.

**Scene:** `game/prototypes/p001_movement_camera.tscn` (project main scene for P001 only). A roughly 30 × 30 m gray box built from CSG boxes with collision:
- Open southern area with three low blocks (0.6–1.0 m) and two tall pillars (4 m) for partial occlusion.
- A 4 m-deep dividing wall (2.5 m tall) with a 1.5 m-wide narrow passage into a northern area containing one tall pillar.
- 2.5 m boundary walls on three sides; the camera-side (south) boundary is 0.6 m so it does not hide the player.
- Flat colors only (floor, walls, blocks). One directional light with shadows; flat background color and ambient light. No fog, grading, or other atmosphere.

**Player:** `game/player/player.tscn` — `CharacterBody3D` (floating motion mode, no gravity) with a capsule collider (radius 0.45 m, height 1.5 m) and a `Sprite3D` placeholder.
- Sprite: temporary hand-made SVG (`placeholder_king.svg`, imported at 4× scale), Y-axis billboard, alpha-cut, unshaded, about 1.6 m tall with its bottom at the player's feet. Placeholder quality is not under test.
- Facing: left/right sprite flip only. Changes only when horizontal input exceeds 0.2; idle and pure vertical movement keep the last facing.

**Controls:** Godot input actions `move_left`, `move_right`, `move_up`, `move_down`. Keyboard: WASD (physical keys) and arrow keys. Gamepad: left analog stick. Action dead zone 0.2. Partial stick tilt gives proportionally slower movement.

**Starting tuning values** (all editable in the inspector):

| Variable | Starting value |
|---|---|
| Move speed | 5.0 m/s |
| Acceleration / deceleration | 80 / 120 m/s² (near-instant) |
| Camera projection | Perspective, FOV 45° |
| Camera pitch | 52° below horizontal |
| Camera distance | 12 m |
| Camera follow | Rigid, no smoothing, no rotation input |
| Sprite pixel size | 0.0042 m/px |
| Renderer | Mobile (unchanged) |
| Physics interpolation | Off (project default) |

**Running:** open the project in Godot 4.7.2 and press F5, or run `/Applications/Godot.app/Contents/MacOS/Godot --path .` from the repository root. Add `--debug-collisions` to view collision shapes.

### 12. Observations

Single playtest session by Quon on the `e91900a` build (starting tuning values in §11; no tuning changes were reported).

- Tester moved diagonally, in figure-eights, and with rapid direction reversals.
- Tester moved through the open area and through the narrow passage.
- Tester moved behind environment objects (partial occlusion).
- Tester changed left/right facing; the character's shadow followed the facing change correctly.
- Collision with environment objects behaved as expected; no collision problems were observed.
- No movement or camera problems were observed.
- The character has no animation. This was expected and is outside P001 scope.

Not recorded: which input device(s) were used during the session, and whether orthographic projection was compared. No measurements were collected.

### 13. Player Comments

Reported by Quon:

- Movement feels good at the current prototype stage.
- Diagonal movement, figure-eight movement, and rapid reversals feel fine.
- Movement through open and narrow areas is smooth.
- Camera distance feels good; no need for manual camera rotation was identified.
- Character size looks appropriate for now.
- Going behind objects looks good; occlusion did not create a problem.
- The hybrid 2D-character / 3D-world presentation currently feels good.
- No significant issues were found.

### 14. What Worked

- Ground-plane movement, including diagonals and quick reversals.
- Collision against the gray-box geometry, including the narrow passage.
- Controlled camera at the starting distance, without a need for rotation.
- Character readability, scale, and behavior when partially occluded.
- Shadow behavior when facing flips.

### 15. What Did Not Work

- No problems were reported.
- No character animation exists; this is out of scope for P001 and not a failure.

### 16. Interpretation

- The 2D-character / 3D-world presentation with a controlled elevated camera appears intuitive and readable enough to build on. *(Developer interpretation.)*
- Uncertainty: this is one tester, who is also a developer, in one session, in a small gray-box scene without combat, enemies, or gold. Input devices used were not recorded, so keyboard vs. controller feel is not separately evidenced. Problems may still appear once more systems or larger spaces are added.

### 17. Unexpected Findings

None reported.

### 18. Outcome

**Outcome:** Validated  
**Confidence:** Medium

**Conclusion:** The current 2D-character / 3D-world presentation, controlled elevated camera, movement, collision, and basic occlusion are sufficiently intuitive and readable to continue development. No significant problems were identified in the initial human playtest. P001 supports proceeding to P002 without additional tuning.

This validates the **direction**, not a final implementation. It does not approve final movement, final camera settings, final character scale, perspective projection as permanent, any animation solution, or a production player controller.

The P001 configuration in §11 becomes the baseline for P002 unless later evidence gives a reason to change it.

### 19. Decision Impact

- Supports existing Approved Direction: **2.5D Top-Down Presentation** (3D environments + 2D characters).
- Supports existing Approved Direction: **Controlled Gameplay Camera**.
- Neither decision needs revisiting at this time. No new design decision created.

### 20. Next Test

**P002 — Gold Collection:** test whether collecting gold is immediately readable and satisfying.

---

# Planned Prototype 002

## P002 — Gold Collection

**Status:** Concluded for the current prototype cycle. Human review was completed on 2026-11-13 and P002 was merged into `main` (merge commit `1f07e14`). Outcome: Iterate (§18). Feedback polish is deferred, and the working collection baseline is accepted for P003. P002 is not fully validated.  
**Date Started:** 2026-11-12  
**Date Concluded:** 2026-11-13  
**Build / Commit:** `d2d201c` (original setup, playtest 1); `94e86aa` (iteration 1). Branch `feat/p002-gold-collection`.  
**Testers:** Quon (playtests 1 and 2). Jason has not yet tested.  
**Related Decision(s):**
- Gold as a central, desirable resource (Approved Direction)
- Visible communication of carried wealth (Approved Direction)
- 2.5D presentation / controlled camera (Approved Direction; P001 baseline)

**Related Feature Spec:** `docs/features/p002_gold_collection.md`

### 1. Primary Design Question

Is finding, approaching, collecting, and visibly accumulating gold immediately readable and satisfying?

### 2. Hypothesis

Simple hand-placed pickups that collect on contact, with an immediate pop, sparkle, and short sound, plus a HUD count and a visibly filling pouch, will make gold collection readable without instruction and make players want to collect more ("I want that gold").

### 3. Why This Matters

Gold is GoldKing's central resource. Later prototypes (P003 power vs. burden, P004 spill and theft, P005 expedition) assume that obtaining gold is appealing on its own. If it is not, their results will be misleading.

### 4. Prototype Scope

- One placeholder gold pickup type, +1 each, about 20 hand-placed in the P001 gray box.
- Automatic proximity collection, exactly once per pickup, with no button and no magnet.
- Collection feedback: pop/shrink, small sparkle, one short sound.
- HUD gold counter.
- Provisional pouch attached to the King with three fill stages.
- Scene reset for repeat tests.

The pickup interaction, the pouch, and the feedback style are **P002 Prototype Assumptions only** (spec §10), not final mechanics or character design.

### 5. Out of Scope

- Gold-based power or burden, and any movement or posture changes (P003).
- Spilling, theft, or enemies (P004).
- Extraction, banking, or ownership (P005 or later).
- Treasure, inventory, economy, Gilding, combat, or procedural generation.
- Final art, audio, or animation, save data, and production player/inventory architecture.

### 6. Variables Being Tested

The starting values are listed in §11. Candidates for tuning between sessions:

- Pickup trigger radius.
- Pouch on vs. off, and the pouch stage thresholds.
- Coin bob on vs. off.
- Feedback intensity: sound volume and overlap, pop, and sparkle.

Change one at a time where practical.

### 7. Controls / Things Held Constant

- P001 movement, camera, collision, and facing, with tuning unchanged.
- P001 gray-box environment, unchanged.
- The same pickup layout and starting position for every run.

### 8. Success Signals

From spec §8. These are reviewable criteria, not canon.

- No critical counting or reachability bugs on the repeatable route.
- Both primary testers understand pickup without instruction on their first encounter.
- Both testers can tell that gold is accumulating, not merely disappearing.
- Satisfaction ratings of about 4/5. This is a useful target, not a rigid gate.
- Spontaneous desire to collect more.

### 9. Failure Signals

Derived from spec §3 and §8:

- Testers need coaching to understand that walking into gold collects it.
- Pickups in clusters or partly hidden spots are missed, or are triggered by accident.
- Collection moments are unclear in a cluster, or the feedback feels noisy or chaotic.
- Testers do not perceive accumulation beyond the HUD, or the pouch obstructs or distracts from the King.
- Collecting feels tedious rather than appealing.

### 10. Optional Measurements

| Metric | Result |
|---|---|
| Pickups missed on the first full route (which ones) | Playtest 1: not recorded |
| Coaching needed (yes/no; what) | Playtest 1: not recorded |
| Pouch noticed separately from the HUD (yes/no) | Playtest 1: not recorded. Pouch preference: undecided. |
| Satisfaction rating 1–5 (per tester) | Playtest 1 (Quon): 3/5 overall. Playtest 2 (Quon): floating 3/5, grounded 2/5. |

### 11. Test Setup

Implemented on branch `feat/p002-gold-collection`. All values below are prototype starting defaults for tuning, not design decisions. The implementation structure is prototype-local and is not a proposed architecture.

**Scene:** `game/prototypes/p002_gold_collection.tscn` is now the project main scene. It is an inherited scene of the unchanged P001 scene: same gray box, light, camera, and player, with the player starting at (0, 0, 8). The P001 scene still runs on its own (`--scene res://game/prototypes/p001_movement_camera.tscn`).

**Pickups:** 20 instances of `game/gold/gold_pickup.tscn`, each worth +1:

| Pattern | Count | Where |
|---|---|---|
| Isolated | 1 | Open west area |
| Trail | 5 | From near the start, angling north-east toward the passage |
| Narrow passage | 1 | Inside the 1.5 m passage |
| Compact cluster | 6 | 2 × 3 grid, 0.6 m spacing, open east area |
| Beside obstacles | 3 | Low block A (east face), pillar A (west face), dividing wall (south face) |
| Partly obscured | 1 | Directly north of pillar B, which is between it and the camera |
| North area, off the main path | 3 | Two along the north side, one in the far north-west corner |

**Pickup behavior:**
- Collection is triggered when the King's body overlaps a 0.3 m sphere at hip height. Combined with the 0.45 m capsule, that means within about 0.75 m center to center.
- A pickup collects exactly once and then removes itself. There is no magnet.
- The coin is a placeholder gold disc (SVG, 4× import, about 0.36 m) on the same Y-billboard and alpha-cut setup as the King. It casts a shadow.
- The coin art bobs 0.06 m at 0.8 cycles per second. The trigger does not move. Set Bob Height to 0 on `gold_pickup.tscn` to disable bobbing for every coin.

**Feedback:**
- The coin pops to 1.4× over 0.05 s, then shrinks away over 0.1 s.
- An 8-particle unlit sparkle burst lasts 0.35 s.
- One shared chime (generated placeholder, 0.14 s) is capped at 3 overlapping voices, with up to about 6% random pitch variation and volume at −6 dB.

**HUD:** top-left label reading "Gold: N". It updates in the same frame as collection and has no count-up animation.

**Pouch (provisional):**
- A sprite on the King's trailing (cape) side, 0.05 m behind his sprite so he always draws in front. It casts no shadow and has no collision.
- It mirrors his left/right facing.
- Stages:
  - Low below 6 gold
  - Partly filled from 6 to 13
  - Overflowing at 14 or more
- To compare without it, uncheck Visible on `Player/Pouch` in the P002 scene. Collection and the HUD are unaffected.

**Controls:** P001 movement controls, unchanged. **Reset:** R or gamepad Back (`restart_test` action) reloads the scene, restoring all pickups, the total, the pouch, and the start position.

**Running:**
- In the editor, open the project in Godot 4.7.2 and press F5.
- From the repository root, run `/Applications/Godot.app/Contents/MacOS/Godot --path .`

**Pre-playtest mechanical check (measured data, not a playtest):** a throwaway headless script, not committed, passed 73 of 73 checks on Godot 4.7.2:

- **Collection counting:**
  - Each pickup counts exactly once.
  - Duplicate overlap signals and non-player bodies do not count.
  - The full route totals 20.
  - The HUD matched the total on every checked physics frame.
  - The pouch changed at 6 and 14.
- **Speed:** all trail and cluster pickups registered at full 5 m/s, with up to 2 pickups in one physics frame.
- **Reachability:** every pickup was reached by real movement.
- **Pouch:**
  - Hiding it does not affect collection.
  - It mirrors with the King's facing.
- **P001 regression:** speed, diagonal speed, stopping, wall collision, the narrow passage, the camera offset and pitch, and the King's shadow are unchanged.
- **Reset:** R and gamepad Back both restore the initial state.

Audio audibility, sparkle appearance, pouch readability, and collection feel were **not** evaluated by automation.

#### Iteration 1 Setup (2026-11-12, build `94e86aa`)

This iteration was approved after playtest 1, where sound/visual feedback rated 2/5 and overall satisfaction 3/5 (§13). The setup above is otherwise unchanged:
- Same 20 pickup positions, values, and 0.3 m trigger.
- Same HUD counting and pouch (implementation untouched).
- Same reset.
- P001 movement, camera, collision, and tuning unchanged.

All values are prototype starting points, not design decisions.

**Feedback changes** (apply to both presentations):

| Element | Playtest 1 | Iteration 1 |
|---|---|---|
| Pickup sound | Soft two-note sine chime, 0.14 s | Metallic two-strike "ch-ing": inharmonic partials plus a short contact click, 0.38 s ring. Generated placeholder. Same −6 dB, about ±6% pitch variation, max 3 voices. |
| Rapid pickups | Every pickup triggers a sound | Pickups less than 45 ms apart share one sound, so clusters read as separate clinks rather than a stacked smear. Every pickup still counts. |
| Coin pop | Grow to 1.4×, then shrink, in 0.15 s | Overshoot to 1.5× with a bright color flash, lift 0.35 m, then shrink, in 0.18 s |
| Glint | None | Four-point star flash at the coin, about 0.18 s, drawn on top of other geometry so it isn't hidden by the popping coin |
| Sparkle | 8 solid particles, 0.35 s | 12 particles that fade white → gold → transparent, 0.45 s |
| HUD | Number changes instantly | Number still changes instantly, plus a subtle pulse (1.15× scale, settling over 0.12 s). Set Hud Pulse Scale to 1 to disable. |

**Presentation comparison** (only the coin art differs between modes):
- **A — Floating:** the playtest 1 look. Upright Y-billboard coin at 0.35 m, bobbing 0.06 m, casting a shadow.
- **B — Grounded:** the same coin texture and size lying flat on the floor, 0.02 m up. No bob and no shadow. From the camera it looks like a slightly squashed disc.
- To switch, select the root node of `game/prototypes/p002_gold_collection.tscn` and change **Gold Presentation** to Floating or Grounded. It applies to all 20 pickups. Reset (R) keeps the selected mode.

**Pre-playtest mechanical check (iteration 1, measured data, not a playtest):** the original throwaway suite was reused and extended with presentation and feedback checks. It passed 83 of 83 checks in **each** presentation mode on Godot 4.7.2:
- Counting, duplicate-signal and non-player guards.
- Full-speed trail and cluster collection.
- The HUD matched the total on every checked physics frame.
- Pouch stages, hiding, and facing.
- Reachability of all 20 pickups by real movement.
- R and gamepad Back reset.
- P001 movement and camera regression.
- Mode-specific coin pose, bob or no bob, a stationary trigger, glint and HUD pulse on collection, and the 45 ms sound merge.

Sound quality, effect readability, grounded-coin visibility in play, and satisfaction were **not** evaluated by automation.

### 12. Observations

#### Playtest 1 — Quon, 2026-11-12, build `d2d201c` (floating coins, original feedback)

Quon played the §11 setup with its starting values. Changes made during the session were not reported.

Not recorded:
- Which pickups, if any, were missed.
- Whether any coaching was needed.
- Which input device was used.
- Whether the pouch-off comparison was tried.

#### Playtest 2 — Quon, reported 2026-11-13, build `94e86aa` (iteration 1: improved feedback; floating and grounded presentations)

Quon played both presentation modes with the iteration 1 feedback and compared them.

Not recorded:
- Which mode was played first.
- Which pickups, if any, were missed.
- Which input device was used.
- Whether the pouch was on or off.

Visible wealth accumulation and pouch preference were not rated in this playtest.

### 13. Player Comments

#### Playtest 1 — Quon (player report)

| Dimension | Rating (1–5) |
|---|---|
| Gold recognition / discovery | 5 |
| Natural collection | 5 |
| Sound / visual feedback | 2 |
| Visible wealth accumulation | 4 |
| Overall collection satisfaction | 3 |
| Pouch preference | Undecided |

- Collecting gold feels natural but only moderately satisfying.
- Floating collectibles work mechanically, but whether they suit GoldKing is uncertain.
- Grounded gold might feel more physically integrated into the world.

#### Playtest 2 — Quon (player report)

| Dimension | Floating gold | Grounded gold |
|---|---|---|
| Recognition | 5 | 2 |
| Natural collection | 4 | 3 |
| Audio / visual feedback | 3 | 3 |
| Overall satisfaction | 3 | 2 |

**Preference:** floating gold.

- The improved audio still isn't particularly pleasing.
- Floating gold feels more attractive and inviting.
- Quon prefers floating gold over grounded gold.
- Further audio refinement can happen later.

### 14. What Worked

Playtest 1:
- Finding the gold (5/5).
- Collecting by walking into it (5/5).
- Seeing wealth accumulate (4/5).

Playtest 2:
- Floating gold stayed highly recognizable (5/5) and was described as more attractive and inviting.
- Feedback was rated 3/5 in both modes, up from 2/5 in playtest 1.

### 15. What Did Not Work

Playtest 1:
- Sound and visual feedback (2/5) was the weakest-rated dimension.
- Overall satisfaction (3/5) is below the 4/5 target in spec §8.

Playtest 2:
- Grounded gold was much harder to recognize (2/5), and its overall satisfaction was lower (2/5).
- The improved audio is still not particularly pleasing.
- Overall satisfaction stayed at 3/5 with floating gold, still below the 4/5 target.
- Natural collection for floating gold was rated 4/5, down from 5/5 in playtest 1. The reason was not reported.

### 16. Interpretation

Playtest 1 *(developer interpretation; one tester, who is also a developer, in one session)*:

- Discovery and the proximity pickup appear to work. The feedback is the most likely limit on satisfaction.
- Whether floating presentation contributes is uncertain. It is worth one direct comparison against grounded gold with the same feedback.
- The pouch was not decisively helpful or harmful.

Playtest 2 *(developer interpretation; the same single tester)*:

- The iteration 1 feedback appears to be an improvement (2 → 3), but not enough to raise overall satisfaction. Better feedback alone may not reach the 4/5 target with placeholder assets.
- In this gray-box scene, floating gold clearly reads better than gold lying flat on the floor.
  - Possible reasons for the grounded result: no bob, no shadow, a squashed silhouette from the camera angle, and low contrast against the floor.
  - These are unconfirmed. A different grounded treatment (for example a standing heap) was not tested.
- The drop from 5 to 4 for floating natural collection may be noise. It could also be an effect of the longer pop or of comparing modes. This is unconfirmed.
- Order effects between the two modes are unknown.

### 17. Unexpected Findings

Playtest 1:
- Quon suggested breaking objects, digging, and discovering river deposits as possible future ways to obtain gold. These are **future possibilities only**. They are not approved, not P002 features, and not Decision Log entries.

Playtest 2:
- None reported.

### 18. Outcome

**Outcome:** Iterate. Recorded as "Needs Iteration — feedback polish deferred; collection baseline accepted for subsequent prototyping."

**Confidence:**
- **Medium** for recognition and automatic proximity collection.
- **Low** for overall satisfaction and final presentation.

**Conclusion:** Floating gold is easy to find, and collecting it on contact feels natural. That is a good enough collection baseline to continue prototyping. P002 is **not** fully validated:
- Satisfaction is moderate.
- Feedback still needs work.
- The pouch's contribution is unclear.

**Supported findings:**
- Floating gold is highly recognizable: 5/5 in both playtests.
- Automatic proximity collection feels natural: 5/5, then 4/5.
- Floating gold is preferred over grounded gold in the tested gray-box environment.
- Gold accumulation was reasonably clear in playtest 1 (4/5).
- All reported mechanical validation checks passed: 73 of 73 on the original setup, and 83 of 83 in each mode for iteration 1.

**Unresolved:**
- Overall satisfaction remains moderate (3/5), below the 4/5 target.
- Audio and visual feedback still need improvement. The current sound and effects are **placeholder quality, not production-ready**.
- The pouch's contribution remains unclear. Preference was undecided in playtest 1 and not rated in playtest 2.
- Collection has not yet been tested alongside gold power and burden.
- Only one tester (Quon, also a developer). Jason has not tested P002.

Feedback polish is **deferred**, not abandoned. It should be revisited when audio and visual work is in scope or when satisfaction blocks a later prototype.

### 19. Decision Impact

- **Weakly supports** the existing Approved Directions *gold as a central, desirable resource* and *visible communication of carried wealth*. Gold is noticed and collected readily, but satisfaction is only moderate. No Decision Log change.
- The P002 Prototype Assumptions are **retained as working choices, not promoted**:
  - Automatic proximity pickup
  - Floating presentation
  - HUD counter
  - Provisional pouch

  They are not permanent gameplay decisions, character design, or narrative canon.
- Grounded (flat) gold was **not preferred** in this test. This is evidence about one gray-box treatment, not a general rejection of grounded gold.
- Breaking objects, digging, and river deposits remain unapproved future possibilities (§17), outside P002 and P003.

### 20. Next Test

**P003 — Gold Power vs. Burden.**

**Working baseline carried forward from P002.** These are prototype choices, not decisions:
- Floating gold presentation (Gold Presentation set to Floating).
- Automatic proximity collection (0.3 m trigger).
- The existing HUD counter.
- The provisional pouch (still optional, contribution unclear).
- The existing iteration 1 sound and effects, kept as placeholder quality.

P003 scope does **not** include breakable objects, digging, river deposits, or further feedback polish.

---

# Planned Prototype 003

## P003 — Gold Power vs. Burden

**Status:** Concluded for the current prototype cycle (2026-11-14). Outcome: Iterate (§18). The design question is not fully validated. After Playtest 2, Quon approved a revised gold-risk direction (§19), so this entry and its implementation are kept as historical evidence of what P003 actually tested: automatic speed penalties and increased strike impact.  
**Date Started:** 2026-11-13  
**Date Concluded:** 2026-11-14  
**Build / Commit:** `0070266` (Playtest 1 build); `becbe71` (Iteration 1 build). Branch `feat/p003-gold-power-burden`.  
**Testers:** Quon (Playtests 1 and 2). Quon is the only recorded human tester; Jason's playtest is not recorded.  
**Related Decision(s):**
- Gold as a central, desirable resource (Approved Direction)
- Gold Power vs. Burden (Prototype Assumption; exact mechanic unvalidated). Its automatic physical-burden portion was superseded on 2026-11-14 (§19).
- Gold Power With Wealth-Driven External Danger (Approved Direction, 2026-11-14; Decision Log)
- P001 movement and camera baseline; P002 working collection baseline

**Related Feature Spec:** `docs/features/p003_gold_power_burden.md`

### 1. Primary Design Question

Can becoming richer feel increasingly powerful and increasingly dangerous at the same time, without making the player want to avoid gold?

### 2. Hypothesis

From spec §3:
- A temporary strike that needs fewer hits as gold rises will make wealth feel like power.
- A mild loss of top speed, felt against a timed gate, will make wealth feel like a cost.
- In one short route where both matter, the trade-off will feel interesting rather than punishing, and players will still want more gold.

### 3. Why This Matters

"More gold = more power and more burden" is the central gold fantasy (a Prototype Assumption). If the burden only reads as friction, or the power only reads as a number, the core loop needs a different burden form before P004 and P005 build on it.

### 4. Prototype Scope

- Three provisional wealth states driven by the existing P002 gold total.
- One temporary strike against stationary test targets.
- A top-speed penalty only.
- One combined course: start → blocking target → timed blocking gate → finish.
- A practice target, and a movement-only course option.
- Trial presets and reset.
- P002 collection, HUD, pouch, and floating gold reused unchanged.

### 5. Out of Scope

- Enemy AI or full combat.
- Player health, damage, death, or failure.
- Stamina, dodge, or more than one burden mechanic.
- Gold spill or theft (P004).
- Expedition, extraction, or banking (P005).
- Midas/Gilding.
- Inventory or economy.
- Progression or saving.
- Breakable-loot rewards, digging, or river deposits.
- Audio/VFX polish, and stronger effects for Heavy.

### 6. Variables Being Tested

- Wealth state:
  - Light (0–5 gold)
  - Loaded (6–13)
  - Heavy (14+)
- Per state, top speed (5.0 / 4.6 / 4.2 m/s) and strike impact (2 / 3 / 6 against toughness 6).

### 7. Controls / Things Held Constant

- Acceleration (80), deceleration (120), diagonal capping, facing, collision, and camera are unchanged in every state.
- Strike cooldown (0.3 s), reach (1.0 m), and feedback are identical in every state.
- Course geometry and gate schedule are identical for every trial. The gate phase resets at each trial start.
- No pickups in the course lane, so gold is constant during a trial.

### 8. Success Signals

From spec §8. Reviewable, not canon.

- Power and burden are both perceptible in play.
- Gold stays attractive at higher states, and players can say when the extra wealth is worth it.
- Basic movement stays reliable.
- Some real preference or tension emerges in the combined course. Not everyone always picks Heavy, and not everyone always rejects it.
- Players can describe "imposing" vs. "sluggish".

### 9. Failure Signals

From spec §8:
- Players avoid gold once the burden appears.
- A slow King feels bad to control.
- Power is only visible as a number.
- The course shows inconvenience but no meaningful pressure.

If these appear, reconsider the burden form before adding more systems.

### 10. Optional Measurements

| Metric | Result |
|---|---|
| Combined-course time per state (several runs, with order recorded) | — |
| Target-broken split per state | — |
| Gate wait per state | — |
| Ratings 1–5: perceived power, burden fairness, movement feel, desire to collect more, trade-off enjoyment | — |
| State preference and reason | — |

### 11. Test Setup

Implemented on branch `feat/p003-gold-power-burden`. **All values are Prototype Assumptions and starting points for tuning, not final balance.** The implementation is prototype-local and not a proposed combat or controller architecture.

**Scene:** `game/prototypes/p003_gold_power_burden.tscn` (now the project main scene). It is an inherited scene of the unchanged P002 scene, which itself inherits P001.
- The same gray box, camera, player, 20 floating pickups, HUD, and pouch are present.
- The controller script extends the P002 controller and uses its gold total. There is no second counter.
- No P001 or P002 files were modified. P002 and P001 still run on their own with `--scene`.

**Wealth states:**

| State | Gold | Top speed | Strike impact | Hits to break (toughness 6) |
|---|---|---|---|---|
| Light | 0–5 | 5.0 m/s | 2 | 3 |
| Loaded | 6–13 | 4.6 m/s | 3 | 2 |
| Heavy | 14+ | 4.2 m/s | 6 | 1 |

- The state is applied whenever the gold total changes: natural pickup, a preset key, or a reset. The HUD, pouch, speed, impact, and trial label update in the same frame.
- Thresholds match the pouch stages (6 / 14).
- Only top speed changes. The P003 controller sets the player's existing `move_speed` at runtime and does not touch the P001 player files.

**Strike:**
- J, Space, or gamepad X/Square, with a 0.3 s cooldown.
- **Radial** 1.0 m reach around the King's hip. It does not aim with facing, which keeps it forgiving.
- Shows a flat reach ring on the floor and plays a placeholder hit sound when it lands.
- Affects P003 test targets only.
- Targets show remaining toughness as `[######]` pips, flash on hit, and burst into debris when broken.
- The same feedback appears in every state.

**Course (north area, separate from the P001 narrow passage):**
- A 0.6 m-high lane wall forms a 2.25 m-wide dead-end lane along the north wall. It is low so the camera can see the King inside the lane.
- The route runs east to west: start line (x 2) → course target filling the lane (x 0) → timed gate (x −3.5) → finish line (x −12).
- **Timed gate:**
  - A stationary barrier whose collision and look switch on a fixed schedule: closed for 1.0 s, then open for 1.0 s, repeating. It shows a yellow floor strip for the last 0.3 s before closing.
  - Its clock starts at zero when the trial starts, so every trial sees the same phase.
  - **Collision-safe close:** if the King is inside the gate when it is due to close, it stays open until he is clear, then closes for the rest of that window. The schedule is not shifted, so later cycles stay on time. The delay only happens when he is standing in the gateway, so normal runs are unaffected.
- No damage, health, pushing, gold loss, or failure.
- The tall P001 pillar near x −6 sits between the gate and the finish.

**Practice target (power only):** in the open west area at about (−12, 6). It respawns about 1 s after breaking, and the trial HUD shows how many hits the last break took.

**Movement-only comparison:** untick `Course Target Enabled` on the P003 root. The course target is then absent, so trials time traversal and gate waiting only.

**Measurements (shown in the trial HUD, and printed as one line per trial in the Output panel; nothing is saved):**
- Wealth state, gold, and speed.
- Total time, counted in physics ticks at 60 per second.
- Time when the target broke.
- Strike attempts and hits on the course target.
- Time spent waiting in front of the closed gate.
- **Caution:** the start → target-broken split includes the approach as well as striking, so it is **not** a pure measure of attack power.

**Controls:**
- P001 movement controls, unchanged.
- **1 / 2 / 3** (or D-pad left / up / right): set gold to 0 / 10 / 20, which puts the King in Light / Loaded / Heavy. Each also moves the King to the course start and resets the target, gate phase, timer, and counters.
- **R**: full scene reload. Gold returns to `Start Gold` (0) and the King to the P001 start.
- Walking up to the lane entrance also arms a new trial.
- The Light/Loaded/Heavy line in the trial HUD can be hidden with `Show Wealth State`.

**Running:** open the project in Godot 4.7.2 and press F5, or run `/Applications/Godot.app/Contents/MacOS/Godot --path .`

**Pre-playtest mechanical check (measured data, not a playtest):** Godot 4.7.2, all checks headless.

A throwaway P003 script, not committed, passed **84 of 84** checks:

| Area | What was checked |
|---|---|
| Thresholds | 5→6 and 13→14, both set directly and through natural pickups. Speed, impact, HUD, pouch, and trial label stay in sync. |
| Movement | Top speed 5.0 / 4.6 / 4.2 m/s, with diagonals no faster. Acceleration and deceleration steps (80/60, 120/60 per frame) are unchanged in every state. Wall collision, the P001 passage at Heavy, facing, and camera offset are unchanged. |
| Strike | Breaks the practice target in exactly 3 / 2 / 1 strikes. The cooldown allows one strike per 0.3 s. Strikes out of reach don't hit, and striking doesn't change gold. |
| Course | The intact target blocks the lane, and the lane can't be bypassed. The gate schedule is correct, a closed gate blocks, and an open gate passes. The gate never closes onto the King and he can't get stuck in it. |
| Trials | All three states complete the course. Each state took exactly 3 / 2 / 1 hits. The timer matches the frames observed. Gold stays constant during trials. Three identical scripted runs per state gave identical results. The movement-only option works. |
| Resets | Preset keys and R reset everything as described. |
| P002 inside P003 | Collection and HUD work, and all 20 pickups are reachable with the lane wall and practice target added. |

Scripted-run results, for reference only. They come from a scripted input pattern, not a human player, so they are not evidence of feel:

| State | Time | Target broken at | Gate wait |
|---|---|---|---|
| Light | 3.45 s | 0.85 s | 0 s |
| Loaded | 3.33 s | 0.52 s | 0 s |
| Heavy | 3.33 s | 0.22 s | 0.05 s |
| Movement-only (Light) | 2.82 s | — | — |

The original P002 suite, unchanged and run against the unchanged P002 scene in both presentation modes, passed 82 of 83. The one failure is its "main scene is P002" check, which is expected because the main scene is now P003. P001, P002, and P003 scenes and all new scripts load and parse with no errors or warnings.

**Not evaluated by automation:** whether the King feels stronger, whether the slowdown is fair or annoying, whether the gate creates tension, whether testers still want gold, strike and hit feel, and audio and visuals.

**Known limitations and risks:**
- The gate schedule interacts strongly with the course layout. With these starting values the scripted Loaded and Heavy runs tie. Gate timing (`Closed Time`, `Open Time`, `Phase Offset`) and positions are tuning variables, not results.
- A single run time is not conclusive. Human reaction and gate-cycle luck add variance, so record several runs per state and the order they were played in.
- The radial strike ignores facing, so the King can hit a target behind him. This was accepted as a forgiving test instrument.
- The 1 / 2 / 3 keys are test shortcuts, not a gameplay feature. Natural collection can only reach Heavy by collecting coins outside the lane first.
- The input bindings overlap Godot's built-in UI actions (D-pad with `ui_left`/`ui_up`/`ui_right`, Space with `ui_accept`). This is harmless because the prototype has no focused UI.
- The strike hit sound and all visuals are generated placeholders.

#### Iteration 1 Setup (2026-11-14, build `becbe71`)

Approved after Playtest 1, where movement burden noticeability rated 2/5 (§13). Only maximum movement speed changes; everything else in the setup above is unchanged.

The original Iteration 1 commit (`8e4257e`, made in another environment) was not pushed and could not be recovered, so this build is a reconstruction from the approved description. It has been re-validated (below).

**Configuration toggle:** `Stronger Burden` on the P003 root node (Wealth States group). Default off. Toggle it in the Inspector before running. A full reset (R) reloads the scene, so a value changed at runtime through the remote Inspector does not survive R.

| Wealth State | Original | Stronger Burden |
|---|---|---|
| Light | 5.0 m/s | 5.0 m/s |
| Loaded | 4.6 m/s | 4.4 m/s |
| Heavy | 4.2 m/s | 3.8 m/s |

Held constant: impact 2 / 3 / 6 (toughness 6 → 3 / 2 / 1 hits), thresholds 6 / 14, acceleration and deceleration, strike cooldown 0.3 s and reach 1.0 m, course, gate, and targets.

**Configuration labels:** the trial HUD's first line is always `Config: Original` or `Config: Stronger burden`, also when the wealth-state line is hidden. Every printed result line names it, for example `P003 trial | Stronger burden | Heavy | gold 20 | speed 3.8 m/s | …`.

**Strike cooldown reset:** pressing 1 / 2 / 3 clears any remaining strike cooldown, so the first strike of each preset trial is available immediately. The regular 0.3 s cooldown between strikes is unchanged during play.

**Mechanical validation (Godot 4.7.2, headless):** the throwaway P003 script, extended for Iteration 1 and not committed, was run once per configuration and passed **108 of 108** in each. It covers everything in the earlier 84-check suite, with speed expectations set per configuration, plus the defaults, the configuration labels, live toggling of the configuration (speed and label change, impact does not), the cooldown reset after each preset key, and the regular cooldown still applying. The printed result lines carried the correct configuration label in both runs. The original P002 suite passed 82 of 83 in both presentation modes; the one failure is its expected "main scene is P002" check. P001, P002, and P003 scenes load headless with no errors or warnings.

Scripted reference runs (identical inputs; not player performance):

| State | Original | Stronger burden |
|---|---|---|
| Light | 3.45 s (target 0.85 s) | 3.45 s (target 0.85 s) |
| Loaded | 3.33 s (target 0.52 s) | 3.48 s (target 0.53 s) |
| Heavy | 3.33 s (target 0.22 s, gate wait 0.05 s) | 3.68 s (target 0.23 s, gate wait 0.00 s) |

With Stronger burden the scripted Heavy run no longer ties Loaded, but gate timing still shapes the totals; treat these as tuning references only.

### 12. Observations

#### Playtest 1 — Quon

Playtest 1 was recorded from Quon's player report. No trial result lines (times, strike counts, gate waits) were captured, so there are no measured comparisons between states for this playtest.

- The speed reduction was barely noticeable until most or all of the available gold had been collected.
- Because the scene has a limited amount of gold, the naturally reached Heavy state lasted a relatively short time.
- Heavy breaking the test target in one hit, instead of three at Light, was enjoyable.

#### Playtest 2 — Quon (Iteration 1, build `becbe71`)

Playtest 2 compared the Original and Stronger Burden speed configurations (§11, Iteration 1 Setup). It was recorded from Quon's player report. No trial result lines were provided for this record, so there are no measured comparisons between configurations.

- The Stronger Burden configuration felt like a mixture of satisfying weight and sluggishness.
- Increased burden did not discourage collecting gold.
- The trade-off remained interesting but did not receive a higher rating than in the Original configuration.

### 13. Player Comments

#### Playtest 1 — Quon (player report)

| Dimension | Rating (1–5) |
|---|---|
| Increased striking power | 3 |
| Movement burden noticeability | 2 |
| Movement enjoyment at Heavy | 4 |
| Power-versus-burden interest | 4 |
| Overall enjoyment | 4 |

| Question | Answer |
|---|---|
| Preferred wealth state | Heavy |
| Did movement penalties discourage collecting gold? | No |

- Quon wants Heavy to feel more like a tank and Light to feel more like a high-DPS playstyle.
- The mechanic is promising but needs further tuning.

#### Playtest 2 — Quon (player report)

| Dimension | Original (5.0 / 4.6 / 4.2 m/s) | Stronger Burden (5.0 / 4.4 / 3.8 m/s) |
|---|---|---|
| Burden noticeability | 4 | 5 |
| Heavy movement enjoyment | 4 | 4 |
| Power-versus-mobility trade-off | 4 | 4 |

| Question | Answer |
|---|---|
| Preferred configuration | Stronger Burden |
| Did increased burden discourage collecting gold? | No |

- Quon questioned whether automatic slowdown would remain suitable across entire expeditions containing substantially more gold.
- Quon noted that designing traversal and combat around different movement speeds introduces additional balancing considerations.
- Quon proposed exploring optional gold-powered heavy states and item-based encumbrance as alternatives.

### 14. What Worked

Playtest 1:
- The one-hit Heavy break was enjoyable.
- Power-versus-burden interest (4/5) and overall enjoyment (4/5) were positive.
- Heavy was the preferred state, and the movement penalty did not discourage collecting gold.
- Movement remained enjoyable at Heavy (4/5).

Playtest 2:
- Both configurations made the burden noticeable (Original 4/5, Stronger Burden 5/5).
- Heavy movement enjoyment stayed at 4/5 in both configurations.
- Neither configuration discouraged collecting gold. Stronger Burden was preferred.

### 15. What Did Not Work

Playtest 1:
- The movement burden was hard to notice (2/5). The slowdown registered only near or at full gold.
- The increased striking power rated only 3/5.
- The natural Heavy experience was short because the scene has limited gold.

Playtest 2:
- Stronger Burden also felt partly sluggish, not only weighty.
- The trade-off rating did not improve with the stronger penalty (4/5 in both configurations).

### 16. Interpretation

Single tester, single session, player report only; treat as low-confidence direction, not validation.

- The current speed values (5.0 / 4.6 / 4.2 m/s) may be too close together to communicate burden. This is the reason for the stronger-burden comparison below.
- Heavy's appeal at this stage appears to come from its power, and the burden does not yet act as a real cost. Whether the trade-off works cannot be judged until the burden is noticeable.

After Playtest 2 (still one tester, short controlled sessions):
- Ratings in Playtest 1 and Playtest 2 differ for the same Original speeds (burden noticeability 2/5, then 4/5). Playtest 2 was a direct side-by-side comparison of the two configurations; the reasons for the difference were not recorded, so it is not treated as a measured effect.
- A stronger automatic speed penalty made the burden clearly noticeable without reducing Heavy enjoyment or the desire to collect gold, but it did not make the trade-off more interesting.
- The current three-state penalty is capped at Heavy. Indefinite or continuing slowdown was not implemented or tested, so P003 says nothing about automatic slowdown across long expeditions with much more gold.

### 17. Unexpected Findings

Playtest 1:
- Quon framed the states as playstyles (Heavy as a tank, Light as high-DPS) rather than only as more power vs. more burden. This is recorded as an Experimental Idea in §19 and is not part of P003.

Playtest 2:
- Quon's main concern after Playtest 2 was long-term fit rather than short-session feel: expedition-length pacing, gold desirability at much larger totals, and designing traversal and combat around varying speeds. This led to the direction review in §19.

### 18. Outcome

**Outcome:** Iterate — automatic gold-based movement burden superseded as the intended core approach; wealth-driven external danger approved for future testing.  
**Confidence:**
- Medium in the short-session observations.
- Low in long-expedition scalability and final combat identity.

Supported findings (one tester, short controlled sessions):
- Increasing impact through gold is promising.
- Automatic movement slowdown can be noticeable and tolerable during a short controlled prototype.
- Stronger Burden was the preferred tested speed configuration.
- Heavy movement enjoyment remained 4/5.
- Neither configuration discouraged collecting gold.

Unresolved:
- The long-term scalability of automatic slowdown was not tested.
- The final combat and burden systems remain unresolved.

The whole P003 design question is not marked Validated. The implementation, test setup, and results above are kept as the record of what was tested.

*Interim outcome after Playtest 1 (2026-11-13, kept for history): Pending; Iteration 1 approved (stronger-burden speed comparison); confidence Low.*

### 19. Decision Impact

*After Playtest 1 (2026-11-13, kept for history):* no decision changes; Gold Power vs. Burden remained a Prototype Assumption.

After Playtest 2 (2026-11-14), Quon reviewed the findings and explicitly approved a revised gold-risk direction:
- **New Approved Direction (Decision Log, 2026-11-14 — Gold Power With Wealth-Driven External Danger):** accumulating ordinary gold stays highly desirable and adds to the Gold King's power. Greater wealth also creates the potential for greater external danger, attention, and vulnerability. Automatic movement-speed penalties from ordinary gold are no longer the intended core downside.
- **Superseded:** the automatic gold-based physical-burden part of the *Gold Power vs. Burden* Prototype Assumption and the matching Gameplay Foundation text. The original assumption stays in the Decision Log as history, and this entry is its evidence.
- **Not changed:** narrative canon; gold spill and theft remain Prototype Assumptions for P004.
- **Experimental Ideas (not approved):**
  - Wealth states as playstyles: Heavy as a tank, Light as a high-DPS style (from Playtest 1). For future combat exploration only.
  - An optional gold-powered heavy form (from Playtest 2).
  - Item-based encumbrance from large treasures or equipment (from Playtest 2).

### 20. Next Test

#### Iteration 1 — Stronger burden speed comparison (implemented in `becbe71`, setup in §11; tested in Playtest 2)

Compare two maximum-movement-speed configurations:

| Wealth State | Current | Stronger Burden |
|---|---|---|
| Light | 5.0 m/s | 5.0 m/s |
| Loaded | 4.6 m/s | 4.4 m/s |
| Heavy | 4.2 m/s | 3.8 m/s |

Held constant:
- Strike impact stays 2 / 3 / 6 (toughness 6 → 3 / 2 / 1 hits).
- Only maximum movement speed changes. No changes to acceleration, deceleration, attack speed (strike cooldown), or any additional burden variables.
- Wealth thresholds (6 / 14), course, gate, and targets unchanged.

Questions:
- Does a stronger speed penalty create a satisfying sense of weight?
- Does Heavy remain enjoyable and desirable?
- Does the stronger penalty improve the trade-off without discouraging gold collection?

Suggested for the next session: record the printed trial result lines for several runs per state and configuration, and the order they were played in.

*Playtest 2 answered these questions for a short controlled session (§12–18). No further P003 iteration is planned for this cycle.*

#### P004 handoff consideration (planning note, not a design)

P004 should not automatically inherit P003's speed-penalty mechanics just because P003 is the most recent prototype. Those mechanics remain useful experimental code, but they no longer represent the intended core gold-risk direction. During P004 planning, evaluate whether to build from the P002 collection baseline or reuse selected P003 functionality (for example the strike, test targets, or trial tooling). The exact scope of P004 — Gold Spill & Theft — still needs its own feature-specification review.

---

# Planned Prototype 004

## P004 — Gold Spill & Theft

**Status:** Concluded for the current prototype cycle (2026-11-14). Outcome: Iterate (§18). Not fully Validated.  
**Date Started:** 2026-11-14  
**Date Concluded:** 2026-11-14  
**Build / Commit:** `f5aa84d` (branch `feat/p004-gold-spill-theft`)  
**Testers:** Quon (Human Playtest 1). Quon is the only recorded human tester; Jason's playtest is not recorded.  
**Related Decision(s):**
- Gold Power With Wealth-Driven External Danger (Approved Direction, 2026-11-14)
- Losing Unsecured Gold and Treasure (Prototype Assumption; P004 does not implement expedition failure or banking)
- Gold spill and theft (Prototype Assumption; tested here)
- P001 movement baseline; P002 working collection baseline. P003 is not inherited (historical experiment).

**Related Feature Spec:** `docs/features/p004_gold_spill_theft.md`

### 1. Primary Design Question

Can the threat of losing collected gold create exciting, readable tension and motivate the player to protect their fortune without making them regret collecting it?

### 2. Hypothesis

From the spec: one readable thief that spills a little carried gold on contact, tries to take one coin, and can be caught by chasing it will create "That's *my* gold — get back here!" tension, while the loss stays small and recoverable enough that the player still wants more gold.

### 3. Why This Matters

The 2026-11-14 Approved Direction makes external danger, not automatic slowdown, the core downside of wealth. P004 is the first test of whether an external actor taking gold feels fair and motivating before P005 builds an expedition around it.

### 4. Prototype Scope

- One placeholder thief in one authored area, once per reset.
- Contact spill (cap 3), one theft (cap 1), movement-only interception, limited loss on escape.
- P002 floating gold, collection, gold counter, pouch, and pickup feedback reused unchanged.
- Test presets, full reload, a test-only status line, and a printed result per encounter.

### 5. Out of Scope

Combat, strikes, health or damage; P003 wealth states and speed penalties; more than one thief or any enemy framework, navigation, or threat scaling; banking, expedition failure, permanent loss, inventory; heavy forms, encumbrance, Gilding; audio/visual polish.

### 6. Variables Being Tested

Thief readability, spill readability, the recover-or-chase choice, and whether a small real loss changes the desire to collect gold.

### 7. Controls / Things Held Constant

- King movement is P001's: 5.0 m/s top speed, acceleration 80, deceleration 120, at every gold amount and after spills.
- P002 pickups, positions, values, trigger, and feedback are unchanged.
- Thief behavior is deterministic: the same inputs produce the same encounter.

### 8. Success Signals

From spec §7 (directional, not hard gates): testers can explain spill and recovery without a tutorial; no counting or unreachable-drop bugs; a real movement-based way to avoid, chase, or recover; gold desirability stays high (aim 4/5+); tension visible in behavior.

### 9. Failure Signals

Persistent irritation, loss of agency, losses that feel unavoidable, or players avoiding gold to avoid the thief, even if the encounter works mechanically.

### 10. Optional Measurements

The printed result line per encounter (outcome, start gold, level gold, spilled, recovered, stolen, dropped, lost, carried, on ground), plus tester ratings from spec §7.

### 11. Test Setup

**Scene:** `game/prototypes/p004_gold_spill_theft.tscn`, inheriting the unchanged P002 scene. It is now the project main scene, so F5 launches P004. P001–P003 scenes remain available to open directly.

**Encounter area:** the arena's existing north-east pocket (open floor from x −3 to 14.6, z −14.6 to −7.4), reached through P001's narrow passage. No new geometry. The thief only moves in straight lines inside this rectangle, so it cannot cross walls.

| Item | Position |
|---|---|
| Burrow (dark disc; thief's start and escape point) | (13.5, 0, −13.5) |
| Preset start marker | (5.75, 0, −6.2), in the passage mouth, ~10.6 m from the burrow (outside the trigger radius) |

The start marker was moved from the planned (5.75, −4) because walking north from there collects P002's `Passage` coin during the first preset trial only, which made trials unrepeatable.

**Thief states:** IDLE at the burrow → ALERT ("!" for the warning time; only if the King carries gold and is inside the trigger radius) → APPROACH → contact: PAUSE → GRAB (heads for the nearest landed spilled coin) → FLEE to the burrow → GONE. If the approach times out, it flees empty-handed. Interception is only possible during FLEE while the thief carries gold; it then drops the coin as a pickup and keeps fleeing empty-handed. One encounter per reset. A King with 0 gold never triggers it; that case prints a "no gold" result once and does not use up the encounter.

**Gold accounting:** the P004 controller is the single owner of every transfer and keeps `carried + coins on the ground + thief-held + lost = starting gold + level gold collected` true after each one (asserted in debug builds and checked by the test). Ordinary level gold enters through the normal P002 pickups and is counted separately. Spilled and dropped coins are a P004-local variant of the P002 pickup: they cannot be collected while scattering, and they ask the controller whether the King receives them *before* any pop, sparkle, sound, or HUD pulse. A coin the thief has claimed is removed silently, so the King never sees collection feedback for gold he did not get. The P002 pickup script is unchanged.

**Level-coin reset policy:** preset keys never respawn or remove level pickups. Collected level coins stay collected and uncollected ones stay where they are. A preset starts a new haul at the preset amount; gold from earlier level pickups is replaced by the preset, not added to it. R reloads the whole scene, restoring all 20 level coins and 0 gold.

**Controls:** WASD / arrows / left stick move. **1 / 2 / 3** (also D-pad left / up / right): new trial with 0 / 10 / 20 gold. This clears spilled coins, ledger, and counters, returns the thief to its burrow, and puts the King at the start marker. These reuse the P003-named `trial_light/loaded/heavy` actions. **R** (gamepad Back): full reload. No attack input.

**Starting values (Prototype Assumptions, exported; none playtest-validated):**

| Parameter | Value |
|---|---|
| Trigger radius from burrow | 9 m |
| Warning | 1.0 s |
| Approach speed | 3.0 m/s |
| Approach give-up | 8 s |
| Contact radius | 0.8 m |
| Pause after spill | 0.5 s |
| Grab speed / escape speed | 3.5 / 3.5 m/s |
| Claim radius | 0.4 m |
| Interception radius | 1.0 m |
| Spill cap / theft cap | 3 / 1 |
| Spill placement | 1.6 m from the King at 60°, −60°, then 180° from the King-to-thief direction (two on the thief's side, so its escape leads away from the King; one behind him) |
| Coin hop | 0.3 s, 0.6 m high |
| Dropped coin | 0.6 m ahead of the intercepted thief |
| Presets | 0 / 10 / 20 |
| Test HUD | visible by default; untick **Show Test HUD** on the P004 root to hide it (the gold counter stays) |

**Feedback:** "!" over the thief during the warning; spilled coins hop out with a lower-pitched pickup sound; a gold coin over the thief's head while it carries stolen gold; a brief red flash and the coin hopping out on interception. All placeholder.

**Mechanical validation (Godot 4.7.2, headless):** `tests/p004_regression.gd` passed **71 of 71** and exits non-zero on failure (checked with a deliberately wrong expectation). It covers:
- Ledger balance throughout; spill caps for 0 / 1 / 2 / 3 / 10 / 20 gold; theft cap; no negative gold.
- No collection while scattering; each coin recovered once; claim-versus-pickup in the same physics frame in both orders, with collection feedback only when the King receives the coin.
- Warning before approach; avoidance by retreating and the thief giving up; one encounter per reset; zero-gold case.
- No interception during GRAB or while fleeing empty-handed; interception drops the coin and it is recoverable.
- Preset resets and repeatability; level-coin policy; R reload.
- P001/P002 behavior inside P004 (speed 5.0 at 0 / 10 / 20 gold and after a spill, acceleration and deceleration, walls, passage, facing, camera, level pickups, gold counter and pouch); P001–P004 scenes instantiate.

`tests/p003_regression.gd` still passes 114 of 114. P001–P004 scenes and the default launch run headless with no errors or warnings.

Scripted reference trials (10 gold, King standing at a fixed point inside the pocket; not player performance):

| Scenario | Result |
|---|---|
| No pursuit | Thief escapes with 1 gold; the other 2 spilled coins stay on the ground |
| Chase as soon as it takes a coin | Intercepted |
| Chase 0.5 s late | Intercepted |
| Chase 1.5 s late | Escapes with 1 gold |
| 1 gold, King collects the spilled coin first | Thief leaves empty-handed |
| 10 gold, King collects the coin nearest the thief first | King recovers 1, thief steals 1 and escapes |

**Windowed check:** screenshots from a scripted run at 1280×720 show the thief at its burrow from the preset start, the "!" warning, the spill, the carried-coin indicator, the interception drop, and the escape, with the gold counter matching the ledger. A HUD bug found this way was fixed: the status line did not update when the thief changed state. Not checked: launching with F5 from the editor (the default main scene was launched from the command line instead), audio, and how readable any of this is to a player.

**Known limitations and risks:**
- With 3 spilled coins, recovering all of them before the thief claims one needs near-optimal play. Chasing immediately is easy at these values. Both are tuning questions for the playtest.
- The thief cannot leave the pocket, so a King in the passage cannot be reached until it gives up.
- Level coins `North1` and `North2` are inside the pocket and can add gold mid-trial; the ledger counts them, but results then differ from a clean preset run.
- A King who runs between the thief and its burrow can intercept it easily. That is allowed as deliberate play.
- The `trial_light/loaded/heavy` action names come from P003.
- Quitting the headless test while effects are still animating prints engine leak warnings at exit. These come from the test harness, not gameplay.

### 12. Observations

#### Human Playtest 1 — Quon (build `f5aa84d`)

Recorded from Quon's player report. No individual printed trial result lines were supplied, so there are no recorded trial counts, outcomes per run, or ledger values for this playtest.

- Most natural response to the thief: avoid it.
- Collecting gold was not discouraged by the encounter.

### 13. Player Comments

#### Human Playtest 1 — Quon (player report)

| Category | Rating (1–5) |
|---|---|
| Thief warning readability | 5 |
| Gold loss clarity | 5 |
| Theft fairness | 5 |
| Chase enjoyment | 4 |
| Gold recovery satisfaction | 4 |
| Overall encounter enjoyment | 4 |

| Question | Answer |
|---|---|
| Was gold collection discouraged? | No |
| Most natural response | Avoid the thief |

- Quon found avoiding the enemy and attempting to recover stolen gold enjoyable.
- Quon wants to expand the mechanic eventually.

### 14. What Worked

Human Playtest 1:
- The warning and the gold loss were clear (5/5 each).
- Theft felt fair (5/5).
- Chasing (4/5) and recovering gold (4/5) were enjoyable; overall encounter enjoyment 4/5.
- The encounter did not discourage collecting gold.

### 15. What Did Not Work

Human Playtest 1: no specific problems were reported. Chase enjoyment, recovery satisfaction, and overall enjoyment rated 4/5 rather than 5/5; no reasons were recorded.

### 16. Interpretation

One tester, one short encounter; treat as directional.

- The placeholder telegraph and spill feedback were enough to make the threat and the loss understandable.
- A small, recoverable loss caused by a visible external actor felt fair and did not make gold less desirable. This supports the 2026-11-14 Approved Direction that accumulated wealth can create external danger.
- Avoidance was the tester's natural first response. How often chases or recoveries happened was not recorded.

### 17. Unexpected Findings

Human Playtest 1: avoidance, rather than chasing or recovering, emerged as the tester's preferred natural response.

### 18. Outcome

**Outcome:** Iterate — promising external-threat mechanic; future expansion deferred.  
**Confidence:** Medium for the tested short encounter.

Conclusions:
- The warning and gold-loss feedback were understandable.
- Theft felt fair to the tester.
- Chasing and reclaiming gold were enjoyable.
- Avoidance emerged as the tester's preferred natural response.
- The encounter did not discourage further gold collecting.
- These findings support the approved direction that accumulating wealth can create external danger.

Limitations:
- One human tester.
- One thief and one encounter layout.
- No long-expedition testing.
- No wealth-based threat escalation.
- No final enemy AI or production balancing.

P004 is not marked fully Validated. The thief behavior, spill and theft caps, and timings remain Prototype Assumptions (spec §9).

### 19. Decision Impact

- No decision changes. The 2026-11-14 Approved Direction (*Gold Power With Wealth-Driven External Danger*) is supported by this evidence but not otherwise altered. Gold spill and theft remain Prototype Assumptions.
- **Deferred (not approved for implementation):**
  - More varied thief behaviors.
  - More interesting chase and recovery interactions.
  - Different enemy types.
  - Longer expedition behavior.
- **Open Questions:**
  - Whether and how threat escalates with wealth (out of scope for P004; already open under the 2026-11-14 decision).
  - Avoidance and stealth opportunities, given that avoidance was the natural response.
  - What incentives make recovering lost gold worthwhile.

### 20. Next Test

No further P004 iteration is planned for this cycle; expansion is deferred. Any future work on the items in §19 needs its own specification and review. P005 planning should treat the P004 encounter as tested evidence for a small, readable external threat, not as an approved enemy design.

---

# Planned Prototype 005

## P005 — Mini Expedition & Extraction

**Status:** Concluded for the current prototype cycle (2026-11-15). Outcome: Iterate (§18). Not fully Validated.  
**Date Started:** 2026-11-15  
**Date Concluded:** 2026-11-15  
**Build / Commit:** `d86c267` (branch `feat/p005-mini-expedition-extraction`)  
**Testers:** Quon (Human Playtest 1). Quon is the only recorded human tester.  
**Related Decision(s):**
- Gold Power With Wealth-Driven External Danger (Approved Direction, 2026-11-14)
- Losing Unsecured Gold and Treasure (Prototype Assumption; P005 implements voluntary extraction and P004 theft loss only, not expedition failure)
- Expedition and Settlement Gameplay Loops (Approved Direction; P005 tests only the expedition half, with no settlement)
- P001 movement baseline; P002 working collection baseline; P004 thief encounter (Iterate) reused as tested evidence, not as approved enemy design. P003 is not inherited.

**Related Feature Spec:** `docs/features/p005_mini_expedition_extraction.md`

### 1. Primary Design Question

Can a short expedition combining exploration, gold collection, external danger, and voluntary extraction create a satisfying gameplay loop that the player wants to repeat?

### 2. Hypothesis

From the spec: a small authored area with nearby gold, a safer branch, and a richer branch guarded by the P004 thief will tempt the player to venture farther, and choosing to return to camp to secure the haul will feel meaningful even without persistent progression.

### 3. Why This Matters

P005 is the first test of the expedition half of the approved gameplay loop. P001–P004 tested movement, collection, burden, and theft in isolation; P005 tests whether they combine into a return-or-continue decision the player wants to repeat.

### 4. Prototype Scope

Approved by Quon (2026-11-15):
- One compact authored area with two optional branches, built on the P001 arena.
- 25 ordinary one-value gold pickups.
- One reused P004 thief encounter with unchanged tuning.
- A recognizable camp where the King starts and where extraction happens only on a deliberate interact press.
- A results panel showing secured gold, and a fresh expedition with nothing carried over.

### 5. Out of Scope

Combat, health, or damage; more than one enemy, respawning, or threat scaling; P003 speed penalties; expedition failure or loss of the whole haul; banking, saving, upgrades, settlement, or inventory; procedural generation or multiple areas; timers; equipment, relics, or heavy gold; new story canon; audio and visual polish.

### 6. Variables Being Tested

Whether the layout invites exploration of both branches; whether the thief's presence affects when the player returns; whether extraction is understood as a deliberate choice; whether securing the haul is satisfying without persistence; whether the player wants another run.

### 7. Controls / Things Held Constant

- King movement is P001's: 5.0 m/s top speed, acceleration 80, deceleration 120, at every gold amount.
- P002 pickups, collection trigger, gold counter, pouch, and pickup feedback are unchanged.
- P004 thief tuning, ledger, spill, theft, interception, and recovery rules are unchanged; only its movement zone and the spill landing bounds were fitted to the new chamber.
- Every expedition starts from the same authored state.

### 8. Success Signals

From spec §9 (directional, not hard gates): the loop is understood without substantial coaching; gold discovery encourages exploration; extraction is recognized as a deliberate action; returning feels like securing something valuable; the player wants another expedition; and there is at least some observable consideration of whether to return or continue.

### 9. Failure Signals

The player never perceives a reason to consider returning early; extraction is confusing or feels like an arbitrary end; the thief dominates the experience; or the player has no interest in another run. A player collecting every coin is not automatically a failure (spec §9).

### 10. Optional Measurements

One printed `P005 expedition` line per extraction (secured, lost to thief, left on ground, not found, gold collected per area, time), the printed `P004 trial` line when the thief encounter ends, and the seven ratings from spec §9.

### 11. Test Setup

**Scene:** `game/prototypes/p005_mini_expedition_extraction.tscn`. It is the project main scene, so F5 launches P005. P001–P004 scenes remain available to open directly and are unchanged.

**Architecture (approved Option B):** the scene inherits the P001 arena, player, and camera, not the P004 or P002 scenes, so it carries none of P002's 20 coin positions or P004's encounter marker layout. The controller script extends the P004 controller (script chain P002 → P004 → P005), reusing P002's gold total, HUD, pouch, and pickup sound and P004's ledger, transfers, and thief wiring without copying them. Required by the inherited scripts, the scene provides the P002/P004 nodes they look up, re-created locally (gold label, pouch, pickup sound, thief, burrow, spill-coin root, spill sound). Two of these are compatibility-only and unused in normal play: the `EncounterStart` marker (placed at camp) and the P004 test status line (hidden; **Show Test HUD** still works). P005 overrides P004's input handler without calling it, so the 1 / 2 / 3 presets do nothing in P005 (they remain in the P003 and P004 scenes).

**Layout (P005-local changes; the P001 scene file is unchanged):**
- `DividerWest` shortened to x −12.5…5, opening a 2.5 m **west gap** at x −15…−12.5.
- New `NorthSplit` wall at x −1 (1 m thick) from the divider to the north wall, splitting the north area into two chambers. The north-west chamber is reachable only through the west gap; the north-east chamber only through P001's existing 1.5 m central passage.

| Area | Location | Gold |
|---|---|---|
| Camp | Disc of radius 2.5 m at (0, 11.5), with a red banner landmark; the King starts at its centre | 4 coins just north of the disc |
| West trail | From camp toward the west gap, around `LowBlockA` | 3 |
| East trail | From camp toward the central passage | 2 |
| Branch A (north-west chamber, safer) | Around the existing north pillar; no thief | 6 |
| Branch B (north-east chamber, thief) | 2 lure coins near the passage exit, outside the thief's 9 m trigger; an 8-coin cluster (4 × 2) about 2.5–4 m from the burrow, inside it | 10 |
| **Total** | | **25** |

Approximate walking distances at 5 m/s: camp to the central passage about 18 m; camp to the west gap about 22 m; a full tour of both branches took about 35 s in the scripted run.

**Thief:** one P004 thief and burrow at (13.5, 0, −13.5). Its movement zone is now (0, −14.6) to (14.6, −7.4) and spilled coins land within (0.4, −14.3) to (14.3, −7.7), so neither can reach Branch A or the passage. All P004 timings, speeds, radii, and caps are unchanged (see the P004 entry §11). One encounter per expedition; once it ends, the north-east chamber is safe for the rest of the run.

**Extraction:** a new `interact` action (keyboard **E**, gamepad button 0 / bottom face button). Inside the 2.5 m extraction radius a prompt reads "E — Secure haul and end expedition" (or "A (bottom button) — …" after controller input). Only an interact press inside the radius extracts; walking through or standing in camp never does, and extraction works with any amount of gold, including zero. A successful extraction sets the extracted state, takes a one-time results snapshot, pauses the scene tree (stopping the King, pickups, spilled coins, and the thief), and shows the results panel. Later presses, including repeated E and a second call in the same frame, are refused. Input is handled before physics in a frame, so no pickup or thief event can land between the snapshot and the pause.

**Gold accounting:** P004's ledger is unchanged; in P005 the haul always starts at 0. The controller also counts level gold through each pickup's own `collected` signal, and `expedition_ok()` checks `carried + spilled on the ground + thief-held + lost + uncollected level gold = 25`. At extraction the 25 units are classified as:

| Result | Meaning |
|---|---|
| Secured | Gold the King carries at that moment |
| Lost to the thief | Gold it escaped with, plus any gold it still holds (forfeited for this run) |
| Left on the ground | Spilled or dropped coins not recovered |
| Not found | Level coins never collected |

**Results panel:** "Expedition complete", **Gold secured** (large), "Lost to the thief" and "Left on the ground" (each only when above 0), the expedition time as m:ss, the note "Each expedition starts fresh — nothing is carried over.", and a **New Expedition (R)** button. Time is shown only here; there is no clock during play. After 0.5 s the button takes focus, so Enter, Space, or gamepad button 0 can press it without the extracting press skipping the results.

**Replay:** New Expedition, or R on the results panel, unpauses and reloads the scene. R during play abandons the run and reloads without a result. Everything resets because the scene is re-created: King position and velocity, gold, HUD and pouch, all 25 pickups, spilled coins, the thief's state, position, carried coin, and visibility, ledger and encounter flags, timer, extraction state, prompt, and panel. There are no autoloads or saved data, so nothing persists between expeditions.

**Controls:** WASD / arrows / left stick move. **E** (gamepad bottom button): extract at camp. **R** (gamepad Back): new expedition. 1 / 2 / 3 do nothing in P005.

**Starting values (Prototype Assumptions, exported or authored in the scene; none playtest-validated):**

| Parameter | Value |
|---|---|
| Camp centre / extraction radius | (0, 11.5) / 2.5 m (the disc is resized to the radius on start) |
| Gold | 25 one-value pickups: camp 4, west trail 3, east trail 2, Branch A 6, Branch B 10 |
| West gap / central passage width | 2.5 m / 1.5 m |
| Thief | P004 values: trigger 9 m, warning 1.0 s, approach 3.0 m/s, give-up 8 s, pause 0.5 s, grab/flee 3.5 m/s, spill cap 3, theft cap 1 |
| Results focus delay | 0.5 s |
| Test HUD | hidden |

**Mechanical validation (Godot 4.7.2, headless):** `tests/p005_regression.gd` passed **84 of 84** and exits non-zero on failure (checked with a deliberately wrong expectation). It covers:
- Initial state: 25 one-value pickups and the per-area counts, gold 0, King at camp, thief idle at its burrow, results hidden, not paused, prompt text, camp and extraction radius, `interact` bindings, P001 and P004 tuning unchanged, thief zone and spill bounds, and coin placement relative to the split and the trigger radius.
- 1 / 2 / 3 do not change gold or move the King.
- Geometry: the shortened divider still blocks, the west gap and central passage are passable, and `NorthSplit` separates the chambers from both sides.
- A scripted tour of both branches from camp and back collects all 25 coins with the HUD and pouch in sync; no automatic extraction after 5 s idle in camp with 25 gold; top speed 5.0 m/s (straight and diagonal) and unchanged acceleration and deceleration while carrying 25; camera offset unchanged.
- Extraction: prompt hidden and E refused just outside the radius; prompt shown and E accepted just inside; results 25 / 0 / 0 / 0; time recorded; results text; five more E presses, a direct second call, and 1 s of frames change nothing; the King cannot move; the button takes focus.
- New Expedition, R on the results panel, and R mid-run each restore an identical initial state.
- Zero-gold extraction; camp coins only (secured 4); Branch A (secured 11).
- Branch B: avoidance (thief warns, gives up, stays in its chamber; nothing lost); escape (lost 1, left 2); interception and recovery of all 3 spilled coins (recovered gold secured); extraction while the thief still holds a coin (forfeited as lost; same-frame second extraction refused; spilled coins cannot be recovered or pop afterwards; thief frozen).
- The final four categories sum to 25 in every extraction, and `not found` matches a direct count of the remaining pickups.
- The expedition-wide invariant held on every checked physics frame of scripted play (more than 1,000 frames).
- P001–P005 scenes instantiate.

`tests/p004_regression.gd` still passes 71 of 71 and `tests/p003_regression.gd` 114 of 114. One P004 check was changed: it asserted that P004 is the default scene, which stopped being true when P005 became the default; it now checks that the P004 scene is present. P001–P005 scenes run headless with no errors or warnings.

Scripted reference runs (not player performance):

| Run | Printed result |
|---|---|
| Both branches, thief held still | secured 25, not found 0, time 0:35 |
| Camp coins only | secured 4, not found 21 |
| Branch A | secured 11 (camp 2, west trail 3, Branch A 6) |
| Branch B, retreat after the warning | thief avoided; secured 6 |
| Branch B, standing still | thief escapes with 1; secured 3, lost 1, left 2 |
| Branch B, immediate chase, then recover | intercepted; all 3 spilled coins recovered; secured 6 |
| Extract while the thief holds a coin | secured 3, lost 1, left 2 |

**Windowed check:** screenshots from a scripted run at the default window size show the camp disc, banner, and prompt at start; the coin trail at the fork; the west gap; the north-west chamber around the pillar; the passage; the Branch B lures, the cluster, and the thief's "!" warning; the spill; the thief carrying a stolen coin; the return path; the results panel (secured 9, lost 1, left 2, time 0:25, with the note and button); and a clean reset after New Expedition. The controlled camera shows the King, nearby gold, the thief, and the encounter clearly. Not checked: launching with F5 from the editor (the main scene was launched from the command line instead), controller input, audio, and how readable any of this is to a player.

**Known limitations and risks:**
- The follow camera shows only a small area around the King, so neither branch opening is visible from camp (confirmed in the screenshots); the coin trails do the guiding. Whether players notice both branches is a playtest question.
- The thief can take at most 1 of 25 coins and appears once per expedition, so the risk may be too small to create return-or-continue tension (spec Risk A). Recorded, not compensated.
- After the encounter ends, Branch B is safe for the rest of the run.
- The 2.5 m dividers block the elevated camera's view of a strip of floor just north of them, as the same walls did in P004. The coins nearest the dividers were visible in the screenshots, but this was not checked from every position.
- Gold secured is a per-run result; whether this feels consequential without persistence is a playtest question (spec Risk D).
- The P005 controller depends on the P004 controller's node paths and functions. P004 is concluded and its tests guard it; any future change to the P004 scripts must rerun both tests.

### 12. Observations

#### Human Playtest 1 — Quon (build `d86c267`)

Recorded from Quon's player report. No individual `P005 expedition` Output lines were supplied, so there are no recorded per-run results (secured, lost, left on the ground, not found, time) or trial counts for this playtest.

- Both optional branches were explored.
- The player did not extract before collecting everything.
- The player felt tempted to continue exploring.
- The thief affected the decision about returning.

### 13. Player Comments

#### Human Playtest 1 — Quon (player report)

| Category | Rating (1–5) |
|---|---|
| Exploration enjoyment | 4 |
| Gold discovery and collection | 4 |
| Threat tension | 4 |
| Extraction clarity | 3 |
| Satisfaction of securing the haul | 3 |
| Overall expedition enjoyment | 4 |
| Desire to play another expedition | 3 |

| Question | Answer |
|---|---|
| One or both branches explored? | Both |
| Extracted before collecting everything? | No |
| Tempted to continue exploring? | Yes |
| Did the thief affect the decision to return? | Yes |

- Avoiding the thief and recovering stolen gold were enjoyable.
- Quon wants more enemies, interesting discoveries, and longer routes in future expeditions.
- Quon wants a meaningful reward for returning with more gold.

**Clarification (Quon, after the playtest):** the 3/5 extraction-clarity rating primarily reflected extraction not feeling rewarding enough. It is **not** evidence that the player failed to understand the extraction controls or prompt. The original rating is kept unchanged above.

### 14. What Worked

Human Playtest 1:
- Exploration (4/5), gold discovery and collection (4/5), and threat tension (4/5) were positive; overall expedition enjoyment 4/5.
- Both optional branches were explored.
- The player felt tempted to continue, and the thief affected the decision about returning.
- Avoiding the thief and recovering stolen gold were enjoyable.

### 15. What Did Not Work

Human Playtest 1:
- Securing the haul was only moderately satisfying (3/5). Per Quon's clarification, the extraction-clarity rating (3/5) also mainly reflects extraction not feeling rewarding enough.
- Desire to play another expedition was moderate (3/5).
- Quon wants a meaningful reward for returning with more gold.

### 16. Interpretation

One tester, one session, player report only; treat as directional.

- Exploration, gold collection, and the existing thief encounter appear to combine into a promising short expedition.
- The return-or-continue decision showed some signal: the player was tempted to continue and weighed the thief when deciding when to return. However, the player collected everything before extracting, so an early-return choice was not observed. Whether that reflects the small thief risk (at most 1 of 25 coins, once per run; spec Risk A) or the lack of reward for securing gold is not established.
- Extraction appears to have been understood. Its weakness is that a secured haul with no further use did not feel meaningful (spec Risk D). This may also limit replay desire, but that link is unconfirmed.

### 17. Unexpected Findings

Human Playtest 1: after the playtest, Quon clarified that the extraction-clarity rating was mainly about reward rather than understanding (§13).

### 18. Outcome

**Outcome:** Iterate — promising combined expedition loop; extraction rewards need further development.  
**Confidence:**
- Medium overall for short-session expedition enjoyment.
- Low-to-medium for the strength of the return-or-continue decision and long-term replayability.

Conclusions:
- Exploration, gold collection, and the existing thief encounter work promisingly together.
- Both optional branches were explored.
- The player experienced temptation to continue and considered the thief when deciding when to return.
- The player did not extract early.
- Extraction was understood, but the secured haul did not provide enough meaningful reward.
- Replay motivation was moderate.
- This prototype supports further development of the expedition loop.

Limitations:
- One recorded human tester.
- One compact authored area.
- One thief encounter per expedition.
- Maximum theft loss remains one gold.
- No persistent reward or progression.
- No longer expedition or additional encounter variety tested.
- No recorded individual trial result lines.

P005 is not marked fully Validated. The layout, gold counts, thief tuning, extraction prompt, and results UI remain Prototype Assumptions.

### 19. Decision Impact

- No decision changes. The *Expedition and Settlement Gameplay Loops* and *Gold Power With Wealth-Driven External Danger* Approved Directions are supported by this evidence but not otherwise altered. *Losing Unsecured Gold and Treasure* remains a Prototype Assumption; P005 did not test expedition failure.
- **Strong Recommendation (not approved):** investigate one meaningful benefit for successfully extracted gold before significantly expanding expedition size, enemy variety, or progression systems.
- **Open Questions:**
  - The exact reward or benefit gained from securing gold.
  - Whether higher secured hauls produce proportionally greater benefits.
  - How rewards affect replay desire.
  - More meaningful return-or-continue tension.
- **Deferred (not approved for implementation):**
  - More interesting discoveries and optional detours.
  - Longer expedition routes.
  - Additional external threats.
- **Not approved by this closeout:** a persistent economy, settlement upgrades, new enemies, larger environments, reward formulas, or a P006 feature scope. These require separate design review.

### 20. Next Test

No further P005 iteration is planned for this cycle. The next experiment is not yet scoped. Per the Strong Recommendation in §19, the reward for securing gold is the suggested first question for review; any follow-up needs its own specification and approval.

#### Human Playtest 1 plan (pre-playtest, kept for history)

**Human Playtest 1** (spec §9):
1. Launch the project with F5; it opens P005 at camp. Use keyboard or a controller.
2. **Pass A — natural expedition:** give minimal explanation ("explore, and come back to camp when you want to finish"). Do not coach extraction timing or tell the tester to collect everything. Observe where they go first, whether they notice both branches, how they respond to visible gold and to the thief, when they return, and whether they understand how to extract.
3. **Pass B — different strategy:** start a New Expedition and ask for a different route or approach. Compare exploration choices, extraction timing, and reaction to the thief.
4. After each run, copy the `P005 expedition` line (and any `P004 trial` line) from the Godot Output panel.
5. Rate 1–5: exploration enjoyment; gold discovery and collection satisfaction; external-threat tension; return-to-camp extraction clarity; satisfaction of securing the haul; overall expedition enjoyment; desire to play another expedition.
6. Record: one or both branches explored; whether they extracted before collecting everything, and why; whether the thief affected the decision to continue or return; whether they felt tempted to pursue more treasure; whether they immediately wanted another run; anything incomplete, repetitive, or confusing; and whether audio and controller input worked.

Report enjoyment and the strength of the return-or-continue decision separately.

---

# Planned Prototype 006

## P006 — Meaningful Extraction Rewards

**Status:** Concluded for the current prototype cycle (2026-11-16). Outcome: Iterate (§18). Not Validated; not production-ready.  
**Date Started:** 2026-11-15 (specification approved)  
**Date Concluded:** 2026-11-16  
**Build / Commit:** `fcd69da` (branch `feat/p006-meaningful-extraction-rewards`)  
**Testers:** Quon (developer) and two coworkers outside the development team: three people in total. Findings were summarized by Quon on 2026-11-16; no individual playtest transcripts, ratings, or Output lines were supplied.  
**Related Decision(s):**
- Immediate Prototype Priority: Extraction Rewards (P006) (Approved Direction, 2026-11-15)
- Expedition and Settlement Gameplay Loops (Approved Direction)
- Light, Primarily Automated Settlement Progression (Approved Direction, reaffirmed 2026-11-15)
- Gold Power With Wealth-Driven External Danger (Approved Direction, 2026-11-14)
- Losing Unsecured Gold and Treasure (Prototype Assumption; not tested by P006)
- P005 (Iterate) reused as the expedition baseline; its findings are unchanged.

**Related Feature Spec:** `docs/features/p006_meaningful_extraction_rewards.md`

### 1. Primary Design Question

Does giving gold brought home from an expedition a persistent, meaningful use make extraction more satisfying and make the player want to embark on another expedition?

The spec asks for three outcomes to be evaluated separately: (1) extraction satisfaction, (2) replay motivation, and (3) whether the 20-gold purchase goal affects return-or-continue decisions.

### 2. Hypothesis

From the spec: securing gold into a persistent in-session treasury, recruiting a merchant who then appears at camp, and spending secured gold on a first sword with a small functional use will make extraction feel like an accomplishment and create a desire to depart again. The purchase goal may or may not change when the player chooses to return; improving the first two outcomes without the third would be a mixed but useful result.

### 3. Why This Matters

P005 (Iterate) found that the expedition loop was promising but that a secured haul with no further use did not feel rewarding (satisfaction of securing the haul 3/5; desire for another expedition 3/5, one tester). P006 is the first test of the settlement half of the approved expedition ↔ settlement loop and the first time secured gold has any persistent use.

### 4. Prototype Scope

Approved by Quon (spec, 2026-11-15), as Prototype Assumptions for testing:
- A small, separate playable camp hub with the King's tent, a treasury chest with an exact balance and coarse fill stages, a departure point, and a merchant stall that appears only after the merchant is discovered and an extraction succeeds.
- A P006 expedition derived from P005, with the 25 standard pickups and the P004 thief unchanged.
- An optional merchant in Branch A, recruited by interaction at zero gold cost, confirmed only by a successful extraction.
- Depositing the extracted haul into the treasury exactly once, with a results → treasury → hub return flow and voluntary redeparture.
- A one-item shop: the First Sword for 20 secured gold.
- One sword swing and two optional breakable treasure containers that release bonus gold after purchase.
- In-session persistence only.

### 5. Out of Scope

From spec §5: a combat system, fightable enemies, health, or damage; inventory or equipment frameworks; multiple items, stock, selling, or trading; city-builder features, workers, construction, or reputation; save/load or cross-launch persistence; new regions, enemies, or thief scaling; P003 movement slowdown; expedition failure or loss of secured treasury; production art, final merchant identity or dialogue, sword powers, or new story canon.

### 6. Variables Being Tested

Taken together, as one integrated reward loop (spec Risk 1): persistent secured treasury, visible hoard growth, merchant discovery and arrival, a purchasable sword with a 20-gold price, and a minimal functional use for the sword. The design does not isolate the effect of any one element.

### 7. Controls / Things Held Constant

- P001 movement and camera; ordinary carried gold does not slow the King.
- P005's 25 standard pickups, their layout, the two branches, camp extraction rules, and the P004 thief tuning, ledger, spill, theft, and recovery rules.
- The P005 scene and script are unchanged; P006 extends them in a separate derivative scene.

### 8. Success Signals

From spec §7 (directional, not hard gates): the player understands that returned gold remains available in the session; identifies a desirable purchase target; chooses to return and purchase; expresses satisfaction with ownership; willingly uses the sword and departs again; deposit and replay ratings improve over the player's own P005 report.

### 9. Failure Signals

From spec §7: merchant discovery eclipses extraction; repeated runs on the same map feel like grind; the treasury increase is unclear or less rewarding than the purchase itself; the sword feels like an arbitrary key; the player cannot understand where to go or why to buy the sword. **Inconclusive** if interface problems or bugs prevent a fair purchase/use experience, the merchant is never found, or too many changes make the result unexplainable.

### 10. Optional Measurements

One printed `P006 expedition` line per extraction (run, secured, treasury before → after, standard and bonus gold, thief losses, merchant met, time, sword ownership) and one `P006 purchase` line per purchase. The spec §7 table proposed ratings for deposit satisfaction and replay desire with a directional target of ≥4/5 against P005's 3/5.

None of these measurements was supplied for the human playtest (§12).

### 11. Test Setup

**Entry point:** `game/prototypes/p006_meaningful_extraction_rewards.tscn` is the project main scene (F5). Earlier prototypes open with Run Current Scene (F6).

**Structure (prototype scene split, not world architecture):** the session root (`p006_meaningful_extraction_rewards.gd`) holds the in-session state (treasury, merchant recruited, sword owned, run identity) and shows one child at a time: the camp hub (`game/prototypes/p006/camp_hub.tscn`) or an expedition (`game/prototypes/p006/expedition.tscn`). Nothing is written to disk; quitting resets everything. The expedition script extends the P005 controller and overrides only the P006 hooks; run on its own it falls back to P005 reload behaviour.

**Camp hub:** the King's tent, a treasury chest with a caption and a HUD line showing the exact balance, three hoard piles beside the chest that appear at 1, 10, and 20 spendable gold (so they shrink after a purchase), an "Expedition Road" departure point, and a merchant stall that is hidden until recruited. Interact (E / gamepad bottom button) within 2.2 m departs or opens the shop. A notice reports arrivals (for example, the merchant joining). A HUD line "First Sword — owned" appears once the sword is bought; the sword itself is not shown on the King in the hub.

**Expedition:** P005's layout, 25 pickups, thief, and manual extraction at the field camp, starting each run with 0 carried. Additions:
- **Merchant** in Branch A's north-west chamber. Interact invites them ("I'll set up at your camp — if you make it back."); recruitment costs nothing and is confirmed only by a successful extraction, including a 0-gold extraction.
- **Two treasure containers:** one on the east trail (visible before the sword is owned) and one in Branch B. Only the sword opens them, once each per run; each releases **3** bonus coins that must be collected like ordinary gold.
- **Results:** gold secured, the treasury as "before + deposited = after", gold lost to the thief, left on the ground, never picked up, bonus gold collected of generated, merchant news, time, and a **Continue to Camp** button. The deposit happens once, guarded by run identity.
- **Abandon:** R (gamepad Back) abandons the run, secures nothing, discards the pending merchant discovery, and returns to camp with a notice.

**Shop:** item and price ("First Sword — 20 gold"), current treasury, and **Buy (20 gold)**, **Not enough gold (need N more)**, or **Owned**, with **Close (Esc)**. A purchase subtracts exactly 20 once. A 0.3 s focus delay prevents the opening press from buying.

**Sword:** a provisional `attack` action — J or Space, gamepad west face button (X). One swing with a 0.3 s cooldown and a small sphere hit (1.1 m reach) on the side the King faces. It only opens P006 containers; there are no enemies or damage.

**Panel input fix (`fcd69da`):** Space is bound to both `attack` and Godot's built-in `ui_accept`, so it could press a focused Buy or Continue button. While a P006 shop or results panel is visible, keys that are both `attack` and `ui_accept` are now consumed, and the gamepad interact button presses the focused enabled button (the project's `ui_accept` has no gamepad binding). Enter and mouse clicks are unchanged. P001–P005 input is unchanged.

**Gold accounting:** the P004 ledger is unchanged. Loose bonus coins are tracked separately; once collected they are ordinary carried gold. The P006 invariant checked each frame is: carried + spilled on ground + thief-held + lost + uncollected standard + loose bonus = 25 + bonus generated.

**Starting values (Prototype Assumptions; none playtest-validated):**

| Parameter | Value |
|---|---|
| Sword price | 20 secured gold |
| Bonus gold per container | 3 (2 containers; 6 per sword-owned run) |
| Hoard pile thresholds | 1, 10, 20 spendable gold |
| Hub interact radius / merchant interact radius | 2.2 m / 2.0 m |
| Sword cooldown / reach | 0.3 s / 1.1 m |
| Shop focus delay | 0.3 s |
| Arrival notice duration | 5.0 s |
| P005 / P004 values | unchanged (see the P005 entry §11) |

**Mechanical validation (previously reported; not rerun during this closeout):** the implementation report for `fcd69da` stated that the committed headless regression suites passed under Godot 4.7.2:

| Suite | Passed | Failed |
|---|---:|---:|
| `tests/p003_regression.gd` | 114 | 0 |
| `tests/p004_regression.gd` | 71 | 0 |
| `tests/p005_regression.gd` | 84 | 0 |
| `tests/p006_regression.gd` | 161 | 0 |
| **Total** | **430** | **0** |

`tests/p006_regression.gd` covers, per its own description, session state, scene transitions, deposits and their idempotency, abandon, merchant recruitment and arrival, shop affordability (19 / 20 / 21+ gold, repeat purchase, accumulation across runs), sword ownership and use, containers, and bonus-gold conservation. It is mechanical only. During the 2026-11-16 closeout, Godot was not available in the closeout environment, so these counts are attributed to the prior implementation report and were **not** independently revalidated.

**Known limitations:**
- Persistence lasts only for the current game session.
- The sword performs a minimal container-breaking interaction, not combat against enemies.
- UI communication and sword-ownership visibility need later improvement (see §15).
- Some regression runs produced resource-cleanup warnings at exit (reported, not investigated in this closeout).
- Exact mouse-click behaviour on the P006 panels was not confirmed by the automated input tests, and there is no record that it was checked afterwards.
- The implementation is a prototype and is not production-ready.

### 12. Observations

#### Human Playtest 1 — Quon and two coworkers (build `fcd69da`)

Recorded from Quon's summary (2026-11-16). This is secondhand for the two coworkers. No `P006 expedition` or `P006 purchase` Output lines, run counts, expedition times, gold totals, ratings, or replay counts were supplied, and there is no record of whether every tester completed every step of the spec §7 plan.

- One coworker took longer than expected to work out where to go to begin the first expedition.
- One coworker wondered where the purchased sword was; its visual and function appear only once the player enters an expedition.
- The testers encountered some uncertainty about what to do. No major gameplay blockers were reported.

### 13. Player Comments

#### Quon (player report)

- Enjoyed the overall P006 gameplay loop more than P005.
- Liked seeing the settlement gain more features.
- Having a functional merchant made the camp more interesting and useful.
- Purchasing the first sword was enjoyable.
- Seeing the gold hoard grow after a successful extraction was satisfying.
- Seeing the hoard become smaller after spending gold on the sword was also interesting.

#### Two coworkers (reported by Quon)

- Generally liked the game.
- Usability points are recorded in §12. No direct quotations were supplied.

No numerical ratings were given for P006. The P005 numerical baseline (one tester, Quon) is unchanged and was not re-measured.

### 14. What Worked

- **Mechanical:** the integrated loop — exploration, gold collection, extraction, secured treasury, merchant recruitment, purchase, and a functional sword reward — worked end to end in previously reported regression tests and in human play, with no major blockers reported.
- **Player report (Quon):** the overall loop was more enjoyable than P005; returning to a camp that gains features, a useful merchant, buying the sword, and watching the hoard grow (and shrink after spending) were all positive.
- **Player report (coworkers, secondhand):** generally liked the game.

### 15. What Did Not Work

- Finding the way to begin the first expedition was slow for one coworker (departure-point readability / camp navigation).
- Sword ownership was not obvious in the camp: one coworker wondered where the sword was because it only appears in the expedition. The hub shows only a HUD text line.
- Testers were sometimes uncertain what to do.
- The sword is a key for containers, not a weapon used against anything (expected limitation, spec Risk 5).
- No measurements were recorded to compare against P005 or the spec's directional targets.

### 16. Interpretation

Three testers, one summarized report, no ratings or Output lines; treat as directional.

- **Integrated loop (supported, medium confidence):** the positive reports on returning to camp, watching wealth accumulate, and spending it on something useful suggest the expedition-to-settlement reward loop is a promising structure. Quon's statement that P006 was more enjoyable than P005 supports this, but it is one developer's comparison, not a measured improvement.
- **Hypothesis 1 — extraction satisfaction:** directionally supported by Quon's report that hoard growth after extraction was satisfying. Not measured against the P005 3/5 baseline.
- **Hypothesis 2 — replay motivation:** not established. No redeparture counts or ratings were recorded; the reported enjoyment of the loop is suggestive only.
- **Hypothesis 3 — return-or-continue decisions:** not established. There is no evidence about whether the 20-gold goal changed when anyone extracted, and no evidence of early extraction.
- **Attribution:** the merchant, hub, treasury, hoard visuals, and sword arrived together (spec Risk 1). The evidence cannot isolate which element produced the positive response.
- **Usability:** the reported confusion points to camp navigation and equipment feedback rather than to the reward concept itself, but this is an interpretation of a summary, not an observed cause.

### 17. Unexpected Findings

- Quon found the hoard **shrinking** after the purchase interesting, not just its growth. The spec had flagged the falling spendable balance as a risk to communicate (spec Risk 6); in this report it was a positive.
- The missing sword in camp was noticed by a tester even though a HUD text line shows ownership; a text line alone may not communicate ownership of a physical item.

### 18. Outcome

**Outcome:** Iterate — current prototype cycle concluded.  
**Confidence:**
- **Medium** for the promise of the integrated expedition-to-settlement reward loop.
- **Low** for isolating the effect of individual reward elements, measuring replay motivation, or determining the influence on return-or-continue decisions.

Conclusions:
- P006 demonstrated a mechanically functioning integrated progression loop connecting exploration, gold collection, extraction, persistent treasury wealth, merchant recruitment, purchasing, and a functional sword reward.
- Early human feedback was positive, especially about the value of returning to camp, seeing wealth accumulate, and spending it on something useful.
- The feedback supports continuing development of the expedition-to-settlement structure.
- The evidence does not independently validate all three original hypotheses, and the prototype has expected usability and presentation limitations.

Limitations:
- Three testers; findings summarized by one developer; no transcripts, ratings, Output lines, run counts, or times.
- No measurement of voluntary redeparture or early extraction.
- All reward elements introduced together.
- One short, known map repeated.
- In-session persistence only; no combat; the sword only opens containers.
- Regression counts are from the prior implementation report and were not rerun at closeout.

No additional P006 iteration is planned for the current cycle. Quon reviewed the results and agreed that further P006 polish is unnecessary before the next prototype.

### 19. Decision Impact

- **Supported (no change in status):** the existing Approved Directions on gold as a desirable and meaningful resource (*Gold Power With Wealth-Driven External Danger*; P006 did not test external danger), complementary expedition and settlement phases (*Expedition and Settlement Gameplay Loops*), and a persistent, lightly automated settlement that develops through player accomplishments (*Persistent Settlement Without City-Builder Maintenance*; *Light, Primarily Automated Settlement Progression*).
- **Not promoted — remain Prototype Assumptions:** the merchant's identity and recruitment process; the 20-gold sword price; the sword's current attack behaviour; treasure-container gold rewards; treasury visual thresholds; the session-root architecture and scene transitions; the shop interface.
- **Promising directions, production implementation open:** a functional merchant at the settlement and visible wealth progression.
- **Open Questions:**
  - Whether a persistent use for gold changes when players choose to extract (hypothesis 3).
  - How strongly the reward loop drives voluntary replay (hypothesis 2).
  - Which elements (treasury, hoard visuals, merchant, purchase, sword use) carry the effect.
  - How the settlement should communicate where to go and what the player owns.
  - The production economy: prices, item categories, merchant roster, persistence model.
- **Deferred (not approved for implementation):** fixes for the departure-point/navigation, sword-ownership, and general UI-guidance issues in §15. These are recorded for future UI, navigation, equipment-feedback, or presentation work.
- **Not approved by this closeout:** a permanent merchant or economy system, settlement upgrades, save/load, or any change to the Decision Log or Gameplay Foundation.

### 20. Next Test

No further P006 iteration is planned for this cycle.

**Strong Recommendation (not approved):** the next major investigation should be a **Combat Foundation** prototype. Potential research question:

> Can a responsive basic weapon attack against a fightable enemy create enjoyable, readable combat within GoldKing's existing 2.5D presentation?

No prototype number, specification, or implementation is assigned here. Any combat prototype needs its own specification and approval.

---

# Prototype 007 (in progress)

## P007 — Combat Foundation

**Status:** In progress. **No outcome assigned; P007 is not concluded.** Human Playtest 1 is recorded below as the baseline for Iteration 1.  
**Date Started:** 2026-11-16 (specification approved; implementation authorized)  
**Build / Commit (Human Playtest 1):** `706c9d5` (branch `feat/p007-combat-foundation`; Godot 4.7.2)  
**Iteration 1 branch:** `feat/p007-target-focus`, branched from `706c9d5`  
**Testers so far:** Quon (developer), one tester.  
**Related Feature Spec:** `docs/features/p007_combat_foundation.md` (Iteration 1: §10)

The remaining sections of the standard 20-section format (measured data, interpretation, outcome, confidence, decision impact, next test) are completed only when P007 closes.

### 1. Primary Design Question

> Can one responsive directional sword attack, a brief invulnerable dodge, and one readable melee enemy produce an enjoyable combat exchange within GoldKing's existing 2.5D presentation?

### Test Configuration — Human Playtest 1

Build defaults at `706c9d5` (the spec starting values, unchanged): sword 110°, 1.4 m, windup/active/recovery 0.08/0.12/0.20 s, dodge cancel in the last 0.10 s of recovery; dodge 1.75 m in 0.20 s, invulnerable 0.04–0.16 s, cooldown 0.70 s from dodge start; King health 3; enemy health 3, speed 3.0 m/s, trigger range 1.5 m, windup 0.50 s (direction commits at 0.25 s), strike 0.15 s (1.8 m, 90°), recovery 0.60 s. Eight-direction movement-based facing. No `P007 encounter` Output lines or attempt counts were supplied for this playtest.

### 12. Observations

#### Human Playtest 1 — Quon, developer (build `706c9d5`)

Developer playtest observations as reported by Quon (2026-11-16). They are not independently verified technical defects.

- Combat was enjoyable in principle but felt clunky and awkward.
- Movement-based facing made it difficult to attack in the intended direction.
- Retreating caused the King to face away from the enemy.
- The player sometimes ran past the enemy while attempting to attack.
- The dodge worked mechanically but was difficult to interpret visually.
- Enemy attack readability was weak.
- Better animations and effects may eventually improve clarity, but this has not been demonstrated.

### 13. Player Comments

#### Quon — ratings (Human Playtest 1)

| Dimension | Rating |
|---|---|
| Overall combat enjoyment | 3/5 |
| Sword responsiveness | 3/5 |
| Attack direction and accuracy | 2/5 |
| Dodge feel | 2/5 |
| Enemy attack readability | 2/5 |
| Desire to fight again | 2/5 |

One tester; small-sample developer ratings. The spec's tentative supportive target (4/5 or better for responsiveness and overall exchange enjoyment) was not reached in this playtest.

### Iteration 1 — Lightweight Target Focus (approved 2026-11-16)

**Research question:** Does lightweight target focus improve directional melee control and combat enjoyment compared with P007's original eight-direction movement-based facing?

**Motivation:** the Playtest 1 facing observations above (attack direction 2/5; retreating turns the King away; running past the enemy).

**Variable being tested:** the source of the King's facing. Mode A: movement input (original baseline, unchanged). Mode B: optional toggleable focus on the single enemy; while focused, the direction toward the enemy chooses the facing.

**Held constant:** eight-direction snapping, sword timing/reach/arc/damage and attack-direction snapshot, dodge (including neutral dodge along current facing), enemy behavior, arena, camera, and spawns. See spec §10 for the full constraints and exclusions.

**Deliberate constraints to observe, not fix:** a neutral dodge while focused travels toward the enemy and may be stopped by its body; snapped focused facing may alternate between neighbouring directions when the enemy sits near a 22.5° boundary.

**Technical findings (implementation, 2026-11-17; automated and developer windowed checks only, not human evidence):**
- Mode A keeps the original behavior: all 159 original P007 regression checks pass unchanged, and the scripted play-style diagnostic gives the same results as before Iteration 1.
- Mode B mechanics verified by 107 added checks: acquire at ≤ 7.0 m, release by press / beyond 9.0 m / enemy defeat / enemy removal / King defeat, no release flicker inside the 7–9 m band, eight-direction snapped target facing, swing direction locked at start, unchanged reach/arc/timings, no movement toward the target, dodge timings and cancel window unchanged while focused.
- Scripted retreat-and-attack at 0.9 m: hits when focused; the same input in Mode A turns the swing away and misses.
- Neutral focused dodge travels toward the enemy and stops at its body (0.90 m centre gap), as intended by the Amendment B constraint.
- Near a 22.5° boundary the snapped cue and swing visibly point beside the enemy (for example, enemy 23° off up: facing up-right, 45°).
- The overhead focus marker left the top of the screen when the enemy was about 5 m or more up-screen; a cyan ground ring under the enemy was added so focus stays visible. At the spawn distance the enemy and ring sit under the top HUD text (pre-existing camera framing).
- Not verified: physical keyboard Tab/F2 in a live window (synthetic OS keystrokes were blocked; the window's input path was exercised with injected key events), the editor's embedded Game view, and gamepad RB (no controller).

**A/B human comparison:** not yet performed. No Iteration 1 playtest result exists.

---

# Prototype Review Guidelines

## Test One Important Question at a Time

A prototype may contain several systems, but it should have one clearly stated primary question.

If the team cannot explain what result would change its mind, the test is probably too vague.

---

## Define Success Before Playing

Avoid deciding after the test that whatever happened was secretly the desired result.

Write success and failure signals before the first playtest whenever practical.

---

## Observe Behavior Before Asking for Opinions

For external tests:

1. Watch what the player does.
2. Record problems without immediately helping.
3. Note hesitation, confusion, repeated behavior, and workarounds.
4. Ask follow-up questions after observing the relevant interaction.

Do not lead players toward the answer the team wants.

---

## Record Both Positive and Negative Evidence

Do not use this log only for bugs and failures.

Knowing **why something works** is important when later changes risk damaging it.

---

## Avoid Changing Several Major Variables at Once

If damage, speed, enemy count, camera, controls, and gold thresholds all change simultaneously, it becomes difficult to identify why the next playtest feels different.

Early prototypes will sometimes require broad changes, but isolate important variables when possible.

---

## Prototype for Learning, Not Survival

Do not keep a prototype implementation simply because time was spent building it.

Prototype code may be:
- Kept,
- Rewritten,
- Simplified,
- or discarded.

The purpose of prototype code is to produce evidence.

Production architecture should be earned separately.

---

## Stop When the Question Is Answered

Do not polish a prototype indefinitely.

Once enough evidence exists to make the next decision, document the conclusion and move forward.

---

# Current Prototype Sequence

The current expected sequence is:

### P001 — Player Movement & Controlled Camera
Prove the chosen presentation and basic movement relationship.

### P002 — Gold Collection
Prove that collecting gold is readable and intrinsically satisfying.

### P003 — Gold Power vs. Burden
Test the central assumption that more wealth can create both greater power and greater danger.

*Concluded for the current cycle on 2026-11-14 (Iterate). The automatic movement-burden approach it tested was superseded by the wealth-driven external danger direction; see the P003 entry.*

### P004 — Gold Spill & Theft
Test whether combat can make losing and recovering gold create enjoyable urgency.

*Concluded for the current cycle on 2026-11-14 (Iterate). Tested as a single thief with movement-based avoidance, chase, and recovery rather than combat; see the P004 entry.*

### P005 — Mini Expedition / Extraction
Combine exploration, gold accumulation, risk, optional treasure, and voluntary return into the first small version of the expedition loop.

*Concluded for the current cycle on 2026-11-15 (Iterate). The combined expedition loop was promising; extraction rewards need further development. See the P005 entry.*

### Planning Note (2026-11-15): Next Intended Investigation
- **P006** is the next intended prototype investigation (production priority approved by Quon; see Decision Log, 2026-11-15).
- Current focus: meaningful rewards for successfully extracted gold.
- Candidates under consideration: persistent secured wealth and visible milestone progression.
- P006's exact specification and implementation are **not yet approved**. No P006 entry exists until it is scoped.
- A combat-foundation experiment is the recommended next major investigation after P006 (not numbered or scoped).

*Planning note above kept as history. P006 was subsequently specified, approved, implemented, and playtested.*

### P006 — Meaningful Extraction Rewards
Give gold secured by extraction a persistent, meaningful use: an in-session treasury, a recruitable merchant, and a purchasable first sword with a minimal functional use.

*Concluded for the current cycle on 2026-11-16 (Iterate). The integrated expedition-to-settlement reward loop was promising (Medium confidence); individual-element, replay, and return-or-continue effects remain unestablished (Low confidence). See the P006 entry.*

### Planning Note (2026-11-16): Next Recommended Investigation
- **Combat Foundation** is the next recommended major investigation (Strong Recommendation, not approved).
- Potential research question: *Can a responsive basic weapon attack against a fightable enemy create enjoyable, readable combat within GoldKing's existing 2.5D presentation?*
- No prototype number, specification, or implementation is assigned.

*Planning note above kept as history. Combat Foundation was subsequently specified and approved as P007.*

### P007 — Combat Foundation
Test whether one directional sword attack, a brief invulnerable dodge, and one readable melee enemy produce an enjoyable combat exchange.

*In progress. Human Playtest 1 (2026-11-16) recorded as the baseline; Iteration 1 (Lightweight Target Focus) approved as an A/B experiment. No outcome assigned. See the P007 entry.*

This sequence is not permanent.

Prototype findings may reveal that another question should be tested first.

---

# When to Promote a Prototype Finding

A prototype finding should influence the formal design documents when:

- The same result survives multiple iterations, **or**
- The evidence is strong enough to make the choice clear, **or**
- Quon or Jason explicitly approves the resulting direction.

When this happens:

1. Update `GOLDKING_DECISION_LOG.md`.
2. Update the relevant gameplay/design foundation if necessary.
3. Keep the original prototype entry intact as the evidence behind the decision.

Do not rewrite old prototype results to match newer decisions.

The history of being wrong is useful.
