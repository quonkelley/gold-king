# P004 — Gold Spill & Theft

**Document:** `docs/features/p004_gold_spill_theft.md`  
**Status:** Approved P004 prototype feature specification — **planning-only repository review authorized; implementation not yet authorized** (approved by Quon, 2026-11-14)  
**Status note (2026-11-14):** Implementation was subsequently approved by Quon. P004 was implemented and tested on `feat/p004-gold-spill-theft` (one human playtest), and its current prototype cycle is concluded (outcome: Iterate). This specification is otherwise unchanged and is kept as the historical record of the approved scope; see the P004 entry in `docs/GOLDKING_PROTOTYPE_LOG.md` for results.  
**Prototype:** P004  
**Depends on:** P001 — Player Movement & Controlled Camera (validated movement baseline); P002 — Gold Collection (working collection baseline accepted; feedback polish deferred); P003 — Gold Power vs. Burden (current cycle concluded, outcome Iterate; historical test only)  
**Engine context:** Godot 4.7.2; typed GDScript; 2.5D scene with controlled camera  
**Repository context:** P003 remained the default project scene at its local merge. Confirm the current repository state and deliberately select P004's scene during implementation planning; do not inherit P003's experimental speed penalties.  
**Naming convention:** `docs/features/p###_<short_descriptive_name>.md`

## 1. Primary Design Question

> **Can the threat of losing collected gold create exciting, readable tension and motivate the player to protect their fortune without making them regret collecting it?**

**Supporting questions**

1. Does a thief's interest in the King's wealth feel understandable rather than arbitrary?
2. Can the player tell when gold spills, which gold is recoverable, and what has been taken?
3. Does having a chance to prevent or recover the loss create meaningful agency?
4. Does a small real risk of loss make collecting gold *more* compelling, or teach players to avoid it?
5. Does the encounter feel fair and enjoyable enough to justify further prototyping of external danger?

P004 tests **a local gold-loss/recovery interaction**, not the complete expedition failure loop, permanent economy, combat system, or wealth-driven difficulty scaling.

## 2. Source Alignment and Decision Status

**Established Canon:** The Gold King is a good-hearted, charismatic, flawed ruler who genuinely loves treasure. Gold should remain desirable and enjoyable. The game explores greed, consequences, value versus price, and the King's return from exile.

**Approved Direction (2026-11-14):** Ordinary gold should remain lucrative and contribute to the King's power, while growing wealth creates potential for external danger, attention, and vulnerability. Automatic movement-speed penalties from ordinary gold are **superseded as the intended core downside**. Exact enemy behavior, gold-power scaling, and threat escalation remain unresolved.

**Approved expedition direction:** Wealth carried away from the settlement is unsecured. Losing an expedition may forfeit unsecured ordinary loot, while previously secured wealth and progression remain safe. **P004 does not implement full expedition failure or settlement banking.**

**Evidence entering P004:**

- P001 established a responsive movement/camera baseline.
- P002's floating proximity pickups were preferable to grounded pickups; basic collection worked, while sound/visual polish and the pouch's long-term role remained unresolved.
- P003 showed that a short-session power-versus-speed trade-off could be enjoyable, but automatic speed loss was superseded after concerns about expedition-scale traversal. Its temporary strike and speed states are not approved production combat.
- Quon approved **external wealth-driven danger** as the core alternative, with optional heavy forms and substantial-item encumbrance preserved only as Experimental Ideas.

**Approved P004 prototype scope (2026-11-14):** Quon approved a **single thief** with a readable approach, a small contact-triggered gold spill, a theft opportunity, and **movement-based chasing/interception** to recover the gold. Initial caps are **up to 3 gold spilled and up to 1 gold stolen per encounter**, both tunable Prototype Assumptions rather than final balance rules. P004 must start from the **P001/P002 movement/collection baseline without P003 automatic gold-based slowdown**. This approval authorizes planning-only review of the implementation, not gameplay coding or a permanent core-game defense mechanic.

**Unresolved Prototype Assumptions:** Exact timings, visual warnings, interception radius, escape route, scripted behavior, spawn placement, and architecture remain tunable test details. Any proposed scope expansion still requires review.

## 3. Desired Player Experience

1. Explore and collect floating gold in a familiar, responsive scene; ordinary gold does not slow the King down.
2. Notice a suspicious, clearly readable thief attracted to the King's unsecured fortune.
3. Have an opportunity to avoid the thief; if contact occurs, see a small portion of carried gold scatter visibly nearby.
4. Decide quickly whether to retrieve the loose gold or intercept the thief attempting to take it.
5. Recover some or all of the spill through active play, or experience a limited, understandable loss if the thief escapes with it.
6. Remain motivated to collect more gold afterward.

