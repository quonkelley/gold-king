# P005 — Mini Expedition & Extraction

**Document:** `docs/features/p005_mini_expedition_extraction.md`  
**Status:** Approved P005 prototype feature specification — **scope approved; implementation authorized** on `feat/p005-mini-expedition-extraction` (approved by Quon, 2026-11-15)  
**Approval history:** P005 scope approved by Quon. This specification was first drafted for review with implementation not authorized. After review of the specification and of a planning-only repository inspection, Quon approved the implementation plan and authorized implementation (2026-11-15). The approved implementation choices are recorded in the P005 entry of `docs/GOLDKING_PROTOTYPE_LOG.md`; the requirements below are unchanged from the reviewed draft.  
**Prototype:** P005  
**Depends on:** P001 — Player Movement & Controlled Camera; P002 — Gold Collection; P004 — Gold Spill & Theft  
**Historical reference:** P003 — Gold Power vs. Burden  
**Engine context:** Godot 4.7.2, typed GDScript, 2.5D presentation  
**Implementation:** Authorized (2026-11-15)

## 1. Primary Design Question

> **Can a short expedition combining exploration, gold collection, external danger, and voluntary extraction create a satisfying gameplay loop that the player wants to repeat?**

### Supporting Questions

1. Does the player enjoy exploring a compact authored environment in search of gold?
2. Does treasure placement encourage curiosity and optional exploration?
3. Does the possibility of encountering a thief influence the player's decisions?
4. Does the player feel genuinely tempted to continue collecting gold rather than return safely?
5. Is returning to the starting location and securing the expedition's haul understandable and satisfying?
6. After completing the expedition, does the player want to play another run?

P005 is an integration experiment, not a complete vertical slice.

## 2. Source Alignment and Decision Status

### Established Canon

The Gold King is good-hearted, charismatic, proud, flawed, and genuinely attracted to wealth. His journey concerns exile, regained power, and becoming worthy of his kingdom.

Gold should remain desirable and enjoyable.

### Approved Direction

- GoldKing uses a 2.5D presentation with 3D environments, stylized 2D characters, and a controlled elevated camera.
- Expeditions take place in connected, explorable environments.
- Gold accumulation should contribute to the King's power and desirability while creating potential external threats and vulnerabilities.
- Automatic movement penalties from collecting ordinary gold are superseded as the intended core consequence.
- Wealth carried away from safety is unsecured until successfully returned.
- The settlement is a progression and story hub, not a resource-management simulation.

### Approved P005 Prototype Scope

Quon approved:

1. One compact authored expedition area with two optional exploration branches.
2. One reused P004-style thief encounter.
3. Voluntary extraction by returning to the starting location.
4. A results screen displaying secured gold and allowing a fresh run, without persistent progression.

These approvals apply to P005's experimental scope, not permanent level structure or game progression.

### Evidence Entering P005

- **P001:** Movement and camera established a usable baseline.
- **P002:** Proximity gold collection was engaging enough to continue prototyping. Floating pickups were preferred; feedback polish remained deferred.
- **P003:** Gold-based power showed promise. Automatic gold-based slowdown was superseded as the intended core burden mechanic.
- **P004:** A single thief encounter produced encouraging readability, fairness, avoidance, and recovery responses. The cycle concluded with outcome *Iterate* and Medium confidence.

P005 must not silently promote P004's placeholder thief behavior, loss caps, or exact timings into permanent mechanics.

## 3. Desired Player Experience

The player begins at a small, recognizable safe camp.

Nearby gold provides an immediate reward and introduces the expedition objective without requiring lengthy instructions.

Exploring farther reveals optional paths with additional treasure. One path offers relatively safe rewards, while another contains an opportunity for a P004-style thief encounter.

At any point, the player can return to camp to secure the haul.

The player should experience the temptation to continue:

> *I could go back with what I've earned, but there might be something valuable I haven't discovered yet.*

Returning to camp and choosing to extract completes the expedition and displays the secured reward.

The player can then begin another fresh run.

### Emotional Targets

