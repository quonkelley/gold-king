# P007 — Combat Foundation

**Document:** `docs/features/p007_combat_foundation.md`  
**Status:** Feature specification **approved for technical planning** — implementation not authorized  
**Status update (2026-11-16):** Implementation **authorized** by Quon on the `feat/p007-combat-foundation` branch (local commits only; no push or merge). See the Approval Record.  
**Status update (2026-11-16, Iteration 1):** After P007 Human Playtest 1, Quon approved **Iteration 1 — Lightweight Target Focus**, a controlled A/B experiment on the `feat/p007-target-focus` branch. See §10 and the Approval Record. P007 is not concluded.  
**Status update (2026-11-17, closeout):** The initial implementation and Iteration 1 were completed and tested. P007's current prototype cycle **concluded with outcome Iterate**. See §11 and the Prototype Log.  
**Prototype:** P007 — Combat Foundation (approved feature specification)  
**Prepared:** 2026-11-16  
**Engine context:** Existing Godot 4.x / typed GDScript project and controlled elevated 2.5D presentation; verify the current engine version in the repository before planning  
**Naming convention:** `docs/features/p###_<short_descriptive_name>.md`  
**Dependencies:** P001 movement/camera baseline; selectively reuse tested input/movement ideas and P006's simple sword interaction as references, **not** as approved combat architecture  
**Source boundary:** P006's implementation and closeout were reported merged into `main` at `9a2d62f` on 2026-11-16. Some source snapshots supplied to this drafting session predate that merge. Claude Code must inspect the **current repository** before proposing a technical plan.

> **Approval boundary:** Quon approved the proposed **Combat Foundation prototype scope** on 2026-11-16, including basic sword combat, eight-direction movement-based facing, a directional dodge with brief invulnerability, late-recovery dodge cancellation, and one fightable melee enemy. This draft translates that direction into a proposed test configuration and acceptance criteria. **The feature specification is approved for technical planning. The technical implementation plan, feature branch, and code changes are not yet approved.** Nothing here establishes permanent combat architecture, a production weapon system, or narrative canon.
>
> **Update 2026-11-16:** Quon has since approved the technical implementation plan (with Amendment A and the director review) and authorized implementation. The statement above is preserved as the approval boundary at the time of drafting. Nothing here establishes permanent combat architecture, a production weapon system, or narrative canon.

## 1. Primary Design Question

> **Can one responsive directional sword attack, a brief invulnerable dodge, and one readable melee enemy produce an enjoyable combat exchange within GoldKing's existing 2.5D presentation?**

Measure **three separable outcomes**:

1. **Responsiveness and control:** Does the King attack, turn, and dodge when and where the player expects?
2. **Readability and fairness:** Can the player recognize the sword's hit area, the enemy's attack, and why damage did or did not occur?
3. **Engagement and learning:** Does the player begin to use deliberate positioning, dodge timing, and recovery openings, and want to repeat a short encounter?

A mechanically correct prototype can still fail the human-experience question. Conversely, a short single-enemy encounter can be promising without supporting claims about long-term combat depth or retention.

## 2. Evidence and Decision Status

### Established Canon — unchanged

The Gold King is fundamentally good-hearted, charismatic, flawed, proud, and genuinely attracted to gold. Nothing in this test establishes a new enemy species, training institution, weapon lore, character event, or supernatural gold power. The King's final combat animation/personality is not decided by placeholder art.

### Existing Approved Direction — preserved

- GoldKing uses a controlled elevated camera, 2D characters in a 3D environment, and readable movement/composition.
- Exploration is intended to feel like a connected mythic world. A standalone enclosed **test arena** does **not** imply the full game is room-based.
- Gold remains desirable; ordinary carried gold should not automatically reduce movement or dodge speed. Wealth-driven *external* danger is an Approved Direction with unresolved implementation.
- Expeditions and a persistent, lightly automated settlement complement one another, but this prototype deliberately isolates combat from their progression loop.

