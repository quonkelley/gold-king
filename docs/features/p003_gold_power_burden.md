# P003 — Gold Power vs. Burden

**Document:** `docs/features/p003_gold_power_burden.md`  
**Status:** Approved P003 prototype feature specification — **planning authorized; implementation not yet authorized** (approved by Quon, 2026-11-13)  
**Prototype:** P003  
**Depends on:** P001 — Player Movement & Controlled Camera (Validated, Medium confidence); P002 — Gold Collection (current-cycle conclusion: Iterate, feedback polish deferred, working collection baseline accepted)  
**Engine / implementation context:** Godot 4.7.2 stable; typed GDScript; Mobile renderer remains a technical/prototype assumption  
**Naming convention:** `docs/features/p###_<short_descriptive_name>.md` (Git history provides document versioning)

## 1. Primary Design Question

> **Can becoming richer feel increasingly powerful and increasingly dangerous at the same time, without making the player want to avoid gold?**

P003 tests the **experience of carrying more gold**. It is not an attempt to finalize combat, movement tuning, gold mechanics, or balancing.

**Supporting questions:**

1. Can a player *feel* the increase in power through play, rather than only read a number?
2. Can a player notice the cost of carrying gold without the controller suddenly feeling broken or unpleasant?
3. At higher wealth, does the reward still outweigh the perceived cost?
4. Does the trade-off lead to interesting player decisions, or simply teach the player to avoid collecting?
5. When power and reduced mobility matter **in the same short route**, do they create an interesting choice rather than two unrelated stat changes?

## 2. Source Alignment and Decision Status

**Established Canon:** The Gold King is fundamentally good-hearted, charismatic and proud, and genuinely loves gold. His greed is a flaw, not a sign of secret villainy. Gold must remain alluring, not a moral punishment.

**Approved Direction:** Gold is central to gameplay, presentation uses a 2D character in a 3D world with a controlled elevated camera, and P001's responsive movement is the baseline. Expeditions are envisioned around gold accumulation and risk, but the later expedition systems are not part of this test.

**Existing Prototype Assumption:** More carried gold can provide power while creating physical burden/vulnerability. The decision log treats the *exact mechanic* as unvalidated. The gameplay foundation outlines the intended fantasy; neither source locks in a speed curve, damage formula, or combat system.

**Evidence entering P003:** P001 movement felt good. P002 established that floating gold is easy to recognize and more inviting than the tested grounded presentation, and automatic proximity collection works naturally. P002 overall satisfaction remained moderate (3/5); audio/visual polish and the pouch's ultimate role remain unresolved.

**Approved P003 prototype-testing scope (not permanent gameplay direction):** Quon selected a temporary impact attack against test targets, a mild speed penalty tested under timing pressure, and **one short combined power-and-burden course**. Use the existing floating pickup, count, and provisional pouch. Compare low, medium, and high carried-gold states. All mechanics, thresholds, and values remain **Prototype Assumptions**, not final combat or movement decisions.

## 3. What the Player Should Experience

1. Begin with little or no gold; move through the familiar P002 space and interact with one simple test target.
2. Collect familiar floating coins using the existing proximity behavior.
3. See/feel that accumulating gold produces **more impact** from a temporary test action.
4. Also notice a **cost** when navigating a short, repeatable movement challenge under pressure.
5. Try a short route that requires both striking a target and passing a timed obstacle, then assess whether extra power makes the mobility cost worthwhile.
6. Reset and compare conditions deliberately, then give an uncoached preference and explanation.

The emotional goal is: **“I'm getting dangerously rich—and I still want more.”** A trade-off that feels like only punishment is not a success.

## 4. Smallest Useful Prototype — Approved Test Scope

### 4.1 Preserve the P002 Collection Baseline

- Keep **Floating** as the default pickup presentation.
- Reuse automatic proximity collection, the run-local gold count, the HUD, the existing placeholder effects and the 20-coin test setup where practical.
- Keep the pouch provisional and independently hideable; do not redesign it or treat it as a finalized character feature.
- Do not spend P003 time on polishing the coin audio, changing collection controls, grounded-gold presentation, or treasure acquisition variants.

### 4.2 Three Observable Wealth States

