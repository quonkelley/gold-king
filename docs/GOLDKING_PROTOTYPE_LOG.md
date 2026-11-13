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
| P002 | Gold Collection | Is collecting gold immediately satisfying and readable? | Testing | Pending playtest | 2026-11-12 (started) |
| P003 | Gold Power vs. Burden | Can increasing wealth feel powerful and dangerous at the same time? | Planned | — | — |
| P004 | Gold Spill & Theft | Does losing loose gold during combat create enjoyable urgency rather than annoyance? | Planned | — | — |
| P005 | Mini Expedition / Extraction | Does choosing between returning safely and pushing deeper create meaningful greed tension? | Planned | — | — |

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

**Status:** Testing (implemented; awaiting human playtest)  
**Date Started:** 2026-11-12  
**Date Concluded:** —  
**Build / Commit:** `d2d201c` (branch `feat/p002-gold-collection`)  
**Testers:** — (planned: Quon and Jason, independently)  
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
| Pickups missed on the first full route (which ones) | — |
| Coaching needed (yes/no; what) | — |
| Pouch noticed separately from the HUD (yes/no) | — |
| Satisfaction rating 1–5 (per tester) | — |

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

### 12. Observations

Pending human playtest.

### 13. Player Comments

Pending human playtest.

### 14. What Worked

Pending human playtest.

### 15. What Did Not Work

Pending human playtest.

### 16. Interpretation

Pending human playtest.

### 17. Unexpected Findings

Pending human playtest.

### 18. Outcome

**Outcome:** Pending human playtest  
**Confidence:** —

### 19. Decision Impact

Pending human playtest.

### 20. Next Test

Pending human playtest. The planned next prototype is P003 (Gold Power vs. Burden).

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

### P004 — Gold Spill & Theft
Test whether combat can make losing and recovering gold create enjoyable urgency.

### P005 — Mini Expedition / Extraction
Combine exploration, gold accumulation, risk, optional treasure, and voluntary return into the first small version of the expedition loop.

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