### Completed prototype evidence — not overclaimed

- **P003:** Tested a strike against targets and gold-related movement burden; the automatic burden direction was superseded. Do **not** import its movement penalties as current combat rules.
- **P004:** Tested a thief and gold spill/transfer behavior, not fightable-enemy combat AI.
- **P005:** Tested exploration/extraction, not damage-based combat.
- **P006:** Showed a promising integrated reward loop; its purchased sword breaks containers, **not enemies**. The P006 cycle concluded **Iterate**, with no further P006 work planned. Its sword, merchant, shop, and hub structures are not permanent combat or equipment decisions.

### Approved for this prototype's design scope — Quon, 2026-11-16

- **One** sword attack, **one** fightable melee enemy, and **one** repeatable combat arena.
- **Eight-direction movement-based facing**, without independent aiming or automatic targeting assistance as the starting test.
- A **directional dodge** with **brief invulnerability frames**.
- **Limited dodge cancellation during late attack recovery**, but not during windup, active swing, or early recovery.
- A simple enemy with readable approach, windup, committed strike, and recovery.
- A standalone test rather than immediate integration into P006's expedition, treasury, or merchant loop.

### Prototype Assumptions / Strong Recommendations — not finalized mechanics

All timings, ranges, health values, control bindings, VFX placeholders, simplified AI states, tuning variables, and exact test metrics below are **proposed starting conditions** for P007. They are not approved production balance, animation design, architecture, or future-combat defaults. A later specification review may change them.

## 3. Desired Player Experience

1. The test loads directly into a small arena. The King already carries a functional prototype sword; the enemy is present, with no preceding merchant purchase or expedition.
2. The player approaches, turns in eight directions, and makes a fast, recognizable forward sword swing.
3. The sword hits when an enemy is visibly inside its directional reach, and misses when the enemy is clearly outside it.
4. The enemy approaches, visibly prepares its attack, **commits its direction**, strikes, and recovers. The player can recognize the danger rather than feeling struck by invisible or homing damage.
5. The player can avoid an attack by moving or by timing a dodge with a brief invulnerable interval. Dodging is useful but not mandatory for every attack.
6. A poorly timed attack leaves the King briefly vulnerable; an attack finishing in late recovery can be dodge-canceled. An intentional dodge-and-counterattack feels responsive.
7. Hits, damage taken, enemy defeat, and player defeat are unambiguous. The encounter can be restarted immediately for comparison.

**Emotional target:** “I knew where I was swinging, saw that attack coming, dodged it, and found my chance to strike back.”

This test evaluates a *single satisfying exchange*, not a complete combat loop with weapon variety, enemy rosters, rewards, or difficulty progression.

## 4. Smallest Useful Prototype

### 4.1 Scene boundary and reuse

- One **standalone P007 combat test scene**, directly runnable for repeated trials. Do not require P006 camp interaction, owning the sword, an expedition, or gold collection.
- Preserve P001–P006 historical prototype scenes, scripts, recorded results, and regression-test behavior. Selectively reuse movement/controller/input patterns **only after current-repo inspection**.
- The arena is compact, flat enough for clear top-down collision/attack tests, and visually uncluttered. Use placeholder geometry, sprite(s), and simple effects. This is a test fixture, not a world-layout decision.
- Include a clear encounter-start state, win/loss state, and **quick retry** that resets health, enemy state, cooldowns, and hit registries. No menu system or save architecture required.
- If the current project's main-scene setting complicates old regression tests, the technical plan must handle that without rewriting historical assertions or test outcomes. Do not silently replace P006's gameplay data or runtime logic.

### 4.2 Player facing and sword attack

**Proposed input baseline:** existing WASD / arrow keys / left stick for movement, `attack` action currently associated with **J, Space, and gamepad west face button** in P006. Confirm the current input map before implementation. Preserve existing historical bindings rather than making a global input remap by assumption.