**Emotional target:** “That's *my* gold—get back here!” rather than “I shouldn't have picked up those coins.”

## 4. Smallest Useful Prototype — Approved Test Scope

### 4.1 Baseline and Scene Boundary

**Approved prototype baseline:** Start P004 from the **P002 collection and P001 movement baseline**, or reuse their underlying components without importing P003's wealth-based movement penalty. Preserve the P002 floating gold pickups, proximity collection, HUD counter, placeholder pickup feedback, and provisional pouch where convenient.

- Keep normal movement unchanged by carried gold.
- Create a separate, repeatable P004 test scene or isolated test area; do not overwrite P003's historical course.
- **Do not reuse or require P003's temporary strike for this experiment.** Chase and movement-based interception are the selected prototype approach; a future change to combat-based defense requires separate review.
- Do not add new production combat or inventory architecture.

### 4.2 One Thief, One Readable Encounter

**Approved single-encounter test:** A placeholder thief becomes interested when the King is carrying ordinary gold. In one small authored area, the thief visibly approaches, attempts one theft, and retreats toward a reachable exit.

- Telegraph the approach with simple animation, movement, silhouette, sound, or a short icon; placeholder graphics are acceptable.
- Favor simple scripted movement/waypoints over a general enemy navigation or behavior-tree system.
- A player with no carried gold cannot lose any; the thief should not create gold from nothing.
- Avoid repeated instant-contact attacks, unavoidable chain theft, offscreen surprises, or permanent roaming enemies.
- Use a trial reset so the same encounter can be compared fairly.

**Approved prototype-only starting quantities:** If the thief makes contact, spill up to **3 units** of currently carried gold into nearby reachable pickups. The thief can claim **at most 1 spilled unit** during that encounter and escape with it. Quon approved these as **tunable prototype test values**, not permanent balance decisions.

### 4.3 Gold Spill, Recovery, and Theft

**Proposed event sequence:**

`Carry gold → thief approaches → contact spills a few units → player reclaims loose gold / thief claims a unit → player intercepts or thief escapes`

- Spilled gold leaves the carried balance immediately and reappears as a small cluster of clearly visible, reachable pickup objects. Recollection uses the existing automatic pickup interaction.
- The thief may take an uncollected spilled unit. Gold the player already recovered cannot also be stolen.
- If the player reaches the fleeing thief and tags it through a simple proximity/interception condition, the thief drops its claimed gold as a recoverable pickup. **No attack input or strike is needed.** The interception radius and timing are tunable Prototype Assumptions; tagging is not an approved final combat mechanic.
- If the thief escapes while holding the gold, that amount is lost from the **current test haul only**. The prototype does not touch secured wealth or persistent progression.
- If the player recovers all spill before the thief claims any, the thief escapes empty-handed. This is a meaningful successful outcome, not a test failure.
- Prevent loss loops: only one spill/theft attempt per reset; never remove more gold than the King actually carries.
- Keep the interaction readable at the normal camera distance. No inventory interface or separate dropped-gold management screen.

**Plan flexibility:** Claude Code may propose a *smaller* equivalent sequence if a scripted thief picking up spilled coins is disproportionately costly. Any simplification must preserve visible gold loss, an external actor responsible for the loss, and an understandable player opportunity to recover or defend the gold. Obtain human approval before implementation.

### 4.4 Minimal Feedback and Test Instrumentation

- Keep the familiar carried-gold HUD and collection feedback.
- Use clear placeholder spill feedback (sound/short burst) and an obvious indicator that the thief is carrying stolen gold.
- Do not add a permanent threat meter, detailed combat HUD, or complex loot markers.
- Print concise test-only results such as starting gold, spilled, recovered, stolen, escaped/lost, and ending carried gold. A test HUD line is optional if it improves observation without clutter.
- Provide deterministic restart, and optionally test-only low/high starting-gold presets. These presets are **not** player-facing progression or wealth tiers.

**Conservation invariant for validation:** After each step, all current-test gold must be accounted for as **carried + spilled on ground + thief-held + escaped/lost** (with normal uncollected level gold tracked separately). A given unit must never be both collected and stolen.

### 4.5 Test Conditions

Use a small set of repeatable scenarios:

