# P006 — Meaningful Extraction Rewards

**Document:** `docs/features/p006_meaningful_extraction_rewards.md`  
**Status:** Approved feature specification for P006 planning (Quon, 2026-11-15) — **implementation not authorized**  
**Status note (2026-11-16):** P006 was subsequently implemented on `feat/p006-meaningful-extraction-rewards` (final build `fcd69da`; the implementation authorization is not recorded in this file) and playtested by three people. The current prototype cycle is concluded (outcome: Iterate). This specification is otherwise unchanged and is kept as the historical record of the approved scope; see the P006 entry in `docs/GOLDKING_PROTOTYPE_LOG.md` for results.  
**Prototype:** P006  
**Prepared:** 2026-11-15  
**Engine context:** Godot 4.7.2, typed GDScript; controlled 2.5D presentation  
**Naming convention:** `docs/features/p###_<short_descriptive_name>.md`  
**Dependencies:** P001 movement/camera; P002 working gold collection; P004 thief/ledger; P005 two-branch expedition and extraction. P003's automatic gold-related speed burden and temporary strike are **not** gameplay baselines.

> **Approval boundary:** Quon approved this P006 feature specification, including its proposed minimal test configuration, for implementation planning. Specific mechanics and tuning remain **Prototype Assumptions for testing**, not permanent production decisions. This is not implementation approval, a production economy design, a finalized combat specification, or a change to narrative canon. Claude Code should inspect the **current tracked repository** before proposing an implementation plan; supplied source documents may not reflect later changes.

## 1. Primary Design Question

> **Does giving gold brought home from an expedition a persistent, meaningful use make extraction more satisfying and make the player want to embark on another expedition?**

Evaluate **three distinct outcomes** rather than combining them into a single success claim:

1. **Extraction satisfaction:** Does securing a haul now feel like a meaningful accomplishment?
2. **Replay motivation:** Does seeing the growing treasury, meeting the merchant, and working toward/using the sword create a desire to depart again?
3. **Return-or-continue decisions:** Does the 20-gold purchase goal meaningfully affect when the player chooses to return, rather than simply clearing the entire level?

P006 may improve the first two without improving the third. That is a **mixed but useful** result, not a failure of the whole loop. The existing thief is intentionally a relatively low-stakes threat.

## 2. Evidence and Decision Status

### Established Canon — unchanged

The Gold King is good-hearted, charismatic, proud, flawed, and genuinely obsessed with gold. His wealth is desirable and fun, but gaining money or followers is not equivalent to earning trust or redemption. No merchant identity, dialogue, supernatural weapon property, new kingdom, or narrative event is established as canon by this prototype.

### Existing Approved Direction

- Gold is central and desirable; ordinary gold should not automatically slow traversal. Greater wealth may draw external danger; exact threat scaling remains open.
- GoldKing uses a controlled elevated 2.5D view, authored connected exploratory spaces, and expedition ↔ persistent settlement phases.
- Settlement growth is **light and primarily automated**, not town management.
- The first prototype priority after P005 is to investigate meaningful extraction rewards (Decision Log, 2026-11-15).
- The *loss of an entire unsecured haul on expedition failure* remains a **Prototype Assumption**, **not** a feature of P006.

### P005 Evidence — retained, not rewritten

P005 outcome: **Iterate** after one recorded human tester. Expedition enjoyment was **4/5**; satisfaction with securing the haul **3/5**; desire for another expedition **3/5**. The 3/5 extraction-clarity report predominantly described *weak reward*, **not** inability to understand the prompt. The player explored both branches, did not return early, and said the thief affected the return decision. P005 includes 25 standard gold pieces, with 15 outside the thief's chamber and 10 within it; the thief can take at most one. None of these findings validates persistent progression, a merchant shop, or sword combat.

### P006 Choices Approved by Quon in Design Conversation — *prototype-specific*

