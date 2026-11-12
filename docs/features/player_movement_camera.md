# P001 — Player Movement & Controlled Camera

**Status:** Ready for Implementation Planning  
**Prototype:** P001  
**Related Prototype Log:** `docs/GOLDKING_PROTOTYPE_LOG.md`  
**Related Gameplay Foundation:** `docs/GOLDKING_GAMEPLAY_FOUNDATION.md`  
**Related Decision Log:** `docs/GOLDKING_DECISION_LOG.md`

---

## Objective

Create the first playable GoldKing prototype that tests whether the approved 2.5D presentation works in practice:

- 3D environment
- 2D player character representation
- Controlled top-down/elevated camera
- Ground-plane movement
- Basic collision
- Basic facing/readability

The purpose of P001 is **not** to build a production-ready player controller.

The purpose is to answer:

> Does a 2D Gold King moving through a 3D environment under a controlled top-down/elevated camera feel intuitive, readable, and promising enough to continue developing?

---

## Approved Constraints

P001 must follow these existing project decisions:

- Engine: **Godot 4.7.2 stable**
- Language: **Typed GDScript**
- Environment: **3D**
- Character presentation: **2D character in the 3D world**
- Camera: **Controlled top-down/elevated**
- Normal gameplay does **not** use free camera rotation
- Exterior spaces should ultimately support a more open, exploratory feel
- Prototype implementation should remain small, modular, readable, and easy to discard or revise

Do not introduce architecture intended for hypothetical later systems.

---

## Prototype Scope

Build only what is necessary to test movement, camera, collision, and character readability.

### Required

- One small 3D test environment
- One placeholder 2D Gold King visual
- Ground-plane movement
- Collision with simple environment geometry
- Controlled top-down/elevated camera
- Basic visual facing response
- Keyboard movement
- Gamepad movement
- Tuning values exposed where practical

### Placeholder Art

Placeholder visuals are encouraged.

The player may use:

- a simple temporary sprite
- rough hand-drawn placeholder art
- a basic directional proxy
- any other clearly temporary 2D representation

Do not spend time creating final character art or animation.

---

## Input Scope

Use Godot input actions rather than hardcoded device checks.

Required actions:

```text
move_left
move_right
move_up
move_down
```

Initial bindings:

### Keyboard

- `W` → move_up
- `S` → move_down
- `A` → move_left
- `D` → move_right

Arrow keys may also be included if trivial.

### Gamepad

- Left analog stick

This is a prototype input configuration only.

The following are **not** being decided in P001:

- Final control scheme
- Input rebinding
- Accessibility input configuration
- Controller menus
- Dead-zone settings UI
- Keyboard settings UI
- Multiple controller profiles

Use Godot's normal input-action system so these decisions remain flexible later.

---

## Movement Requirements

The player must be able to move across the ground plane in all expected directions.

Movement should:

- respond consistently to input
- support diagonal movement without unintended speed increases
- stop predictably when input stops
- respect environment collision
- remain independent of frame rate
- expose core tuning values such as movement speed where practical

Acceleration and deceleration may be tested if needed.

Do not assume they are required for the final game.

---

## Camera Requirements

The camera must:

- use a controlled top-down/elevated view
- follow the player sufficiently for the test
- not require player-controlled rotation
- keep the player readable during normal movement
- allow the test environment's depth and collision boundaries to be understood

The following are intentionally **not finalized**:

- Perspective vs. orthographic projection
- Final camera angle
- Final camera distance
- Final follow smoothing
- Final zoom behavior

These are P001 tuning variables.

If comparing perspective and orthographic projection becomes useful, change one major camera variable at a time where practical.

Do not build a generalized production camera framework.

---

## 2D Character Presentation

The player character should be represented as a 2D visual inside the 3D world.

The prototype should be capable of revealing whether:

- the sprite feels grounded on the terrain
- the character remains visually readable
- depth is understandable
- geometry frequently obscures the character
- the visual facing behavior is understandable

Use the simplest Godot-native implementation appropriate for this test.

The exact production sprite/billboard/animation solution is still open.

Do not permanently lock the project to a specific sprite technique solely because it is used in P001.

---

## Facing Behavior

The character should visually respond to movement direction enough for human testers to understand where the Gold King is facing.

A minimal solution is sufficient.

Requirements:

- Facing should be based on meaningful movement input
- Releasing movement should not produce distracting direction flicker
- The last meaningful facing direction may remain visible while idle

Do not build a final animation state machine.

Do not create final directional animation sets.

---

## Test Environment

Create one small gray-box 3D space suitable for movement testing.

It should contain enough geometry to evaluate:

- open movement
- collision
- navigating around obstacles
- depth readability
- partial occlusion
- character grounding
- camera readability

Possible placeholder geometry:

- flat ground
- walls
- blocks
- a narrow passage
- a wider open area
- one or two raised/tall obstacles

Keep the scene small.

Do not build a real GoldKing region.

Do not spend time on visual polish.

---

## Renderer

The project currently uses Godot's **Mobile renderer**.

Leave it unchanged for P001.

This is a prototype/technical assumption, not a permanent production decision.

Only recommend revisiting the renderer if P001 produces actual evidence of a visual, lighting, performance, or workflow problem.

---

## Acceptance Criteria