- Face **one of eight directions** based on the last nonzero intentional movement input in the world ground plane, interpreted consistently with the controlled camera. A reasonable deadzone prevents analog-stick drift from changing facing.
- With no current movement input, retain the last valid facing direction.
- Snapshot attack direction at the moment a swing starts. Movement can continue, but no mid-swing aim steering, auto-homing, or target selection.
- One quick, manually triggered **frontal arc** attack; each target can receive damage **at most once per swing**. Repeated button presses do not bypass attack timing. Holding the button does not generate an automatic chain.
- Sword reach, arc width, windup, active window, recovery, and optional movement scaling are editable test values; no combos or heavy attacks.
- Provide a plainly visible arc/timing cue on the ground plane or aligned to the player's facing so players and developers can judge hit area against collision results.

**Initial tuning proposal (not final):**

| Property | Starting value |
|---|---|
| Sword coverage | ~110° forward arc |
| Sword reach | ~1.4 world units |
| Windup | 0.08 s |
| Active hit window | 0.12 s |
| Recovery | 0.20 s |
| Total attack cycle | ~0.40 s |
| Movement during attack | Allowed; no automatic gold-related movement penalty |
| Attack buffering / repeat-hold / combos | Not implemented in initial test |

Use existing physical-scale conventions where possible; these world-space numbers are tunable examples, not a mandate to resize characters or arenas.

### 4.3 Dodge and invulnerability

**Proposed input:** Left Shift / gamepad east face button (B on an Xbox layout), as a dedicated P007 dodge action. Confirm compatibility with the current map and avoid altering P001–P006 inputs globally.

- A discrete button press initiates one dodge when permitted; holding the button must **not** repeatedly dodge.
- Direction is the current normalized movement input; if neutral, use the last valid facing direction. Dodge respects world collision and must not tunnel through arena boundaries.
- Dodge movement is visibly distinct from walking. A **short invulnerability window within the dodge** blocks this prototype enemy's damage; invulnerability is not active for the entire dodge by default.
- Dodge uses a cooldown, with no stamina bar, cost, perfect-dodge reward, block, parry, counter mechanic, or animation commitment outside this test.
- On starting a dodge during permitted late sword recovery, cancel the remainder of the sword's recovery cleanly. It must **not** create another hit, prolong the prior hitbox, or permit duplicate damage. Dodge cannot begin during windup, active swing, or early recovery.
- The dodge direction/facing interaction must be visible enough to test whether the King awkwardly faces away from the enemy after retreating. Do not silently fix this with target lock-on.

**Initial tuning proposal (not final):**

| Property | Starting value |
|---|---|
| Dodge duration | ~0.20 s |
| Dodge displacement | ~1.75 world units |
| Invulnerable interval | Approximately 0.04–0.16 s after dodge start (tunable) |
| Cooldown | ~0.70 s |
| Dodge cancel allowed | Final ~0.10 s of sword recovery only |
| Stamina cost | None |
| Obstacle collision | Active |

Specify whether cooldown starts on dodge start or end in the implementation plan, then test that consistently. These are deliberately modest and adjustable timings, not approval of exact invulnerability-frame counts.

### 4.4 One fightable enemy

- **Placeholder Training Enemy**, with no canonical species, equipment, dialogue, or lore.
- A minimal readable state flow: **Approach → Windup → Commit/Strike → Recovery → Approach**. Commit can be a boundary within windup rather than a complex extra AI state.
- Approach until within practical melee range. A visible windup communicates both *when* and *where* the attack will occur.
- **Lock the enemy's attack direction before the damaging strike**; no last-frame rotation or perfect tracking after commitment.
- Strike in a fixed defined directional area. On a successful overlap, apply **at most one player hit per enemy strike** when the player is not invulnerable.
- A recovery interval provides a real counterattack opening. Normal player sword hits display impact feedback but should not automatically interrupt/stun-lock every enemy attack.
- A defeated enemy stops all attacks/damage and shows a clear defeat state.
- Contact/overlap without a committed attack does not damage the player.