- The reward loop involves discovering a merchant, automatically gaining a merchant stall at the settlement on successful return, securing gold into a persistent treasury, and buying a **first sword for 20 secured gold**.
- The merchant can be discovered in the **safer Branch A**, without requiring the thief encounter. Recruitment is through discovery/interaction, not gold payment.
- Use a **small playable settlement hub**, separate from the existing P005-style expedition scene, with a **simple departure/extraction transition**. This is not permanent world/scene architecture.
- Preserve a compact **results → treasury deposit → playable hub** return flow. Let the player voluntarily start another expedition.
- The sword has **minimal interaction** with breakable treasure objects; full combat, enemies, and weapon systems are intentionally postponed.
- Longer-term merchants may offer a *mix* of weapons, relics, treasures, tools, and equipment. **P006 implements only one merchant and one sword**, not those future categories.

### Prototype Assumptions — **approved for P006 testing only; not production decisions**

- Merchant representation, exact position within Branch A, text, visibility cue, and one-button interaction details.
- A tiny treasury prop with visible fill stages, a minimal merchant UI, and a departure marker.
- The specific scene lifecycle and in-session state holder.
- One attack input, one simple sword swing, and **two optional breakable containers** that release a small amount of *bonus* gold after purchase.
- Exact hit shapes, bonus gold quantity, feedback timings, debug instrumentation, and rating targets.

## 3. Desired Player Experience

1. **At the beginning:** The King stands in a humble, walkable camp with an empty treasury, no merchant, and an obvious way to depart.
2. **Expedition:** He collects attractive gold, explores the existing two branches, can avoid or chase the thief, and discovers an approachable traveling merchant on the safer branch.
3. **Discovery:** One simple interaction marks the merchant as willing to join the settlement. The King is not forced to recruit them and does not buy their services with unsecured gold.
4. **Return:** The King deliberately extracts at the existing field-camp point, sees what he secured, and sees the treasury total increase.
5. **Homecoming:** Back in the playable settlement, the merchant's modest stall now exists, the treasury visually reflects accumulated gold, and the sword is offered for **20 secured gold**.
6. **Decision:** If he has 20 or more, he can buy the sword. If he has less, he keeps the balance and can return for more gold; the seller and progress remain available.
7. **Use:** On a later expedition, a readable swing opens optional treasure containers for bonus coins. The King owns the sword for the rest of the session.
8. **Return again:** He banks the new haul and can see the effect of his investment, then choose another expedition.

**Emotional target:** “That's *my* fortune. Now I can finally buy something worthwhile—and I want to go see what it lets me do.”

A player who continues to collect everything before extracting is not playing incorrectly. Record whether the sword goal *influenced* the choice, not just whether they extracted early.

## 4. Smallest Useful Prototype

### 4.1 Scene boundary and reuse

**Approved P006 structure:** One small, separate **playable hub** and one P005-like **expedition**, with simple transitions. The field camp in the expedition is a staging/extraction location, **not** a second developed town. This is a prototype scene split, not a permanent world-travel or zone-loading rule.

**Implementation-planning recommendation (not architecture authorization):** Preserve the original P005 scene and its historical test behavior. Reuse selectively or build a P006-specific derivative/wrapper so that hub persistence and bonus sword loot do not silently alter P005's fixed-25-coin invariant. Prefer the simplest modular state handoff compatible with the actual repo after inspection; do not build a generalized world manager, save system, economy framework, or inventory service.

- Initial test boot enters the **playable hub** with treasury 0, merchant absent, sword unowned.
- A visible departure interaction starts a fresh expedition with **0 carried gold**.
- At the expedition staging camp, **E / existing `interact` action** explicitly extracts as in P005; walking into the extraction zone must not auto-extract.
- Results are acknowledged, then the game transitions to the playable hub. Do **not** automatically launch the next run.
- Returning to the hub should be distinguishable from starting a new expedition; retain the P005 flow only in the P005 historical scene.

### 4.2 Playable hub — four simple elements

1. **King's humble camp/tent:** existing-style placeholder visual anchor. No rest or upkeep mechanic.
2. **Treasury:** one visible chest/hoard plus **exact secured-gold balance** in a readable place; optional coarse fill stages that reflect remaining spendable gold. No new resource type or upgrade tree.
3. **Merchant stall:** absent until the merchant is discovered and the player successfully extracts. One readable merchant stand-in, one proximity/interact prompt, one-item purchase panel.
4. **Departure point:** clearly differentiated from the merchant and treasury. Manual departure, no destination selector or map.

