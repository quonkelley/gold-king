# GoldKing — Gameplay Foundation

**Status:** Working design document  
**Version:** 0.1  
**Purpose:** Capture approved gameplay/presentation direction while keeping unresolved systems clearly marked as open.  
**Note:** These decisions guide prototyping and may still change when playtesting reveals better answers.

**Authority:**
- `GOLDKING_DECISION_LOG.md` is the authority for decision status (Approved Direction, Prototype Assumption, Open Question, Deferred, Rejected). If this document and the Decision Log disagree, the Decision Log wins.
- `GOLDKING_PROTOTYPE_LOG.md` is the authority for prototype sequencing and findings.
- `GOLDKING_CONTEXT.md` is the authority for narrative/world canon.

---

## 1. Approved Direction: Presentation

GoldKing will use a **2.5D top-down presentation built from 3D environments and 2D characters**.

### Technical / Visual Direction
- The world and level geometry are fully 3D.
- Primary characters and enemies are represented with stylized 2D artwork/animation inside the 3D world.
- The camera uses a controlled top-down/elevated perspective.
- Normal gameplay does not use free camera rotation.
- Camera movement may be used selectively for framing, conversations, bosses, landmarks, or dramatic moments.

### Why This Direction Fits GoldKing
This format preserves strong combat readability, expressive character art, environmental depth, visible elevation, physical treasure and gold, exploration, secrets, authored visual composition, and a more manageable production scope than full 3D character production.

The goal is not to imitate Enter the Gungeon, The Binding of Isaac, or Cult of the Lamb mechanically. Those games are useful references for camera readability and presentation, but GoldKing should develop its own combat, exploration, world, and progression identity.

---

## 2. Approved Direction: Level and World Feel

GoldKing should feel **more open and exploratory than a room-to-room dungeon crawler**.

### Exterior Spaces
Outdoor areas should communicate openness and physical geography. They may include branching paths, roads and trails, fields, forests, ruins, cliffs, caves, hidden locations, optional encounters, environmental storytelling, secrets and Easter eggs, and landmarks visible from a distance.

Outdoor exploration should not feel like a sequence of enclosed combat boxes.

### Interior Spaces
Interiors may become tighter and more structured when appropriate: temples, caves, castles, ruins, mines, houses, crypts, and other enclosed locations.

Interiors can use rooms, corridors, chambers, locked encounters, puzzles, or compact combat spaces without forcing the entire game into an Isaac-style room structure.

### Continuous Zones
Expeditions should generally feel like **continuous connected spaces** rather than isolated rooms linked by doors.

A zone may transition naturally through locations such as:

`road → forest → ruin exterior → temple interior → hidden chamber → boss/climax`

Combat can happen organically inside these spaces. Some encounters may temporarily lock or constrain the player, but this should be used intentionally rather than as the default structure of every encounter.

---

## 3. Approved Direction: World Structure

The current working structure is **hybrid** rather than open-world or board/tile-based.

The game should have a persistent larger world containing the Gold King's former kingdom, the settlement that grows after his exile, surrounding lands, distinct regions, mythological locations, settlements, roads, ruins, and eventually potentially other kingdoms or territories.

The player travels to destinations and undertakes expeditions within this larger world.

GoldKing will **not** use a For the King-style tile map as its primary world-navigation system.

---

## 4. Approved Direction: Expedition Identity

An expedition is a journey away from the player's persistent settlement in pursuit of goals such as gold, treasure, story objectives, characters, relics, powers, abilities, discoveries, or access to new locations.

The player accumulates unsecured wealth while away from home.

### Prototype Assumption: Losing Unsecured Gold and Treasure
*Status: Prototype Assumption (see Decision Log). Not finalized design.*

The current failure rule being tested:
- Gold carried during an expedition is unsecured.
- Ordinary treasure carried during an expedition is unsecured.
- Failing an expedition causes the player to lose the unsecured gold and ordinary treasure from that expedition.
- Previously secured settlement progression and wealth are not lost.