**Initial tuning proposal (not final):**

| Property | Starting value |
|---|---|
| Player health | 3 enemy hits |
| Enemy health | 3 player sword hits |
| Enemy strike damage | 1 health unit |
| Enemy movement | Slower than player movement |
| Enemy windup | ~0.50 s |
| Enemy active strike | ~0.15 s |
| Enemy recovery | ~0.60 s |
| Contact damage | None |
| Simultaneous enemies | One |

### 4.5 Feedback and instrumentation

Minimum readable feedback, not finished art direction:

- Sword swing indicator showing its direction and coverage, synchronized with actual damage timing.
- Enemy attack telegraph aligned to the true future strike zone and commitment direction.
- Visually distinct hit/miss/blocked-by-dodge outcomes: e.g., flash or small impact effect, simple sound if inexpensive, and clear health display.
- Player hit and enemy defeat indication; obvious win/loss and retry prompt.
- **Developer-only toggle/debug view** showing player attack phase, snapped facing, dodge state/invulnerability, enemy state/commit direction, and health, with only useful instrumentation (not a permanent combat HUD or generalized telemetry system).
- Keep visuals simple enough that players can judge controls without being distracted by placeholders or hidden hitboxes. Full eight-direction sprite animation, professional VFX, camera shake, and hit-stop are optional *later* explorations, not required to pass this prototype.

### 4.6 Test conditions and resets

- One default encounter with fixed, repeatable initial positions, facing, and timings.
- Reliable retry after enemy defeat or player defeat; same initial conditions unless the tester deliberately changes a debug/tuning parameter.
- Optional developer toggles may help isolate whether the dodge or cancellation window works, but don't build an A/B experimentation framework or treat debug toggles as production features.
- Record the *actual* tuning values used for each human test in the Prototype Log; don't mix observations from materially different configurations without labeling them.

## 5. Explicit Non-Goals

Do **not** implement or imply approval of:

- Additional weapons, weapon switching, combos, heavy/charged attacks, ranged aiming, target-lock, aim assist, weapon loot, equipment slots, or inventory.
- Blocking, parrying, stamina, perfect-dodge bonuses, counterattack abilities, skill trees, upgrade costs, or relic synergies.
- Multiple enemy types, enemy packs, bosses, complex pathfinding, dynamic difficulty, wealth-responsive enemy spawns, or an enemy architecture designed for an entire game.
- Gold collection, gold-powered attacks, theft, drop rewards, treasury purchases, merchant interactions, or integration into P006's expedition/settlement sequence.
- Procedural arena generation, authored-world content, quest dialogue, new narrative lore/canon, or a permanent arena-based level structure.
- Final animation pipeline, eight-direction production sprite sets, polished materials/VFX, full UI, sound design pipeline, production save/load, or generalized combat engine abstractions.

> **Iteration 1 note (2026-11-16):** For the Iteration 1 experiment only (§10), Quon narrowed the *target-lock* / *aim assist* exclusion above to allow one toggleable, single-enemy target focus that chooses the King's eight-direction facing. The exclusion otherwise stands, and this does not approve target-lock or aim assistance as a production mechanic.

The **Approved Direction** of wealth-driven *external danger* remains intact but is not tested here. Never reintroduce automatic movement penalties from ordinary gold as a shortcut for combat balance.

## 6. Mechanical Acceptance Criteria — after separate implementation authorization

Mechanical checks should use automated regression tests where practical, supplemented by windowed/manual tests for input feel and visual readability. An automated pass is **not** human combat validation.