No building placement, worker assignments, construction menu, settlement economy, reputation meter, population simulation, or multiple shops. Small placeholder geometry is enough.

### 4.3 Merchant encounter and arrival

- Place an easy-to-notice but optional merchant stand-in in **Branch A's northwestern chamber**, near an existing landmark, without blocking passage or relocating the 25 standard gold pickups unnecessarily.
- The player can approach and use the existing interaction input. Show minimal feedback that the merchant was met and is willing to join the camp; dialogue is **temporary placeholder**, not canon.
- Merchant recruitment costs **zero gold**, and carried gold must not affect recruitment.
- If discovered, the merchant arrives automatically **after a completed extraction** (even one with zero secured gold). Merely meeting the merchant mid-expedition does not spawn the stall in the field.
- If not discovered, the hub stays without a merchant; the player can leave and find them on a later expedition.
- Once recruited, the merchant persists across subsequent runs in the current session. Repeated interaction or rediscovery must not create duplicate stalls.

**Measurement caveat:** The merchant's appearance itself may motivate replay independently of securing gold. Record *discovery satisfaction* separately from *deposit satisfaction* rather than attributing all improvement to the treasury.

### 4.4 Treasury, deposit, purchase

- **Expedition gold is unsecured** while carried; **hub treasury gold is secured** and spendable. No spending of carried gold on the road.
- On successful extraction, freeze/resolution-guard expedition gold transfers and take **one** definitive snapshot. The deposited amount equals the final carried gold (ordinary plus any properly collected bonus gold). Previously secured wealth is not exposed to the P004 thief.
- Results should show at least **this haul secured**, **treasury before + deposited = treasury after**, and useful P005 loss/time information. Merchant discovery may be shown as a separate discovery outcome.
- Credit the treasury **once only** per extraction. Closing/reopening the results UI or repeated interact presses must never duplicate gold.
- At the hub, the merchant displays a sword costing **20 secured gold**. The UI clearly shows affordability and current balance.
- A confirmed purchase subtracts **exactly 20**, marks the sword owned, and keeps ownership for the session. There is no negative balance, duplicate purchase, resale, or second item.
- Once owned, the shop can show **Owned** instead of a Buy action. No inventory menu, equipment slot system, or weapon switching is needed.
- A purchase is a **permanent-in-session advancement**, but the **treasury spendable balance decreases**. Don't suggest the deposited coins remain in the chest if they were spent; the new sword/merchant stall also visibly communicates lasting progress.

**Illustrative accounting:** Secure 23 gold → treasury 23. Buy sword for 20 → treasury 3, sword owned. Extract 8 next time → treasury 11, sword still owned.

### 4.5 First sword — deliberately minimal use

- The purchased sword is available for subsequent expeditions; no combat enemies or damage framework is required.
- Add **one responsive swing** with temporary animation, a readable short hit area, and placeholder impact feedback. Directional details and attack timings are **Prototype Assumptions** to be proposed after inspecting the existing controller and camera.
- Add **two optional breakable treasure containers**, distinguishable from normal scenery and accessible on the existing map. At least one should be visible before ownership so the purchase has a recognizable payoff on revisit.
- The containers are *not mandatory gates* to complete or extract. Without a sword they remain intact; with a sword a correct swing breaks each once and releases a **small tunable bonus gold amount** (suggested starting value: **3 gold per container**, 6 extra per sword-owned run).
- Reuse P002's gold-collection feel/ownership path where practical. Bonus coins are collectible and bankable, not direct treasury deposits.
- Clearly identify this as a **functional economic reward demonstration**, **not combat validation**. A sword that only opens boxes may feel like a key; note that as a limitation, not a final weapon design.