Use the same approximate bands that the P002 pouch already communicates, as **initial test values only**:

| Carried gold | Test label | Initial intention |
| --- | --- | --- |
| 0–5 | Light | Baseline movement and minimum power |
| 6–13 | Loaded | Noticeable but manageable increase in power and burden |
| 14+ | Heavy | Clearly stronger, with a meaningful but playable cost |

Use exposed parameters rather than embed these values in permanent architecture. The thresholds are **not** final gold-load tiers. For comparison testing, provide a simple way to restart in or quickly reach each state; prefer an editor/test configuration over a gameplay menu or inventory.

### 4.3 Power — One Temporary Test Action (Selected for P003 Draft)

**Selected experiment:** A **single button-triggered impact/strike** that affects stationary test targets (e.g., breakable training blocks). The same target should require fewer impacts as wealth rises, with obvious placeholder hit feedback. An illustrative target is **3 / 2 / 1 hits** for Light / Loaded / Heavy; these counts are tunable test values, not a balance commitment.

- One fixed action, one simple target type, one visible result. Its damage/impact may scale discretely by wealth state.
- No combos, weapon swapping, ranged-versus-melee decision, enemy AI, weapon upgrades, knockback framework, or production combat controller.
- Use clear temporary indicators (target flashes, remaining hits or a break effect) to establish that increased gold **does something**, not just that the HUD number changes.
- The action is a **measurement instrument**, not an approved weapon, Midas/Gilding ability, final attack animation, or final combat style.

**Design boundary:** This strike is a temporary measurement tool. Keep attack range, input, and recovery/timing the same across wealth states so that changing hit counts, rather than changing attack responsiveness, reveals the power effect. Whether it *feels* powerful still requires human playtesting.

### 4.4 Burden — One Mild Movement Cost Under Pressure (Selected for P003 Draft)

**Selected experiment:** At higher gold loads, apply a **small, tunable reduction to maximum movement speed only** in the P003 player configuration, while preserving P001 acceleration, deceleration, turning responsiveness, movement input, diagonal normalization, collision, and controlled camera. Do not alter P001 source assets merely to achieve the test.

- Use mild differences first; propose **0% / ~8% / ~16% slower** for Light / Loaded / Heavy as *starting test values*, subject to human approval and tuning.
- Do not also add stamina, dodge penalties, recovery lag, turning inertia, or an exhaustion system in this prototype. **One burden variable at a time.**
- Include a brief, repeatable **timed traversal segment** with one predictable cycling obstacle or hazard lane. Record elapsed time and optionally contacts as a proxy for navigational pressure. Use placeholder geometry; **no health, enemy AI, damage, gold loss or failure system**. This is a controlled pressure test, not proof of real combat vulnerability.
- Any hazard indicator is strictly a test instrument. A hit/contact must **not** spill, steal, consume, or remove gold; those mechanics belong to P004.
- Keep the original open-area and narrow-passage movement routes available so the player can directly compare whether the King still feels responsive.

**Critical risk:** Gold should never feel like a reason to stop exploring. If even a mild speed penalty feels like friction rather than an interesting trade-off, record that result rather than adding extra compensation or prematurely committing to movement penalties. A later burden experiment could explore vulnerability or action recovery *instead*.

### 4.5 Readability of the Trade-off

- Retain HUD gold count and the provisional pouch.
- Add only the minimum temporary indication needed to tell what happened in tests (e.g., target reaction and simple hazard contact/timer feedback).
- Do **not** introduce new HUD gauges for every variable or a large stat interface.
- Avoid requiring detailed mathematical explanations to perceive power and burden.

### 4.6 Combined Power-and-Burden Challenge (Agreed Test Design)

Use **one short, repeatable course** within the existing P001/P002 gray-box environment:

`Start → stationary target blocking progress → single predictable timed obstacle → Finish`