1. **Scene/test isolation:** P007 starts directly, resets predictably, and does not depend on P006 treasury/shop or mutate P001–P006 historical scenes.
2. **Cardinal/diagonal facing:** All eight valid movement directions produce the correct facing; diagonal inputs remain normalized; neutral input retains last facing; analog deadzone avoids jitter.
3. **Attack direction lock:** Once a swing begins, turning/moving does not rotate its hit arc for that attack.
4. **Directional geometry:** Clearly placed targets inside the active sword arc receive damage; equally clear targets behind/outside reach/arc do not. Edge cases have deterministic rules.
5. **Sword hit limits:** Each enemy takes at most one hit per swing; no damage occurs during sword windup or recovery; attacks cannot be multiplied by key-repeat/holding inputs.
6. **Dodge activation:** Current movement directs dodge, neutral uses retained facing; a held input does not trigger repeated dodges; cooldown prevents immediate reuse; collision prevents wall traversal.
7. **Invulnerability window:** An enemy strike overlapping the player during the configured dodge invulnerability interval causes no damage; one immediately before and after it can cause damage if the overlap conditions are met.
   - **Clarification (Amendment A, approved 2026-11-16):** each enemy strike resolves against the King **once, on first contact**. First contact during dodge invulnerability confirms a successful dodge and consumes that strike, so it cannot damage the King later in the same active window. First contact before or after the invulnerability interval may cause damage normally. A strike that never contacts the King causes no damage. Each strike produces at most one hit or one confirmed dodge.
8. **Attack cancellation:** Dodge is rejected during windup, active swing, and early recovery and accepted during late recovery and idle/eligible movement; accepted cancellation cleans up any previous sword state/hitbox.
9. **Enemy states:** Approach, telegraph, strike, recovery, and defeat are observable; committed enemy strike direction remains fixed after the commit boundary.
10. **Enemy hit limits:** Each enemy strike inflicts at most one hit; contact without a strike inflicts none; defeat prevents further damage.
11. **Feedback truthfulness:** Attack and telegraph indicators correspond to tested collision regions and active times; health and hit confirmation match actual results.
12. **Retry/idempotency:** Restart restores health, positions, cooldowns, and hit registries; no duplicate enemies, stale invulnerability, or accumulated damage timers.
13. **Input isolation:** Existing attack/interaction mappings still behave in the historical prototypes; dedicated P007 dodge doesn't inadvertently confirm UI actions or alter earlier prototype input behavior.
14. **Regression safety:** Run the available P003–P006 suites and any relevant earlier checks in the **current** repository. Record exact counts, environment, and expected main-scene assertions; do not silently delete or weaken a historical test to achieve green results.
15. **Manual windowed control check:** Human operator verifies keyboard and, if accessible, gamepad sword/dodge behavior, visible facing, telegraph alignment, late-recovery cancellation feel, and clean retry.

A focused test harness is preferable to a broad new combat architecture. Exact test-file paths and scene structure belong in the technical plan after repository inspection.

## 7. Human Playtest Plan

### Test population and setup

- First pass: Quon plus **two or three** players not implementing the feature, if available. Small sample: directional evidence only, not a generalizable usability or retention study.
- Use the same recorded build and combat tuning. Give players **movement, attack, and dodge controls**, but **do not explain** the enemy's windup/commit/recovery sequence.
- Ask each tester to try the encounter several times; do not force a win or keep players until bored. Keep instruction, timing, and feedback collection consistent.
- If controls or UI prevent a meaningful attempt, record that separately instead of classifying the combat mechanics themselves as a failure.

### Observe first, ask second

Record as **Direct Observation** where possible:

- Can the player turn toward an enemy and land intentional frontal hits, including diagonal approaches?
- Does the player appear to understand the enemy telegraph after a few attempts? What did they do before being told its pattern?
- Does the player intentionally avoid at least one attack by walking or dodging? Can they explain why the dodge succeeded/failed?
- Do they recognize and exploit the enemy recovery window, or win mainly by repeated attack presses?
- Do they experience unexpected hits or misses, awkward post-dodge facing, confusing late-recovery input rejection, or unclear defeat?
- Do they request another attempt unprompted? **Keep observed voluntary retries separate from stated desire to retry.**