**Critical P005 accounting boundary:** Keep the existing **25 standard pickup** layout unchanged as the comparison baseline. If sword containers generate bonus coins, P006 must explicitly track the **bonus generated, uncollected, carried, dropped, stolen, lost, and secured** amounts as appropriate; update *P006-specific* conservation and results logic without editing historical P005 expected totals. For example, once bonus coins are generated, an invariant can include `25 standard coins + bonus generated` across all standard/bonus uncollected, carried, spilled, thief-held, and lost states. The exact invariant must match the implemented lifecycle and not count a coin twice. Validate totals with and without the sword.

### 4.6 Transition and reset rules

| Event | Persistent-in-session effect | Expedition-local effect |
| --- | --- | --- |
| Depart from hub | Treasury, merchant, sword unchanged | New run: 0 carried, standard pickups reset, thief reset, sword bonus containers reset |
| Meet merchant | Record *pending discovery for this run* | No stall while in field |
| Extract successfully | Add captured carried gold **once**; make discovered merchant available in hub | Close run; no subsequent transfers; show results before hub return |
| Buy sword | Spend 20 treasury gold **once**; sword owned | No effect on a completed run |
| Leave expedition via test reset/abandon (if provided) | **No deposit**; preserve previously secured session state | Discard unbanked haul and pending discovery; restart run or return to hub as explicitly labeled |
| Quit/relaunch game | **No promised persistence** | Everything may restart from initial test state |

**Prototype assumption:** Merchant discovery is confirmed by successful extraction, not merely by pressing E in the field. This keeps the flow coherent, but **does not** approve permanent companion-loss rules or expedition-failure behavior.

Do not implement story consequences or death/failure conditions to enforce these rules.

### 4.7 Input, UI, feedback, and debug information

- Reuse existing movement and `interact` bindings. Prevent an interact press from being consumed by multiple nearby activities; establish clear focus/range and prompts in the hub and expedition.
- Use a distinct provisional `attack` action for the sword, compatible with keyboard and gamepad. Binding to **J/Space and gamepad west face button** is a *candidate* inspired by P003's temporary strike, **not** a combat-control decision; review collisions first.
- Small shop UI: item name, **20 gold** price, balance, Buy/Owned/Insufficient Funds, close/return. No scrolling catalog or separate inventory screen.
- Results UI: prior/deposited/after treasury totals, run secured amount, and a clear **Continue to Camp** action.
- Visible placeholder feedback for deposit, merchant arrival, successful purchase, sword hit/break, and spilled bonus coins. Keep readability ahead of visual polish.
- Print one concise **P006 expedition** result per extraction with total secured, standard vs. bonus collected/secured if useful, lost/spilled/uncollected, merchant discovered, thief outcome, elapsed time, treasury before/after, sword ownership, and whether the player extracted with at least 20 available toward the purchase. Log one purchase event (price, before/after, owned); avoid excessive telemetry.

## 5. Explicit Non-Goals

P006 **must not** introduce:

- A general combat system; fightable enemies, enemy health, damage to the King, dodge or defense, combos, weapon families, hit-stun systems, combat balancing, or relic synergies.
- Full equipment/inventory frameworks; multiple weapons or sale items; merchant stock rotation, buying/selling treasure, trading, restocking, discounts, or crafting materials.
- A city-builder; free placement, NPC schedules, follower AI, worker assignments, maintenance, construction resources, or population/reputation currencies.
- Full save/load or cross-launch persistence; robust game state architecture beyond what the test needs.
- New regions, new hostile enemy types, world maps, procedural generation, dynamic difficulty, new thief scaling, or changes to P003 ordinary-gold slowdown.
- Expedition failure/death rules or the loss of the player's previously secured treasury.
- Production art, final merchant identity/dialogue, mythical sword powers, or established new story canon.

**Stop rule:** If sword use requires building a large combat architecture or the camp requires city-management code, reduce the feature to the smallest readable interaction and bring the scope issue back for review.

## 6. Mechanical Acceptance Criteria — after implementation approval