| Condition | Purpose | Expected observable result |
| --- | --- | --- |
| 0 carried gold | Safety/control | No negative gold, phantom spill, or created theft |
| Modest carried amount (e.g. 10) | Main uncoached test | Player sees warning, possible spill, potential chase/recovery |
| Larger carried amount (e.g. 20) | Perception check | Wealth still feels worth carrying; loss remains limited and readable |
| Player avoids contact | Agency check | Gold retained without triggering an unavoidable penalty |
| Thief escapes / thief intercepted | Outcome contrast | Loss and recovery are correctly represented and understandable |

The difference between modest and larger amounts **does not introduce dynamic enemy scaling**. The only wealth-dependent test behavior required is that the thief has something to target when the King carries gold.

## 5. Explicit Non-Goals

P004 must **not** introduce:

- A wealth-based enemy spawning director, escalation formula, or threat-meter system.
- Multiple enemy types, factions, patrol ecosystems, pathfinding frameworks, or combat AI architecture.
- Player health, full combat damage, permanent death, a boss, or finalized defense actions.
- The P003 automatic gold-weight speed penalty.
- Settlement banking, full-run failure/loss, extraction, permanent economy, or item inventories.
- Optional gold-powered heavy form, large-item encumbrance, Midas/Gilding powers, equipment systems, or new lore canon.
- Audio/visual polish beyond minimum legibility, new treasure acquisition methods, or a full environment redesign.

If any of these seem essential to the test, record why and seek scope approval rather than adding them silently.

## 6. Mechanical Acceptance Criteria

Before human testing, the following must be demonstrated with Godot 4.7.2 (automated where practical):

- [ ] P004 launches without scene/script errors; P001/P002 movement and gold pickups still work.
- [ ] Ordinary gold does not alter top movement speed or turning responsiveness.
- [ ] A telegraphed thief encounter triggers at most once per trial reset.
- [ ] A player can avoid the event through movement; the thief does not cause repeated unfair contact loss.
- [ ] Spill quantities are bounded by current carried gold and the configured spill cap.
- [ ] Spilled coins are visible, reachable, and recollected exactly once by the existing pickup interaction.
- [ ] The thief cannot claim coins already recovered or hold more than the configured theft cap.
- [ ] Interception correctly makes thief-held gold recoverable; escaping removes only thief-held gold from this test haul.
- [ ] HUD/pouch and test results agree with the actual carried total after loss and recovery.
- [ ] The conservation invariant holds with 0, modest, and larger starting amounts.
- [ ] Presets/restart restore a reproducible encounter and do not duplicate or erase unrelated level pickups.
- [ ] Previously committed `tests/p003_regression.gd` remains runnable and its historical P003 checks pass (it is not required that P004 inherit P003 gameplay behavior).

Mechanical correctness is necessary but **not evidence that theft feels fair or fun**.

## 7. Human Playtest Plan

**Preferred testers:** Quon and Jason separately, with minimal explanation beforehand. If only one tester is available, record that and lower confidence.

**Suggested sequence:**

1. Begin in a normal pickup area, collect some gold, and approach the thief's area without coaching. Observe the first encounter.
2. If gold spills, watch whether the player understands what happened and chooses to recover it.
3. Observe whether the player pursues or intercepts the thief, and whether the outcome is understood without reading logs.
4. Repeat one encounter with a different carried amount or outcome. Avoid extensive tuning mid-session.
5. Ask for ratings and qualitative feedback only after the uncoached attempt.

**Record at minimum:**

| Dimension | Evidence |
| --- | --- |
| Recognition | Did the player notice the thief and understand its interest in gold? |
| Readability | Did the player know gold had spilled and distinguish recoverable from stolen? |
| Agency | Did avoidance, recollection, or interception feel possible and understandable? |
| Tension | Rate how exciting it felt to protect/recover gold (1–5) |
| Fairness | Rate the encounter's fairness (1–5); explain any unavoidable-feeling loss |
| Gold desirability | Afterward, how strongly did the player want to collect more gold (1–5)? |
| Frustration | Rate annoyance/frustration caused by the loss (1–5) |
| Behavior | Did the player chase, recover, avoid, ignore, or regret collecting? |

**Proposed directional success criteria (not hard gates):**

- Both primary testers can explain the basic loss/recovery interaction without a long tutorial.
- No critical counting, inaccessible-drop, or unavoidable loss bug.
- The player has a genuine movement-based way to avoid, chase, or intercept the thief and recover loss; the outcome is not merely a scripted deduction.
- **Gold desirability remains high** after the event (aim for 4/5 or higher, recognizing small-sample uncertainty).
- Tension/recovery motivation is evident in player behavior, not only questionnaire ratings.
- Persistent irritation, loss of agency, or deliberate avoidance of additional gold counts as a strong warning even if the scripted encounter works perfectly.