Useful **Measured Data**, if easy to capture: encounter attempts, victories/defeats, whether an intentional dodge avoided a strike, surprising-hit complaints, and voluntary retries. Do not add extensive analytics solely to collect numbers.

### Post-play feedback — six separate 1–5 ratings

1. Attack responsiveness.
2. Directional control / knowing where the sword would swing.
3. Dodge responsiveness.
4. Enemy attack readability/fairness.
5. Overall enjoyment of an individual combat exchange.
6. Desire to fight the enemy again.

Ask open questions: *What felt best? What felt unfair or confusing? When did you decide to dodge? Did the sword go where you expected? What would you change first?* Preserve player comments as **Player Report**, separate from what was observed.

### Predeclared supportive and warning signals

**Supportive / promising:** Most testers can intentionally land directional hits, identify at least one telegraph, evade an attack using movement/dodge after limited exposure, and respond to an enemy recovery window. Players describe sword/dodge as responsive and the brief exchange as engaging. A tentative target is **4/5 or better for responsiveness and overall exchange enjoyment**, but interpret small-sample ratings alongside behavior, not as automatic validation.

**Warning / Iterate:** Repeated apparent hits fail to register; dodge feels arbitrary or unreliable; telegraph and actual damage disagree; turning to attack frequently causes frustration; late-recovery cancellation feels like swallowed input; enemies can be defeated entirely by indiscriminate swing spam without engaging with their attacks.

**Inconclusive:** Visual/input defects prevent fair exposure; players receive inconsistent instructions; tuning changes substantially between participants without labeling; the fight is too trivial or too punishing to exercise dodge or enemy recovery; testers cannot distinguish control problems from combat timing.

**Scope discipline:** Repetition or lack of enemy variety after a few attempts is expected, **not** evidence by itself that the basic exchange failed. Conversely, do not declare all of GoldKing's combat validated because one simple enemy feels good.

## 8. Risks, Guardrails, and Questions for Review

1. **Presentation geometry:** Eight-direction world-plane attacks and sprite facing can visually disagree. Check actual camera-space/world-space mapping early; ground-plane cues are an evaluation tool, not mandatory final visuals.
2. **Input conflict:** P006 already exposed `Space` overlapping `ui_accept`, plus missing gamepad confirmation. Avoid global changes to `ui_accept`; isolate P007 attack/dodge behavior and preserve historical scenes.
3. **Attack commitment vs. responsiveness:** Limited cancellation may feel restrictive when an enemy unexpectedly attacks. Test the specific recovery boundary before adding input buffering or universal cancellations.
4. **Dodge power:** If invulnerability covers too much of dodge or cooldown is too short, players may ignore positioning; if too short or unreadable, dodge may feel unfair.
5. **Movement-based facing trade-off:** Retreating changes orientation and may make immediate counterattacks awkward. Observe first; don't mask this with auto-targeting.
6. **Enemy fairness:** An enemy that tracks through the strike or attacks without telegraph will not meaningfully test intentional dodging.
7. **Triviality and spam:** One slow enemy may be defeated before players experience a real exchange. Tune health/recovery thoughtfully rather than adding a second enemy or combat systems prematurely.
8. **Hit feedback:** Placeholder visuals still need to communicate true collision. Resist polishing animation and VFX before solving control geometry.
9. **Unapproved architecture:** Existing P006 scene/session/controller inheritance and P003 strike aren't automatically the correct combat foundation. Claude must inspect the current repository before proposing reuse.
10. **Scope creep:** No persistent character health, settlement recovery, gold loss on death, gear economy, or enemy rewards in P007. These belong to a future integrated expedition-combat experiment.

**Open for technical planning and playtest iteration:** Exact engine version; node/scene composition; camera-aligned eight-way facing math; world-space arc hit-testing; dodge hitbox/iframe implementation; input action locality; whether collision prevents overlapping player/enemy; initial spawn distance; which diagnostics genuinely speed investigation; and whether audiovisual hit feedback is sufficient without finished animation.

