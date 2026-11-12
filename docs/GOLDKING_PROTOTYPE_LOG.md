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
| P001 | Player Movement & Camera | Does the chosen 2.5D presentation produce intuitive, readable movement? | Planned | — | — |
| P002 | Gold Collection | Is collecting gold immediately satisfying and readable? | Planned | — | — |
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

**Status:** Planned  
**Date Started:** —  
**Date Concluded:** —  
**Build / Commit:** —  
**Testers:** Quon / Jason initially  
**Related Decision(s):**
- 2.5D top-down presentation
- 3D environments + 2D characters
- Controlled gameplay camera

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

Pending.

### 13. Player Comments

Pending.

### 14. What Worked

Pending.

### 15. What Did Not Work

Pending.

### 16. Interpretation

Pending.

### 17. Unexpected Findings

Pending.

### 18. Outcome

**Outcome:** Pending  
**Confidence:** Pending

**Conclusion:** Pending.

### 19. Decision Impact

Pending.

### 20. Next Test

If P001 validates the presentation sufficiently, proceed to **P002 — Gold Collection**.

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