- Curiosity about what lies beyond the initial route.
- Excitement from accumulating gold.
- Caution when encountering an external threat.
- Satisfaction when returning with a secured haul.
- Interest in trying another expedition.

The experience should not require artificial scarcity, hunger, timers, or escalating enemy spawns to create urgency.

## 4. Smallest Useful Prototype

### 4.1 One Compact Authored Area

Use one small continuous environment with:

- A clearly identifiable starting camp.
- A nearby collection opportunity.
- Two optional exploration branches.
- Readable routes back to camp.
- Enough landmarks or visual distinction to understand where the player has traveled.

**Strong Recommendation:** Reuse existing P001/P002/P004 environment elements and construct only the minimum additional geometry necessary to establish the branching layout.

Do not introduce procedural generation, multiple zones, a world map, or a full settlement scene.

### 4.2 Treasure Placement

Use ordinary gold pickups as the primary expedition reward.

Suggested provisional distribution:

- **Starting area:** A small amount of easily visible gold.
- **Branch A:** Additional gold reachable with little or no direct threat.
- **Branch B:** A potentially more lucrative collection opportunity near the thief encounter.

Treasure placement should make exploration worthwhile without requiring a complex reward system.

Do not introduce equipment, relic inventories, treasure appraisal, or permanent upgrades during this prototype.

The exact gold quantities and positions are Prototype Assumptions to be proposed during planning.

### 4.3 External Danger

Reuse one P004-style thief encounter, preserving its recognizable warning, gold-spill, theft, avoidance, interception, and recovery behavior where practical.

The player should have the opportunity to avoid or respond to the thief using movement.

Do not introduce:

- Additional thieves.
- Enemy respawning.
- Wealth-scaled enemy counts.
- Combat or health mechanics.
- A general threat director.

The goal is to investigate how a known external threat affects a longer expedition decision.

P004's exact encounter tuning may be adjusted only as needed for the new layout and must remain provisional.

### 4.4 Return-to-Start Extraction

The player begins at camp and must return to that location to extract.

**Strong Recommendation — Prototype Assumption:**

- A clearly marked extraction zone surrounds camp.
- When inside, the player sees an interaction prompt.
- Pressing an interact input confirms extraction.
- Simply walking through camp does not end the expedition.
- Extraction is allowed with zero or more carried gold.

Extraction ends the current run and records the amount secured.

The results must be based on the King's actual carried balance, not the total amount of gold that appeared in the level.

**Important boundary:** P005 does not need to implement the full expedition-failure system. Loss of the complete unsecured haul on failure remains part of the broader expedition direction, but this prototype only needs successful voluntary extraction and existing P004 theft loss.

### 4.5 Results and Replay

Successful extraction displays a minimal results interface.

Suggested information:

- Expedition completed.
- Gold secured.
- Gold lost to theft, if any.
- Optional run duration.
- A clear option to begin another expedition.

Beginning another run resets the environment, player, ordinary pickups, thief encounter, and expedition results.

The secured amount is a result of the completed test run, not a permanent currency balance.

No persistent banking, shop, equipment progression, settlement development, or save system is required.

### 4.6 Debug Controls

Preserve useful testing controls where practical, but ensure debug presets do not accidentally appear as normal expedition behavior.

The player should be able to perform an uncoached expedition without depending on shortcuts that grant starting gold.

A full reset must produce a reproducible initial expedition.

## 5. Technical Reuse and Architecture Boundaries

P005 should reuse existing tested systems rather than rebuilding them.

### Intended Reuse

- P001 player movement and controlled camera.
- P002 automatic collection, gold counter, and collection feedback.
- P004 spill, theft, recovery, and movement-based interception where relevant.

### Explicitly Excluded

- P003 automatic speed penalties.
- P003 temporary strike and combat targets.
- General enemy AI frameworks.
- Persistent inventory, settlement banking, and economy systems.
- Procedural generation.
- Expanded combat architecture.

**Open technical question:** Whether P005 should inherit the P004 prototype scene or compose a new scene using P001/P002 and selected P004 components.