None of these open points requires adding new gameplay pillars before P007 is tested.

## 9. Documentation and Approval Gates

### Current status — specification approved for planning

**Already approved:** The Combat Foundation **prototype scope and this complete feature specification**, including eight-direction movement-facing, brief invulnerable dodge, limited late-recovery cancellation, the focused test boundary, and the stated acceptance criteria. The numeric tuning values remain editable Prototype Assumptions.

**Not yet approved:** A repository technical implementation plan, creation of a feature branch, code edits, implementation, final tuning values, or permanent production combat mechanics.

**2026-11-16 — Quon:** Approved this complete feature specification **for technical planning**. This approval does not authorize implementation or creation of a feature branch.

### After spec approval — planning-only Claude Code handoff

Claude Code may then inspect the current `main`, `AGENTS.md`/`CLAUDE.md`, input map, movement scenes, P003–P006 scripts, available tests, and current Godot version. Request a **planning-only** proposal that names minimal files, reuse vs. isolation choices, test strategy, a short staged implementation path, and concrete risks. Claude stops for human review and must not create a branch or implement P007 merely because the spec was approved for planning.

### After explicit technical-plan/implementation authorization

Build the smallest playable P007 and mechanically validate it. Preserve old prototypes and distinguish automated checks from windowed/human evidence. A new main-scene default or test-runner adjustment requires explicit review for regression consequences.

### After human testing

Add a P007 entry to `docs/GOLDKING_PROTOTYPE_LOG.md` using its established **20-section format**, including actual Godot/build/commit, test configuration and values, tester count, Direct Observations, Measured Data, Player Reports, Developer Interpretations, regression outputs, limitations, outcome (**Validated / Iterate / Rejected / Inconclusive / Deferred**), confidence, and next test. Record any consequential approved decisions separately; do not silently promote sword timings, dodge frames, enemy archetype, or training arena to permanent design.

## 10. Iteration 1 — Lightweight Target Focus (approved 2026-11-16)

**Why:** In P007 Human Playtest 1 (Quon, developer; build `706c9d5`; see the Prototype Log), attack direction and accuracy were rated 2/5. The main reported problem was that movement-based facing turns the King away from the enemy while retreating, so attacking while retreating or strafing was unreliable. This is a developer playtest observation, not an independently verified defect.

**Research question:** Does lightweight target focus improve directional melee control and combat enjoyment compared with P007's original eight-direction movement-based facing?

**Controlled comparison (same arena, camera, spawns, sword, dodge, and enemy in both modes):**

- **Mode A — original baseline:** eight-direction movement-based facing exactly as implemented at `706c9d5`. Target focus is unavailable. Mode A remains the comparison baseline.
- **Mode B — toggleable target focus:** the player may toggle focus on the single living Training Enemy. While focused, the direction toward the enemy (instead of movement input) chooses the King's facing; movement still moves the King in the same world/screen directions.

**Constraints (Amendment B of the technical plan):**

- Focused facing uses the **existing eight-direction snapping**. No continuous aiming and no smoothing at the 22.5° boundaries.
- **Neutral dodge behavior is unchanged** in both modes: with no movement input the dodge travels along the current facing. While focused this can send the King toward the enemy, where solid collision stops him. This is a deliberate experimental constraint; any awkwardness is to be recorded, not corrected, during this iteration.
- Sword timing, reach, arc, damage, attack-direction snapshot, and hit resolution are unchanged. Focus never moves the King, never redirects an active swing, and never enlarges the hit area.
- Dodge distance, duration, invulnerability, cooldown, late-recovery cancellation, and collision are unchanged. Focus persists through dodges.
- Acquisition range 7.0 m and release range 9.0 m (ground plane), Tab / gamepad RB toggle, and F2 facilitator mode switch are starting Prototype Assumptions.

