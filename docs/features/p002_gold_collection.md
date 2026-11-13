# P002 — Gold Collection

**Document:** `docs/features/p002_gold_collection.md`  
**Status:** Approved prototype feature specification (2026-11-12, Quon); implementation not yet authorized  
**Prototype:** P002  
**Depends on:** P001 — Player Movement & Controlled Camera (Validated; Medium confidence)  
**Engine / implementation context:** Godot 4.7.2 stable, typed GDScript, Mobile renderer (prototype assumption)

## 1. Design Question

> **Is finding, approaching, collecting, and visibly accumulating gold immediately readable and satisfying?**

P002 isolates the appeal of obtaining gold. It does **not** test whether carrying gold makes the King stronger, slower, more vulnerable, or more likely to lose wealth. Those questions belong to later prototypes.

## 2. Context and Decision Status

**Approved Direction (existing):** Gold is a central, desirable gameplay resource; GoldKing uses a 2D character in a 3D environment with a controlled elevated camera, and the King's accumulated wealth should be communicated visibly. GoldKing's explorable areas should feel like connected places, not a sequence of sealed combat rooms.

**Validated prototype baseline:** Use P001's existing player controller, camera, scene, gray-box environment, and movement behavior as the starting point. Preserve P001 tuning as a baseline, not a finalized production choice.

**Prototype Assumptions (for this test only):** Gold is represented by simple distinct pickups; walking near a pickup collects it automatically; one visible counter records the run's collected gold; a temporary pouch visibly attached to the King changes as wealth accumulates; a short sound and small visual pop/sparkle make pickups rewarding. These are preferred **P002 prototype assumptions only**, not final mechanics or character-art decisions.

## 3. Player Experience to Test

1. The player notices gold in the environment, including in a small cluster and in at least one less-obvious location.
2. The player approaches it using the existing movement controls.
3. Contact/proximity collects the gold once, without interrupting movement.
4. Collection immediately produces a readable response (object disappears, brief visual/audio cue, and total increases).
5. As the total grows, the player can *see* accumulation at a glance beyond the pickup disappearing.
6. Collecting several pieces in succession feels appealing rather than noisy, confusing, or tedious.

The intended emotional tone is **"I want that gold"**, not **"I should avoid carrying too much."**

## 4. In Scope — Smallest Useful Prototype

### Gold pickups
- One placeholder gold pickup type with a recognizable silhouette and strong contrast at P001's current camera distance.
- Fixed, hand-placed pickups with a single nominal value (e.g. **+1** each). No denominations or exchange rates.
- Several simple placement patterns: one isolated pickup, a short trail, a compact cluster, pickups beside obstacles, and one slightly obscured/off-main-path pickup.
- Each pickup can be collected **exactly once** via a small proximity/overlap trigger, without requiring a collection button. The radius should feel like reaching the gold, not collecting it from a distance.
- No attraction radius, vacuum/magnet behavior, physics scatter, or item interaction button in the initial implementation.

### Collection feedback
- Clear pickup disappearance or quick shrink/pop effect.
- One short, non-intrusive audio cue (placeholder is acceptable).
- One small visual pop/sparkle (placeholder is acceptable); choose the cheapest implementation during planning.
- Feedback should work for both single pickups and rapidly collected clusters without making the screen or audio chaotic.

### Visible accumulation
- A plainly legible on-screen gold count that changes immediately.
- Start with one **low-cost, clearly provisional pouch attached to the Gold King** with around three distinct fill appearances (empty/low, partly filled, overflowing). A simple placeholder is enough; no bespoke animation system is required.
- The pouch should track the King without covering his silhouette, distracting from navigation, or interfering with P001 facing, shadows, collision, or camera readability. It must not change movement, collision, damage, posture, or power.
- Keep the HUD counter and attached pouch independently observable so playtesting can establish whether the pouch adds meaningful feedback. The pouch is **optional in the final design**: if it gets in the way or feels awkward, record that finding and remove/reconsider it rather than forcing it into production.
- Alternative wealth cues such as a gold-colored character effect or visible changes in heft/posture remain possible **future experiments**; do not implement them in P002. Actual burden and weight effects belong to P003.

### Test scene and replay
- Reuse/extend the P001 gray-box scene without redesigning the environment or camera.
- Arrange a short, repeatable route with approximately **15–25** total pickups so testers encounter isolated, grouped, and partly obscured gold.
- Provide a straightforward restart/reset for repeated collection tests; no persistence or save system.

## 5. Explicitly Out of Scope

- Gold-based damage or ability scaling (P003).
- Gold burden, movement penalties, load thresholds, stamina, or vulnerability (P003).
- Dropping/spilling gold, theft, enemies collecting gold, or damage-triggered loss (P004).
- Expedition failure, extraction, banking, or permanent ownership (P005 or later).
- Treasure/ordinary loot, relics, equipment, shops, inventory, crafting, and any settlement economy.
- Midas/Gilding powers, combat systems, enemies, and procedural generation.
- Final art, final audio, animation pipeline, save data, or production-ready player/inventory architecture.

## 6. Implementation Guardrails for Claude Code