P001 is mechanically ready for human evaluation when all of the following are true:

### Project

- The project opens in Godot 4.7.2 without parser errors.
- The P001 test scene runs without immediate runtime errors.

### Movement

- Keyboard movement works.
- Gamepad left-stick movement works.
- Diagonal input does not produce unintended faster movement.
- Movement stops predictably when input stops.
- The player cannot move through test collision geometry.

### Camera

- The camera follows the player.
- The player cannot freely rotate the normal gameplay camera.
- The player remains visible during normal traversal of the test scene.

### Character Presentation

- A placeholder 2D player visual exists inside the 3D environment.
- Facing visibly responds to movement sufficiently for testing.
- The visual remains usable while idle.

### Scope

- No combat system has been introduced.
- No gold system has been introduced.
- No inventory/treasure system has been introduced.
- No production camera framework has been introduced.
- No unnecessary third-party dependency has been added.

---

## Mechanical Validation

Claude or another coding agent may validate objective conditions such as:

- scripts parse successfully
- scene/resource paths resolve
- movement input produces player velocity
- diagonal movement is normalized
- collision prevents passing through test geometry
- the test scene launches without immediate runtime errors

Use only commands that are actually available and verified in the repository environment.

The verified Godot executable path on Quon's macOS environment is:

```bash
/Applications/Godot.app/Contents/MacOS/Godot
```

The repository target is:

```text
Godot 4.7.2 stable
```

Do not invent test commands that have not been verified.

---

## Human Evaluation Questions

P001 is not successful merely because it runs.

Quon and Jason should play the prototype and evaluate:

### Movement

- Does movement direction feel intuitive relative to the camera?
- Does the character feel responsive enough to continue testing from this perspective?
- Does keyboard movement feel understandable?
- Does controller movement feel natural enough for further iteration?

### Camera

- Does the camera angle make movement easy to read?
- Does the view feel too high, too low, too close, or too distant?
- Is there any strong desire to rotate the camera manually?
- Does the camera make open space feel sufficiently open?

### 2D Character in 3D

- Does the character look grounded in the world?
- Does the sprite feel visually detached from the terrain?
- Is depth understandable?
- Does geometry obscure the character too often?
- Is the character easy to locate during movement?
- Does the hybrid presentation feel worth continuing?

### Overall

- Does this presentation feel promising enough to build P002 on top of it?
- Is there a fundamental presentation problem that should be solved before adding gold systems?

These are human judgments.

Automated tests must not claim to answer them.

---

## Success Signals

Evidence supporting the current direction includes:

- Movement feels intuitive relative to the controlled camera.
- The 2D character remains readable against the 3D environment.
- The player understands depth and collision boundaries.
- The character feels sufficiently grounded.
- Manual camera rotation does not feel necessary.
- The environment feels meaningfully more dimensional than a flat 2D space.
- The team wants to continue testing gameplay from this presentation.

---

## Failure / Revision Signals

Evidence suggesting the direction needs revision includes:

- Movement direction remains confusing after reasonable tuning.
- The sprite consistently appears detached from the world.
- Depth is difficult to understand.
- Environment geometry frequently hides the character.
- The camera makes exploration feel cramped.
- Perspective produces significant readability problems.
- The hybrid 2D/3D approach creates disproportionate technical or art problems.
- The team repeatedly wants free camera rotation simply to navigate.

A failure signal does not automatically mean abandoning the 2.5D direction.

It means the cause should be identified and tested before proceeding.

---

## Explicitly Out of Scope

Do not add any of the following during P001 unless Quon or Jason explicitly changes the scope:

- Combat
- Attacks
- Dodge
- Blocking
- Health
- Enemies
- AI
- Gold collection
- Gold burden
- Gold spill
- Gold theft
- Treasure
- Inventory
- Equipment
- Midas/Gilding powers
- Dialogue
- NPC systems
- Quests
- Settlement systems
- Expedition/extraction systems
- Save/load
- Procedural generation
- Final art
- Final animation
- Final shaders
- Final lighting
- Final audio
- Input rebinding
- Input settings UI
- Controller menus
- Accessibility configuration
- Final control scheme
- A generalized production camera framework
- A custom state-machine framework
- A global event bus
- New third-party addons or dependencies

If any of these appear necessary to solve P001, stop and explain why before implementing them.

---

## Implementation Philosophy

P001 exists to generate evidence.

Prefer:

- one simple player scene
- one simple prototype/test scene
- minimal scripts
- exported tuning values
- normal Godot-native patterns
- readable typed GDScript

Avoid:

- generalized gameplay frameworks
- premature production architecture
- speculative extensibility
- systems designed for future combat/gold/inventory
- polishing placeholder content

Prototype code may later be kept, rewritten, simplified, or discarded.

That is acceptable.

---

## Completion Report

When implementation is complete, report:

1. Files created.
2. Files modified.
3. Scene structure.
4. Movement implementation summary.
5. Camera implementation summary.
6. Input actions/bindings added.
7. Tuning values exposed.
8. Mechanical validation performed.
9. Anything that could not be mechanically validated.
10. Questions requiring human playtesting.
11. Any deviation from this specification.

Do not update the Prototype Log with a final outcome until Quon or Jason has actually played the prototype.