**Excluded from Iteration 1:** camera lock-on or rotation, target cycling, multiple enemies, independent mouse/right-stick aiming, aim magnetism, expanded hitboxes, new attacks or weapons, sword/dodge/enemy balance changes, new telegraphs or dodge VFX, polished animation, generalized targeting architecture, changes to P001–P006, and any permanent combat decision.

**Known P007 findings not addressed by Iteration 1:** the centre-point hit/miss readability finding, dodge readability, and enemy telegraph readability remain recorded findings.

## 11. Closeout (2026-11-17)

Both the initial P007 implementation (`706c9d5`) and Iteration 1 (`feat/p007-target-focus`) were completed, regression-tested (696 checks across P003–P007, 0 failures), and played by Quon. **Outcome: Iterate — current prototype cycle concluded.**

- Human Playtest 1 found substantial control friction with movement-based facing.
- In the Iteration 1 A/B comparison, Quon strongly preferred lightweight target focus (Mode B) and reported much greater control and engagement. One developer tester; qualitative; no Mode B ratings.
- Quon attributed the low dodge-feel and enemy-readability ratings largely to placeholder presentation; this is a developer interpretation, not a tested cause.
- Opponent-focused combat is carried forward as a promising direction. Nothing in this specification — including the §10 targeting exception, the controls, timings, ranges, eight-direction facing, enemy behavior, or architecture — is approved as production design. The §5 exclusion narrowing applied to Iteration 1 only.

The approvals, exclusions, and amendments above are kept as history. Full findings: `docs/GOLDKING_PROTOTYPE_LOG.md`, P007.

---

## Approval Record

**2026-11-16 — Quon:** Approved the proposed P007 Combat Foundation **scope as the basis for drafting** this feature specification. Approved for prototyping in principle: basic sword, eight-direction movement-based facing, short dodge with invulnerability, late-recovery dodge cancellation, one fightable melee enemy, standalone repeatable test environment. **This is not approval of the finished specification or implementation.**

**2026-11-16 — Quon:** Approved the completed P007 Combat Foundation feature specification **for technical planning**. Proposed timings, ranges, and controls remain Prototype Assumptions, not permanent balance or mechanics.  

**Specification approval:** Approved for technical planning.  
**Technical planning:** Authorized for read-only current-repository inspection and a plan proposal.  
**Feature branch / implementation:** Not authorized.  
**Historical prototypes / established canon:** Unchanged.

**2026-11-16 — Quon:** Approved the P007 technical implementation plan, Amendment A, and the director review, and **authorized implementation** on `feat/p007-combat-foundation`, including automated tests, windowed developer validation, and local commits. Pushing and merging are not authorized. The director review supersedes Amendment A's proposed anti-spam pass conditions: attack spam winning is not automatically a failure; deliberate fighting must be viable; the encounter starts with 3 enemy health; any tuning change must be conservative and recorded with its motivating observation. All tuning values remain Prototype Assumptions.

**Feature branch / implementation:** Authorized (2026-11-16).  
**Push / merge:** Not authorized.  
**Human playtest outcome:** Not yet recorded.

**2026-11-16 — Quon:** Approved **P007 Iteration 1 — Lightweight Target Focus** (§10) as a controlled experiment comparing Mode A (original movement-based facing) with Mode B (toggleable single-enemy target focus), and approved the technical plan with Amendment B. Implementation authorized on `feat/p007-target-focus`, branched from `706c9d5` so the Human Playtest 1 build remains available. The §5 target-lock / aim-assist exclusion is narrowed for this experiment only. Pushing, merging, and concluding P007 are not authorized.

**Iteration 1 implementation:** Authorized (2026-11-16).  
**Push / merge / P007 outcome:** Not authorized; P007 remains open.

**2026-11-17 — Quon:** Concluded P007 — Combat Foundation for the current prototype cycle with outcome **Iterate**, and concluded the foundational prototype cycle (P001–P007). The next stage is planning a First Integrated Playable Experience (Decision Log, 2026-11-17). Pushing and merging are not part of this closeout.

**P007 outcome:** Iterate (2026-11-17).