- **Planning only until human review.** Inspect existing repository layout, P001 specification/implementation, AI instruction files (`AGENTS.md`, `CLAUDE.md`, `.claude/settings.json`), and `GOLDKING_PROTOTYPE_LOG.md` before proposing file-level changes.
- Preserve working P001 movement, collisions, controlled camera, and basic facing.
- Prefer a tiny modular pickup scene/script and the smallest practical place to hold one numeric gold total. Avoid building a generic item/economy/inventory framework.
- Use typed GDScript. Expose values expected to change during testing, but do not over-abstract them.
- Choose low-cost placeholder assets and simple Godot primitives/tweens/signals where sufficient.
- Do not modify main directly during implementation. Implementation follows review and creation of a P002 feature branch.
- Flag any reason the proposed scope cannot be implemented without touching architecture outside P002.

## 7. Mechanical Validation Checklist

- [ ] Project opens and runs in the target Godot build without new errors.
- [ ] Existing P001 movement, collision, and camera behavior remain intact.
- [ ] Each pickup increases the total by its intended amount exactly once.
- [ ] Pickups cannot be collected repeatedly after disappearing.
- [ ] Both isolated pickups and clusters register consistently at normal and rapid traversal speeds.
- [ ] HUD count and the attached pouch stages update reliably.
- [ ] The pouch does not obstruct the character or regress P001 facing, shadow, movement, or camera readability.
- [ ] Feedback can trigger repeatedly without stacking into unreadable clutter or severe audio overlap.
- [ ] Pickups near obstacles and partially occluded locations remain physically reachable.
- [ ] Restart/reset makes the same test repeatable.

Mechanical correctness is necessary but **does not establish** that collection feels good.

## 8. Human Playtest Plan

**Recommended testers:** Quon and Jason, ideally independently and without being told how the pickups work. More testers are welcome; one person's positive reaction alone should carry lower confidence.

**Playtest sequence:** Start each player in the same scene, observe an unaided first encounter, allow a full route, then request a quick impression and repeat the cluster segment if necessary. Avoid coaching unless the player gets stuck; record any coaching as a readability issue.

**Observe and record:**

| Dimension | Specific evidence to capture |
| --- | --- |
| Finding | Are gold pieces noticed in open, clustered, and partially obscured placements? Which are missed? |
| Approach | Can players tell how to reach gold, including next to geometry? |
| Collection | Do they understand that walking into/near gold collects it without instruction? Any missed or accidental triggers? |
| Feedback | Do they notice exactly when collection occurs, especially in a cluster? |
| Accumulation | Can they tell that total wealth is increasing? Do they notice the attached pouch separately from the HUD? Does the pouch add delight, or obstruct/distract from the King? |
| Satisfaction | Do they want to collect more? Rate collection satisfaction from 1–5 and explain why. |

**Proposed success criteria (reviewable, not canon):**
- No critical collection-counting or accessibility bugs in the repeatable route.
- Both primary testers understand the basic pickup interaction during their first encounter without instruction.
- Both primary testers can identify that gold is accumulating, not merely disappearing.
- Record each tester’s 1–5 satisfaction rating and explanation; **4/5 is a useful target, not a rigid pass/fail gate** given placeholder presentation and a small sample. Look especially for spontaneous desire to collect more gold.
- At least one full route test checks readability when pickups are partially obscured and when collected rapidly.

A failed criterion means **iterate or revise the assumption**, not automatically reject the approved gold direction. With only two testers, report confidence conservatively.

## 9. Completion / Documentation

P002 may be marked **Validated**, **Needs Iteration**, or **Invalidated** only after mechanical checks and human playtesting. Document test conditions, observations, bugs, satisfaction feedback, assumptions retained/rejected, and confidence in `GOLDKING_PROTOTYPE_LOG.md` before merging.

Do **not** treat auto-pickup, UI placement, pickup scale, visual accumulation thresholds, or feedback style as final architecture/design decisions solely because they were used in P002.

## 10. Approved Scope and Remaining Questions

**Approval:** Quon approved the P002 feature-specification draft on 2026-11-12. This authorizes moving to Claude Code inspection and planning, **not** implementation. Approval covers the scope and test plan; individual mechanics remain **Prototype Assumptions**, not permanent Approved Directions.

**P002 test assumptions (approved for prototyping, not final gameplay decisions):**

1. **Pickup interaction:** Automatic proximity collection, with a small radius and no magnetism.
2. **Visible accumulation:** A HUD counter plus a temporary, visibly attached pouch that changes through approximately three fill appearances. The pouch is not a permanent character-design commitment.
3. **Feedback minimum:** One short sound plus a simple pop/sparkle, kept readable during rapid pickups.

**Still open:** Whether the pouch improves visual accumulation, exact pickup radius and stage thresholds, and whether feedback remains satisfying in clusters. These should be resolved through planning and playtest evidence, not preemptively treated as permanent decisions.

**Playtest fallback:** If the pouch looks intrusive or feels unpleasant, document that outcome and evaluate whether the HUD alone sufficiently communicates accumulation. Gold-colored appearance changes may be considered in a subsequent iteration. Movement/physical weight changes remain outside P002 (P003).

## 11. Workflow Gate

**Before development:** Confirm that the completed P001 commits have been pushed to `origin/main` (`git push origin main`) or deliberately record why that prerequisite has changed. **Specification review is complete.** Next ask Claude Code to inspect the repository and produce a **planning-only** implementation proposal. Review that plan, then create a P002 feature branch before separately authorizing implementation.