- The King must clear the **same test target** using the temporary impact action, then pass the **same obstacle** and reach the finish. The stronger Heavy state should clear the target in fewer hits but move more slowly through the route.
- Record **total completion time**, **hits needed to clear the target**, and optionally **hazard contacts**. The game should not punish contacts with health or gold loss. Keep the timer and contact display simple and test-local.
- Run the same course at Light, Loaded, and Heavy. Provide a reliable reset and an editor/test-only way to set or rapidly reach each gold state. The primary gameplay path should still allow natural collection; no inventory, cheat menu, or persistent progression is necessary.
- Also retain **separate checks** for power alone (target) and mobility alone (open traversal). Without them, a faster combined time could conceal a miserable movement feel, or a slower time could conceal satisfying impact.
- Preserve attack timing and course geometry across conditions. If the obstacle's cycle introduces variance, start trials from a repeatable phase or record repeated runs; do not present a single timing result as conclusive.
- **Do not add** additional targets, enemies, AI, health, traps, death, gold spill, or expedition mechanics. This is a minimal experiment, not a level or racing mode.

The course is intended to answer: **Does extra striking power compensate for reduced mobility in a way the player enjoys?** It does not need perfect numerical balance. A result where Heavy is always fastest, always slowest, or only preferred in certain situations is useful evidence, provided we also record how it feels.

### 4.7 Repeatable Comparison

- Reuse/extend the existing environment; preserve the P001/P002 baseline where possible.
- Keep a reliable reset, simple access to all three load conditions, and the same route layout for fair comparison.
- Do not add menus, saving, a persistent inventory, or full level progression.

## 5. Deliberately Out of Scope

- P004: taking damage causes gold spill; theft, gold loss, enemies taking gold, reclaiming dropped gold.
- P005: expeditions, extraction, banking, failure stakes, settlement economy, or permanent progress.
- Full combat design: enemy AI, enemy health/damage, weapon classes, combos, dodge/stamina, progression builds, final attacks.
- Midas/Gilding powers, magical ability trees, relic systems, or story/canon changes.
- Final movement tuning, permanent burden states, final numerical progression formulas.
- Procedural generation; world redesign; exploration/treasure systems; breakable-loot rewards, digging, river deposits.
- Audio polish and final visual effects; a final Sprite3D/animation pipeline; production-grade player or inventory architecture.

**Clarification:** Temporary breakable *test targets* are permitted to measure impact, but **breakables as a source of gold** are not part of this prototype.

## 6. Technical/Architecture Guardrails for Claude Code

- **Planning-only is now authorized following human approval of this specification.** First inspect repository instructions (`AGENTS.md`, `CLAUDE.md`, `.claude/settings.json`), P001/P002 assets and scripts, the feature specs, and `docs/GOLDKING_PROTOTYPE_LOG.md`.
- In planning, recommend the smallest viable extension that avoids altering P001's validated scene and controller directly. If Gold total must be exposed to P003, propose one clear ownership path instead of adding an autoload, generic inventory, or global event system.
- Favor one P003-specific scene or scene extension, and P003-local experiment scripts/targets. Do not duplicate P002's entire gold collection implementation if a simpler reuse path is sound.
- Make tunable values accessible for fast A/B playtesting; Godot 4.7.2 and typed GDScript.
- Stop and request human review if a seemingly small change requires adopting a permanent combat/controller architecture.
- Code branch, implementation and commits are authorized separately **after** planning review. Do not implement against `main`.

## 7. Mechanical Validation Checklist (Proposed)

- [ ] Project loads and runs with no new engine errors/warnings.
- [ ] P001 basic movement, camera, collision, facing and shadow behavior still work in the unchanged baseline.
- [ ] P002 pickups still collect once, HUD still reflects total, reset still works, Floating remains default.
- [ ] Exactly the intended wealth band activates at test boundaries (e.g., 5→6 and 13→14).
- [ ] The temporary power demonstration produces reproducibly stronger outcomes at higher gold states.
- [ ] The burden variable produces measurable, correct traversal changes and does not break input or collision.
- [ ] The **combined route** can be completed at Light, Loaded, and Heavy; hit counts, completion time, and any contact count are recorded consistently, without damaging the player or changing gold.
- [ ] Separate target-only and movement-only checks can isolate the cause of any combined-route difference; route setup and hazard timing are repeatable enough for comparison.
- [ ] No gold is lost, spilled, stolen, banked or saved.
- [ ] Reset and rapid repeat tests restore a known starting state.
- [ ] There is no regression from the current P002 working baseline.

Passing tests shows **mechanical correctness**, not that the trade-off is fun.