Prototype question: does losing the entire current haul create meaningful greed and extraction tension, or does it make failure feel excessively punishing?

**Open Questions:** unique relic and story-item behavior, recovery systems, voluntary retreat rules, mid-expedition banking, and whether upgrades can protect part of the haul.

---

## 5. Gold

### Approved Direction: Gold Is Central

Gold is intended to be one of the central gameplay systems rather than merely a currency.

- Gold is more than simple currency. It is a major source of desire, power, risk, and temptation, and connects to the game's themes of greed and "enough."
- The player actively seeks and collects large quantities of gold.
- The King's current amount of carried wealth should be communicated visually through animation, posture, appearance, sound, and/or carried treasure.

### Approved Direction: Gold Power With Wealth-Driven External Danger
*Status: Approved Direction (Decision Log, 2026-11-14), informed by P003.*

- Accumulating ordinary gold should remain highly desirable and contribute to the Gold King's increasing power.
- Greater accumulated wealth should also create the potential for greater **external** danger, attention, and vulnerability. This increasing exposure is the intended core downside of carrying more gold.
- Collecting ordinary gold should **not** automatically impair traversal. Automatic movement-speed penalties from ordinary gold are no longer the intended core downside.

How external danger works is unresolved: which enemies or entities respond to wealth, how threats escalate, how escalation is communicated, and how players respond. This direction does not define a dynamic-difficulty director, enemy-spawning formula, or threat meter.

**Superseded (2026-11-14):** the earlier *Gold Power vs. Burden* Prototype Assumption, under which more carried gold also created increasing physical burden. P003 tested it with automatic top-speed penalties. The results are recorded in the Prototype Log and the original assumption remains in the Decision Log as history.

### Prototype Assumption: Gold Spill & Theft
*Status: Prototype Assumption (see Decision Log). Tested in P004 as a single thief encounter (concluded 2026-11-14, outcome Iterate; see Prototype Log). Not finalized design.*

- Gold may spill when the King takes major hits.
- Certain enemies may steal or consume gold.

### Experimental Ideas (not approved)
- An optional gold-powered heavy form.
- Separate encumbrance from large treasures or equipment.
- Wealth states as playstyles (for example a tank-like heavy style and a faster high-damage light style).

### Open Question: Supernatural Gold Powers / Midas-Inspired Gilding
*Status: Open Question / Future Prototype (see Decision Log).*

Midas-inspired powers, such as gilding enemies, objects, or parts of the environment, are under consideration and may be prototyped later. Whether gold provides supernatural abilities at all is an open narrative question in `GOLDKING_CONTEXT.md`. Supernatural gold mechanics are unresolved and should not be treated as canon or approved design.

The exact combat formulas, gold power scaling, threat mechanics, powers, and balancing are not finalized.

---

## 6. Approved Direction: Persistent Settlement

After exile, the Gold King begins from a small camp near the kingdom he once ruled.

The settlement is a **persistent progression and story hub**, not a city-builder or maintenance simulation.

Its primary functions are:
1. Permanent progression.
2. Story and character development.
3. Visible evidence of the player's accomplishments.

The player should not be required to perform routine settlement chores, manually manage workers, maintain hunger systems, assign production jobs, or constantly defend the base from random resource-loss events.

The settlement should grow primarily through major accomplishments, characters encountered during expeditions, meaningful investments, story progress, reputation/influence, and important development milestones.

Much of the ordinary growth of the settlement can happen automatically as people choose to live there.

### Clarification (2026-11-15): Light, Primarily Automated Settlement
*Status: Approved Direction (reaffirmed by Quon; see Decision Log, 2026-11-15). Clarifies the direction above; does not approve a city-builder.*

- The settlement begins as a modest camp and can gradually become more populated, impressive, comfortable, and functional.
- Growth is driven primarily by expedition accomplishments, discoveries, story progression, significant investments, and characters encountered.
- The player should experience the satisfaction of watching their home develop.
- Ordinary construction and population growth can happen automatically.
- The player should not routinely manage building placement, hunger, worker schedules, resource-production chains, or repetitive settlement chores.
- The settlement supports the expedition adventure rather than replacing it with a management simulator.
- Greater management depth may be reconsidered later only if there is a compelling gameplay reason.