Claude Code should inspect the actual repository and recommend whichever option best avoids unnecessary coupling to P004's test controls and fixed encounter positions.

No architecture has been approved yet.

## 6. Gold Accounting and Expedition State

Gold accounting must remain consistent throughout collection, theft, recovery, extraction, and replay.

The system should distinguish at minimum:

- Gold currently carried by the King.
- Ordinary level gold not yet collected.
- Spilled or recoverable gold.
- Gold currently held by the thief.
- Gold lost through theft.
- Gold secured at extraction.

Before extraction, the P004 conservation rules should continue to apply to gold that has entered the carried haul, adjusted for P005's run-initialization policy.

At extraction:

1. Record the current carried amount as the secured result.
2. Prevent further collection and theft transfers in the completed run.
3. Display the correct result.
4. Allow a fresh run that resets all relevant expedition state.

Gold must not be duplicated by entering camp, interacting repeatedly, or restarting.

P005 should not invent persistent account balances or a general inventory framework.

## 7. Proposed Test Scenarios

These scenarios are intended to be mechanically reproducible.

| Scenario | Expected behavior |
|---|---|
| Extract with zero gold | Run completes with zero secured |
| Collect nearby gold and extract | Exact carried amount is secured |
| Explore Branch A then extract | Optional exploration reward is reflected in results |
| Explore Branch B and avoid thief | Gold remains subject only to actual collection and encounter events |
| Lose one gold to thief, then extract | Secured amount reflects the loss |
| Intercept thief and recover coin | Recollected gold contributes to secured result |
| Return through camp without interacting | Expedition continues |
| Interact with extraction outside camp | Extraction is not triggered |
| Start another run | Pickups, thief and expedition state reset |
| Repeated extraction input | No duplicate result or secured amount |

Exact environmental geometry and test coordinates are to be determined during implementation planning.

## 8. Mechanical Acceptance Criteria

Before human playtesting, confirm:

- P005 launches without scene or script errors.
- Player movement and controlled camera remain functional.
- Ordinary gold does not automatically slow the King.
- Both optional branches are reachable and lead back toward camp.
- Gold pickups work and update the HUD consistently.
- The thief encounter functions without introducing additional enemies.
- Theft and recovery preserve accurate gold accounting.
- The camp extraction interaction works only within the intended area.
- Returning to camp without interacting does not automatically end the run.
- The extracted gold result matches the actual carried gold.
- Repeated extraction input cannot secure gold twice.
- Replay creates a fresh and consistent expedition.
- No persistent gold balance carries into another run.
- P004 and P003 regression tests remain runnable.
- Historical P001–P004 prototype scenes remain available.

Automated tests establish mechanical correctness, not enjoyment or meaningful decision-making.

## 9. Human Playtest Plan

### Primary Goal

Determine whether the integrated expedition loop is satisfying and whether the return-or-continue decision carries meaningful tension.

### Pass A — Natural Expedition

Allow the tester to begin at camp with minimal explanation.

Observe:

- Where they explore first.
- Whether they notice both branches.
- How they respond to visible gold.
- Whether they encounter or avoid the thief.
- When they decide to return to camp.
- Whether they understand how to extract.
- Whether they want another run.

Do not coach the tester into extracting early or collecting every coin.

### Pass B — Controlled Comparison

Ask the tester to complete a second expedition using a different route or strategy.

Compare exploration choices, extraction timing, and reaction to the thief.

### Measurements

Rate from 1 to 5:

1. Exploration enjoyment.
2. Gold discovery and collection satisfaction.
3. External-threat tension.
4. Return-to-camp extraction clarity.
5. Satisfaction of securing the haul.
6. Overall expedition enjoyment.
7. Desire to play another expedition.

Also record:

- Did the player explore one or both branches?
- Did the player extract before collecting all available gold?
- If they extracted early, why?
- If they collected everything, why?
- Did the thief affect their decision to continue or return?
- Did they feel tempted to pursue more treasure?
- Did they immediately want another run?
- What felt incomplete, repetitive, or confusing?