## 8. Human Playtest Plan (Proposed)

**Recommended testers:** Quon and Jason independently if available. Record individual impressions; do not inflate confidence if only one person tests.

**Suggested route:** First collect naturally and observe reactions. Then test the stationary target alone, basic movement alone, and the **combined target → obstacle → finish course** at Light, Loaded, and Heavy gold. Repeat in different orders if feasible so adaptation does not masquerade as improvement. The stopwatch is supporting evidence, not the playtest's main goal.

**Record qualitative and quantitative evidence:**

| Dimension | Question / observation |
| --- | --- |
| Power | Could you *feel* stronger? When did the change become obvious? |
| Burden | Did you notice reduced mobility? Did it feel fair, interesting, annoying or negligible? |
| Danger | Did extra weight create any pressure in the short challenge, or just make everything slower? |
| Desire | Did you still seek additional gold after noticing the cost? Why or why not? |
| Trade-off | In the combined route, did breaking the target faster make slower movement feel worthwhile? Which wealth state would you choose, and would you ever deliberately stop collecting? |
| Responsiveness | Did the P001 movement still feel good enough to play? |
| Clarity | Did you need the HUD or instructions to notice the mechanical differences? |

**Suggested ratings (1–5; diagnostic, not automatic pass/fail):** perceived power, burden fairness, movement feel, desire to collect more, overall trade-off enjoyment.

**Proposed success signals:**

- Power and burden are both perceptible during the test, not just mathematically present.
- Gold remains attractive at richer states, with players able to articulate when/why the extra wealth is worth the drawback.
- No meaningful loss of basic movement reliability or control.
- Some tension or interesting preference emerges when **both mechanics matter together**, rather than every tester trivially rejecting Heavy or always choosing Heavy.
- Players can describe the difference between feeling physically imposing and feeling sluggish; timing alone does not define success.

**Failure/iteration triggers:** Players avoid gold as soon as burden appears; a slow King feels bad to control; power is visible only in a numeric readout; the timed challenge demonstrates inconvenience but not meaningful risk. If so, reconsider the **burden form** before adding complexity or piling on additional systems.

## 9. Completion and Documentation

- Record the approved spec, planning assumptions, mechanical findings, human playtest results, and confidence in `docs/GOLDKING_PROTOTYPE_LOG.md`.
- Keep **mechanical reliability**, **perceived power**, **burden appeal**, and **trade-off quality** separate in the conclusion; P003 can have a mixed outcome.
- Prototype status can be Validated, Iterate, or Invalidated based on human evidence and reviewed scope. Passing automated checks alone is not enough.
- Any longer-term mechanic proposed for approval requires a separate explicit decision; don't silently elevate test thresholds, penalty percentages, or the temporary impact action to durable design.
- No merge until findings have been recorded and reviewed; follow the established feature-branch workflow.

## 10. Approval Status and Remaining Gate

**Approved by Quon for the P003 prototype:**

1. Temporary single-button impact versus stationary test targets.
2. Mild **maximum-speed-only** penalty, beginning with 0% / ~8% / ~16% by wealth state, without altering acceleration or turning responsiveness.
3. **Combined course**: clear a target, navigate one predictable timed obstacle, and finish; compare this with isolated target and movement checks.

**Approval scope and limitations:**

- Three provisional wealth bands (0–5, 6–13, 14+) and illustrative 3 / 2 / 1 target hits are suitable **test starting points**, not final mechanics.
- Keep the entire P003 scope narrow and P004/P005 systems excluded.
- Review the combined course's actual implementation proposal for complexity before any feature branch or code is authorized.

**Current status:** P003 feature specification approved on 2026-11-13. **Claude Code may inspect and produce a plan only.** A separate human architecture/scope review and explicit implementation authorization are still required before creating the feature branch or changing gameplay files.

## 11. Workflow Gate

1. Confirm the P002 documentation/push is complete (reported pushed by Quon).
2. **P003 feature specification approved by Quon (2026-11-13).**
3. Ask Claude Code for a **planning-only** inspection and file-level architecture proposal.
4. Review Claude's plan and scope; authorize a feature branch and implementation separately.
5. Mechanically validate; human playtest; record findings; review the outcome; commit and merge only after evidence is documented.