### Experimental Ideas: Settlement Characters and Followers (not approved)
- Important characters discovered during expeditions could later join or contribute to the settlement.
- Specialists could unlock new services or gameplay opportunities.
- Followers could gradually arrive as the King's influence and accomplishments grow.
- A growing population could visibly communicate rising status and influence.
- Buildings and inhabitants could help the settlement feel alive and functional.

*Illustrative example only:* the player discovers a blacksmith during an expedition; after a relevant objective is completed, the blacksmith joins the settlement, a workshop becomes available automatically, and an equipment-related service opens without manual construction or management. **This is not an approved character, quest, building, or mechanic.**

Follower recruitment rules, NPC jobs, automated production, settlement layouts, building upgrades, and any castle progression sequence are not defined.

### Open Questions: Reputation, Influence, and Legendary Status
Whether the King's growing status could be communicated through more followers, increased recognition, new opportunities, visible settlement development, influence or reputation, or heroism, renown, or legendary status.

"Reputation/influence" above names a possible growth driver only. No progression currency, reputation meter, faction system, or status formula is defined or approved.

Growing wealth, gaining power, attracting followers, earning loyalty, and becoming worthy of ruling remain distinct (see `GOLDKING_CONTEXT.md`). Settlement growth or a larger following should not be treated as proof of loyalty or redemption.

---

## 7. Approved Direction: Expedition ↔ Settlement Loop

GoldKing currently has two complementary gameplay phases.

### Expedition Phase
`Explore → Fight → Discover → Accumulate Gold → Become Stronger and More Exposed to Danger → Find Treasure/Relics/People → Decide Whether to Push Further → Return or Fail`

### Settlement Phase
`Return → Secure Haul → See What Changed → Interact With Characters → Invest/Unlock → Prepare → Choose Next Destination → Depart`

"Become Stronger and More Exposed to Danger" follows the 2026-11-14 Approved Direction in §5 (it previously read "Become Stronger/Heavier"); its exact mechanics are unresolved. "Return or Fail" depends on the Prototype Assumption in §4 and may change with prototype evidence. The two-phase structure itself is the approved direction.

The two phases should feed each other.

Expeditions should create reasons to care about returning home.

Settlement progression should create reasons to immediately want another expedition.

---

## 8. Approved Direction: Loot Philosophy

GoldKing should avoid a cluttered generic crafting-resource economy.

Primary expedition rewards currently fall into three broad categories:

### Gold
The common central resource and source of expedition power/risk.

### Treasure
Valuable objects that can be brought home, collected, displayed, sold, given away, or occasionally used in special ways.

### Relics / Special Items
Rare discoveries that matter because of their unique function rather than simply their sale price. They may affect story, mythology, powers, abilities, characters, world access, exploration, or permanent gameplay options.

Generic material inventories such as large quantities of wood, stone, leather, iron, etc. are currently discouraged unless a later mechanic creates a strong specific reason for them.

---

## 9. Combat Identity — Current Design Preferences
*Status: Experimental Ideas / Quon's current design preferences (2026-11-15). Not Approved Direction for any combat system.*

Current preference:

> **Consistent, responsive movement and defensive fundamentals, with offensive combat styles that can change substantially depending on weapons, enemies, and environments.**

- Combat should balance fast, aggressive action with deliberate positioning and timing.
- Combat rhythm may vary with the equipped weapon and the area or encounter.
- GoldKing should remain a substantial action game: fighting, survival, dangerous encounters, obstacles, and dungeons.
- Strong interest in a hybrid of diverse weapons and relic combinations.
- Weapons may significantly change attack patterns and fighting styles.
- Relics and special discoveries may modify weapons and produce interesting combinations.
- The Gold King's personality should stay recognizable across builds; his greed, charisma, pride, and relationship with gold may inspire distinctive gameplay possibilities.

