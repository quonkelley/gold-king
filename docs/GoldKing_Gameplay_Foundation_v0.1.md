# GoldKing — Gameplay Foundation v0.1

**Status:** Working design document  
**Purpose:** Capture approved gameplay/presentation direction while keeping unresolved systems clearly marked as open.  
**Note:** These decisions guide prototyping and may still change when playtesting reveals better answers.

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

### Current Failure Direction
- Gold carried during an expedition is unsecured.
- Ordinary treasure carried during an expedition is unsecured.
- Failing an expedition causes the player to lose the unsecured gold and ordinary treasure from that expedition.
- Previously secured settlement progression and wealth are not lost.

Important story items and unique relics may require separate rules and remain an open design question.

---

## 5. Approved Direction: Gold

Gold is intended to be one of the central gameplay systems rather than merely a currency.

Current working direction:
- The player actively seeks and collects large quantities of gold.
- Carrying more gold makes the Gold King more powerful.
- Carrying more gold also creates increasing physical burden and vulnerability.
- The King's current amount of carried wealth should be communicated visually through animation, posture, appearance, sound, and/or carried treasure.
- Gold may interact with the King's supernatural abilities, including a possible Midas-inspired Gilding power.
- Gold may spill when the King takes major hits.
- Certain enemies may steal or consume gold.

The exact combat formulas, load thresholds, powers, and balancing are not finalized.

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

---

## 7. Approved Direction: Expedition ↔ Settlement Loop

GoldKing currently has two complementary gameplay phases.

### Expedition Phase
`Explore → Fight → Discover → Accumulate Gold → Become Stronger/Heavier → Find Treasure/Relics/People → Decide Whether to Push Further → Return or Fail`

### Settlement Phase
`Return → Secure Haul → See What Changed → Interact With Characters → Invest/Unlock → Prepare → Choose Next Destination → Depart`

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

The first prototype should **not** attempt procedural generation.

Build one small handcrafted continuous zone that tests controlled top-down camera, 3D environment, 2D character presentation, movement, melee/action combat, gold collection, gold burden, open exterior space, a tighter interior, branching exploration, one secret, one treasure, and voluntary return/extraction.

The objective is to learn what a good GoldKing space feels like before attempting to generate variations of it.

---

# Current Design Principle

> **GoldKing should feel like an adventure through a real mythic world that happens to use roguelite systems—not like a randomized dungeon generator with a story wrapped around it.**