- [ ] P001 movement/camera and normal gold pickup behavior remain usable; carried ordinary gold does **not** reduce movement speed.
- [ ] P005 historical scene remains playable and its existing **25-coin** and extraction results remain unchanged.
- [ ] A fresh P006 session begins in a walkable hub, treasury at 0, merchant/stall absent, sword unowned.
- [ ] Manual hub departure enters a fresh expedition; field extraction is manual and works with **0, partial, or full** carried gold.
- [ ] Merchant is discoverable and interactable in safer Branch A without confronting the thief; missing the merchant does not block extraction or replay.
- [ ] Merchant appears in hub only following discovery **and a successful extraction**, including if the player banked 0. Merchant remains afterward; there are no duplicates.
- [ ] Extraction result matches the final carried balance; `treasury_after = treasury_before + secured` exactly once, including repeated input or results-panel presses.
- [ ] A purchase with **19 gold** (or less) is refused without modifying ownership/balance; with **20 gold** it succeeds once; with **21+** it subtracts exactly 20; a repeat purchase is refused or marked Owned.
- [ ] Player can accumulate smaller extractions (e.g. 11 + 9 = 20) and purchase the sword on a later hub visit.
- [ ] Sword ownership persists across repeated expeditions in the **same session**; no sword use before ownership.
- [ ] Sword interacts with optional containers once each. Container bonuses cannot be double-spawned, picked up twice, or deposited without collection; base 25 coins remain separate.
- [ ] P004 thief spill/theft/recovery accounting remains correct if bonus coins enter carried gold; **all P006 gold is conserved**, with no negative balances or duplicate deposits.
- [ ] Manual new expedition resets only expedition-local pickups, thief, sword containers, and carried gold; retains treasury, recruited merchant, and owned sword.
- [ ] Quitting/relaunching is **not** expected to preserve treasury/merchant/sword for this prototype.
- [ ] Existing `tests/p005_regression.gd`, `tests/p004_regression.gd`, and `tests/p003_regression.gd` pass, except for explicitly explained default-main-scene assumptions that must be adjusted narrowly rather than hiding failures; P001–P005 scenes still load.
- [ ] New repeatable P006 tests return nonzero on failure and cover scene transitions, treasury transfer idempotency, shop affordability, and sword bonus conservation. No machine-specific absolute paths.

Mechanical acceptance is **not evidence** that the reward is emotionally satisfying.

## 7. Human Playtest Plan

**Preferred testers:** Quon and Jason separately if available. State the actual count and that baseline P005 ratings came from just Quon. Do not claim controlled statistical improvement.

### First pass — natural full loop

1. Start at the new hub with no instructions beyond a minimal departure cue. Observe whether the camp layout and departure interaction are understood.
2. Depart; allow natural route choice. Note whether the player finds the merchant, whether they enter the thief's chamber, and whether the 20-gold sword target affects collecting and returning.
3. Let the player extract **whenever they choose**. Record carried gold, branches visited, thief outcome, gold still out in the map, and the *player's stated reason* for returning.
4. On results, ask separately how rewarding the **deposit** felt and whether seeing the *new treasury total* mattered.
5. In the hub, observe whether the player notices the merchant and treasury, understands the purchase, buys the sword if affordable, and wants to depart again.
6. Allow a next expedition with the sword. Record whether the player notices, chooses to attack, breaks containers, collects bonus coins, and reports that the item felt worth buying.
7. If the player returns with less than 20 gold, do not grant free currency to make the demo look successful; observe whether they choose another expedition to earn the remainder. For an optional controlled QA trial, set a test preset explicitly labeled as such.

### Measures — distinct hypotheses

| Dimension | P005 baseline | P006 evidence/target |
| --- | --- | --- |
| Satisfaction of securing haul | **3/5** | Directional target **≥4/5**, plus observed response to deposit |
| Desire to begin another expedition | **3/5** | Directional target **≥4/5**, plus actual voluntary redeparture |
| Return-or-continue decision | No early extraction observed; thief influenced reported choice | Gold at extraction, gold left, stated reason, perceived sword goal; **no required early return** |
| Exploration / gold desirability | **4/5** each | Check not degraded by shop or repetition |
| Merchant discovery | Not present | Found without coaching? Did discovery itself feel rewarding? |
| Shop readability | Not present | Can understand 20-gold price and purchase without help? |
| Sword reward | Not present | Voluntarily used; perceived usefulness/excitement; worthwhile purchase? |
| Camp/homecoming | Not present | Does visibly changed camp feel more like a place worth returning to? |