**Open Questions:** combat controls and aiming; dodge/defensive mechanics; weapon types and equipment slots; relic behavior and synergy rules; temporary vs. permanent combat abilities; weapon discovery and unlock rules; combat progression; enemy designs and balancing; supernatural gold powers and Midas-inspired abilities (see §5; not canon).

No weapon roster, synergy framework, combat architecture, or implementation sequence is approved.

---

## 10. Expedition Milestones and Exploration
*Status: Experimental Ideas (2026-11-15). Supports the approved hybrid-world (§3) and continuous-zone (§2) directions; not approved mechanics.*

Possible layers of progression:
- Short-term milestones achievable within a single expedition.
- Medium-term milestones spanning multiple expeditions.
- Larger objectives involving several connected quests or expedition stages.
- Intermediate accomplishments contributing to larger rewards.

Possible reasons to explore:
- Distinct regions with different atmospheres, environments, enemies, discoveries, and gameplay challenges.
- Treasure, relics, unusual weapons, important characters, mythology, and folklore.

No biome list, region names, quest system, environmental mechanics, reward requirements, or milestone formulas are approved. Example region types raised in discussion are not world canon.

---

# Open Design Question: Procedural Generation

**No decision has been made yet about procedural level generation.**

Procedural generation is not required for GoldKing to function as a roguelite.

The primary concern is preserving memorable geography, authored exploration, environmental storytelling, hidden secrets, mythology, Easter eggs, and the sense that locations are real places in a coherent world.

### Current Strong Recommendation

Prototype **hand-authored zones first**.

If replayability later needs additional variation, consider procedural or systemic variation at a smaller scale rather than generating entire regions.

Potential variable elements could include enemy composition, treasure placement, optional encounters, events, elite enemies, weather or environmental conditions, minor route blockers/openings, reward opportunities, or selected modular side areas.

This approach can be summarized as:

> **Authored macro-world, variable micro-content.**

Whether GoldKing ultimately uses this hybrid approach, fully authored expeditions, or more extensive procedural generation should be decided after the core exploration/combat prototype is playable.

---

# Prototype Implication

`GOLDKING_PROTOTYPE_LOG.md` is the authority for prototype sequencing. The summary below reflects it and should not be treated as a separate plan.

Early prototypes are **incremental**. Each answers one primary design question and introduces systems separately:

1. **P001 — Player Movement & Controlled Camera**
2. **P002 — Gold Collection**
3. **P003 — Gold Power vs. Burden** (concluded 2026-11-14; led to the revised direction in §5)
4. **P004 — Gold Spill & Theft** (concluded 2026-11-14, Iterate)
5. **P005 — Mini Expedition / Extraction** (concluded 2026-11-15, Iterate)

Next intended investigation: **P006**, meaningful rewards for successfully extracted gold (production priority; specification not yet approved). See the Prototype Log planning note and the Decision Log (2026-11-15).

### P001 Scope

P001 tests only:
- Player movement
- The controlled top-down/elevated camera
- A 2D character inside a 3D environment
- Basic readability and spatial feel

P001 does **not** include combat, dodge, gold collection, treasure, enemies, Gilding, extraction, settlement systems, or procedural generation. Later prototype stages introduce those systems separately.

### Earlier Framing

An earlier version of this document proposed one combined first prototype: a small handcrafted continuous zone testing camera, presentation, movement, combat, gold collection, gold burden, exterior/interior space, branching exploration, a secret, a treasure, and voluntary extraction. That combined scope was replaced by the incremental sequence above. Much of it now corresponds to P005 and later work.

Early prototypes should **not** attempt procedural generation. The objective is to learn what a good GoldKing space feels like before attempting to generate variations of it.

---

# Current Design Principle

> **GoldKing should feel like an adventure through a real mythic world that happens to use roguelite systems—not like a randomized dungeon generator with a story wrapped around it.**