### Directional Success Criteria

Promising evidence would include:

- The player understands the basic expedition loop without substantial coaching.
- Gold discovery encourages exploration.
- The player recognizes extraction as a deliberate action.
- The return process feels like securing something valuable.
- The player reports interest in another expedition.
- The game produces at least some observable consideration of whether to return or continue.

**Important:** A player collecting every coin before extracting is not automatically a failure. However, if the player never perceives any reason to consider returning early, the return-or-continue decision has not yet been demonstrated.

The expedition's overall enjoyment and the strength of the extraction decision must be evaluated separately.

## 10. Key Risks and Open Questions

### Risk A — Extraction Has No Real Tension

One thief encounter may not create enough ongoing uncertainty to make an early return appealing.

Do not preemptively solve this with timers, repeated enemies, or arbitrary penalties.

Record whether the current systems provide sufficient tension.

### Risk B — The Area Is Too Small or Predictable

Players may quickly learn where every reward is located, limiting replay interest.

This is acceptable for a first integrated prototype. Variation can be tested later if necessary.

### Risk C — Reusing P004 Creates Unnecessary Coupling

P004 contains fixed encounter geometry, trial presets, and debugging functionality.

Avoid allowing those assumptions to dictate the entire P005 architecture.

### Risk D — Results Feel Inconsequential

Without persistent progression, secured gold may feel less important than it would in the finished game.

Use clear feedback and a visible secured total, but do not add a permanent economy simply to compensate.

Record whether the absence of persistence affects perceived satisfaction.

### Risk E — The Thief Overshadows Exploration

The expedition should feel like a journey in search of wealth, not simply another thief test.

The thief should provide context and consequence rather than becoming the sole objective.

## 11. Explicit Non-Goals

P005 does not include:

- A complete settlement or town hub.
- Permanent gold banking or upgrades.
- Expedition death, full failure, or complete-haul loss.
- Procedural maps or multiple destinations.
- Multiple enemy types, combat systems, or bosses.
- Dynamic threat escalation.
- Survival mechanics or forced extraction timers.
- Treasure and equipment encumbrance.
- Optional heavy gold forms.
- Quests, dialogue, new characters, or new story canon.
- Final animations, environmental art, or audio polish.
- Full save/load functionality.

Any expansion beyond this scope requires separate review.

## 12. Prototype Outcome and Documentation

After automated validation and human playtesting, record in `docs/GOLDKING_PROTOTYPE_LOG.md`:

- Actual scene configuration and mechanics reused.
- Exact gold distribution and layout.
- Extraction interaction and reset behavior.
- Validation results.
- Tester count and observed behavior.
- Ratings and direct qualitative comments.
- Whether the player perceived a meaningful return-or-continue decision.
- Whether the combined loop felt enjoyable and repeatable.
- Known limitations.
- Outcome: Validated, Iterate, or Rejected, with confidence.

Do not convert provisional encounter tuning, treasure layout, or extraction UI into permanent design decisions without approval.

## 13. Approval and Development Workflow

### Current Status

**P005 scope approved; feature specification drafted for review. Implementation not authorized.**

*Status update (2026-11-15): the specification and the planning-only implementation review were approved, and implementation was authorized on `feat/p005-mini-expedition-extraction` (gate steps 1–5 below).*

### Next Gate

1. Review and approve this feature specification.
2. Commit the approved specification using the established naming convention.
3. Conduct a planning-only Claude Code repository inspection.
4. Review proposed architecture and implementation scope.
5. Explicitly authorize implementation on `feat/p005-mini-expedition-extraction`.
6. Run mechanical regression tests.
7. Conduct Human Playtest 1.
8. Document findings and conclude or iterate based on evidence.
9. Review and merge through the existing Git workflow.

The approved specification should guide implementation, but the prototype's playtest evidence determines whether the expedition loop works.

**P005 design principle:**

> *Gold should tempt the King to venture farther. Extraction should make returning with that wealth feel meaningful.*