**Optional stronger comparison:** If a second tester or later session is available, compare a similar route with the purchase goal visible vs. after acquisition. Do not change thief tuning and branch layout at the same time. A single developer's ratings cannot establish causality, and repeating the same map introduces familiarity effects.

### Suggested success/failure signals

**Supportive:** Player understands that returned gold is permanently available within the session; can identify a desirable purchase target; chooses to return and purchase; expresses satisfaction with ownership; willingly uses the sword and departs again; deposit/replay ratings show an improvement over their own P005 report.

**Warning/iterate:** Merchant discovery eclipses extraction (a zero-gold return feels just as rewarding); repeated map runs feel like grind; treasury increase is unclear or less rewarding than the purchase itself; sword interaction feels like an arbitrary key; the player cannot understand where to go or why they should buy the sword.

**Inconclusive:** Interface or bugs prevent a fair purchase/use experience; tester never sees the merchant and no follow-up condition is tested; too many things change to explain what improved.

## 8. Risks, Guardrails, and Open Questions

1. **Multiple new variables:** Merchant, hub, banking, and sword all arrive together. This tests the **integrated reward loop**, not the independent causal value of each feature. Ask for moment-by-moment feedback.
2. **Short, known map:** Repeating P005 may be uninteresting even with a target. Don't respond by building regions or procedural generation during P006.
3. **Weak external stakes:** One thief can steal at most one gold and disappears after its encounter. A 20-gold goal may change route choices but not lead to early extraction. Do not add stronger threats until measured.
4. **Merchant not found:** Optional exploration risks missing the primary shop. Use a strong visual cue on Branch A; maintain a repeatable test route without scripting automatic discovery.
5. **Sword is not combat:** Opening boxes proves functional value only. Don't label P006 a combat validation or equate a satisfying box-break with satisfying enemy encounters.
6. **Treasury vs. lifetime wealth:** The displayed *spendable* balance drops on purchase. An optional lifetime-earned counter is **not** needed for the experiment; don't introduce extra progression currencies. The sword and merchant visually represent lasting investment.
7. **Accounting regressions:** P005 assumes fixed 25 world coins. P006 bonus drops and scene reloads must not duplicate loot, break gold conservation, or change P005 history.
8. **Mode separation:** Scene transition is a P006 convenience; the game's final travel/loading model remains open.
9. **Persistence level:** In-session carryover only; no disk saving and no final progression economy decision.
10. **Narrative identity:** A merchant helping the King does not prove earned loyalty or moral redemption. The NPC's identity and exact dialogue are not canon.

## 9. Documentation and Approval Gate

**Before coding:** Quon approved this feature specification on 2026-11-15. Claude Code may subsequently be asked for a **planning-only** repository inspection and implementation proposal; code changes still require **separate explicit authorization**. Preserve original prototype scenes and tests.

**After testing:** Create the P006 entry in `GOLDKING_PROTOTYPE_LOG.md` with build, scope, exact test configuration, measures, observations, player reports, interpretation, outcome (Validated/Iterate/Rejected/Inconclusive/Deferred), confidence, and what should be tested next. Keep P005 as Iterate. Update `GOLDKING_DECISION_LOG.md` and the Gameplay Foundation **only** for explicitly approved new directions or evidence-backed changes; do not silently make the merchant, price, sword, or scene layout permanent production canon.

**Next investigation (recommendation only):** A focused combat foundation experiment with one actual fightable opponent and meaningful sword attacks, separately scoped and approved. No prototype number is assigned here.

---

## Human Approval Record

**Approved by:** Quon, 2026-11-15. **Authorization:** Feature specification accepted for planning; **no implementation authorized**.

The prototype-specific proposals in this document are accepted as **P006 test assumptions**, including two optional breakables at a suggested starting value of 3 bonus gold each, merchant arrival on successful extraction, simple treasury/shop feedback, and the proposed playtest measures. Values may be tuned through the approved prototype workflow; they are **not** permanent economy, combat, narrative, or settlement decisions.

The next gate is a planning-only repository review and implementation proposal, followed by separate human authorization before code changes.