A disappointing playtest may justify simplifying theft, changing recovery affordances, or revisiting the risk model; it does not overturn the broader Approved Direction by itself.

## 8. Risks and Design Questions to Examine

1. **Tedium:** Does chasing small losses become a chore? Avoid an endlessly repeatable thief.
2. **Unfairness:** Do fast surprises or inaccessible drops make gold loss feel arbitrary?
3. **Readability:** Can the player distinguish carried, spilled, thief-held, and lost amounts without a complex HUD?
4. **Incentives:** Does adding danger to possession discourage collecting? Watch actual behavior.
5. **Scope:** Is a thief pursuing dropped gold too costly for one experiment? Prefer a simple scripted encounter over generalized AI.
6. **Power fantasy:** P004 intentionally does not finalize how wealth raises the King's offensive power. The player should not need the superseded speed states or temporary P003 strike to experience P004.
7. **Threat scaling:** One thief does not prove that attracting more or stronger enemies with wealth is fun. Defer that distinct question.

## 9. Outcome and Documentation Gate

After automated checks and human playtesting, record in `docs/GOLDKING_PROTOTYPE_LOG.md`:

- Exact prototype configuration, trial setup, and Godot version.
- Observed behavior, ratings, narrative comments, and tester count.
- Any counting bugs, unfair losses, readability problems, and recovery behavior.
- Outcome (**Validated**, **Iterate**, or **Rejected** for the tested interaction) and confidence.
- Which implementation details are retained as a next-prototype baseline and which remain unapproved assumptions.
- Implications for P005 — Mini Expedition & Extraction (without implementing P005 here).

Do not mark automatic thief behavior, spill amounts, loss rates, or encounter frequency as permanent design merely because they are used in P004.

## 10. Approval and Workflow Gate

**Current status:** **P004 feature-specification scope approved by Quon on 2026-11-14. Planning-only Claude Code review is authorized. Gameplay implementation is not authorized.** The team must review Claude Code's proposed architecture and plan before any P004 feature branch or gameplay work begins.

**Approved scope decisions (Quon, 2026-11-14):**

1. **Single-thief encounter:** One readable, telegraphed thief; bounded contact spill; a chance for the King to retrieve and defend unsecured gold. **Approved for P004 prototype.**
2. **Recovery approach:** Movement-based chasing and proximity interception, without P003's temporary strike or a combat system. **Approved for P004 prototype only.**
3. **Initial loss caps:** Spill **up to 3** and steal **up to 1**, tunable during testing. **Approved as Prototype Assumptions, not final balance.**
4. **Technical baseline:** P001 movement and P002 collection, without P003's automatic movement-speed burden. P003 remains a historical experiment. **Approved for P004 prototype.**

**Still open for planning:** Exact state sequencing, telegraph timing, reachable escape route, interception radius, feedback, test controls, gold-accounting implementation, scene construction, and minimum regression coverage. Claude Code should recommend concrete starting values and justify them as **Prototype Assumptions**, not decisions requiring expanded gameplay systems. Escalating thief frequency or threat strength based on wealth is **out of scope**.

**Next gate — planning-only Claude Code inspection:**

1. Verify the repository's latest `main` and its synchronization with the remote before branching; confirm whether P003 is still the project main scene.
2. Inspect `AGENTS.md`, `CLAUDE.md`, `.claude/settings.json`, the latest canonical Gameplay Foundation and Decision Log, this spec, P001/P002 assets, and P003's test infrastructure.
3. Propose the **smallest implementation** consistent with the approved encounter, including scene/script reuse, a simple state progression, carried/spilled/thief-held/lost gold accounting, and automated validation.
4. Explicitly identify new files, any unavoidable modifications to existing files, prototype tuning parameters, risks, and the planned test command(s).
5. **Stop and return the plan for Quon/ChatGPT review.** Do not modify files, create the feature branch, commit, push, merge, or write gameplay code during planning-only review.

**Following explicit implementation approval:** Create `feat/p004-gold-spill-theft`; implement only the approved plan; run Godot validation and P001/P002/P003 regressions; collect human playtest findings; update the Prototype Log; then follow the normal reviewed commit/merge workflow.

**Source freshness note:** The archived copies of `GOLDKING_GAMEPLAY_FOUNDATION.md` and `GOLDKING_DECISION_LOG.md` available while drafting predate the 2026-11-14 P003 closeout. This specification applies the newer Approved Direction explicitly confirmed in the conversation. Claude Code must reconcile it with the latest tracked repository documents rather than overwrite those documents using archived copies.
