# Wizardlings — Technical Design Specification

**Version:** 1.0  
**Date:** 2026-07-22  
**Engine:** GameMaker Studio 2 (GML)  
**Scope:** One-week hackathon build  

---

## 1. Core Systems

### 1.1 Apprentice System
Each apprentice is a self-contained `obj_apprentice` instance. Movement is manual (`x += move_speed * direction`). Terrain collision uses `tilemap_get_at_pixel()` against a collision tile layer. Edge detection uses a lookahead check one pixel below and ahead — if no ground tile exists, the apprentice walks off. Wall detection reverses direction.

State is managed via an enum-driven state machine in the Step event. Role behavior is encoded as a sub-state within the Casting state — when an apprentice encounters a relevant obstacle, it transitions to Casting, performs its role action, then returns to Walking.

### 1.2 Role Assignment System
Managed by `obj_game_controller`. The controller holds an array of role budgets for the current level (e.g., `role_budget[ROLE.GEO] = 2`). 

The player pauses the game (toggling `global.paused`), selects a role from the UI panel (tool-first), then clicks an apprentice. On valid assignment: decrement budget, set `apprentice.role = selected_role`, unpause.

### 1.3 Hazard System
Hazards are object instances placed in rooms by the designer. Each hazard has a `hazard_type` variable (enum: `GAP`, `SPIKES`, `LIQUID`, `FIRE`, `HAZARD_TERRAIN`). 

On collision with an apprentice:
- If apprentice has a role that counters this hazard → trigger Casting state
- If apprentice is within an Aegimancer barrier radius → absorb hit (decrement barrier)
- Otherwise → kill apprentice (transition to Dead state)

### 1.4 Level Management
`obj_game_controller` owns level metadata: `apprentice_count`, `win_threshold`, `role_budget[]`. These are set per-room in the Creation Code of `obj_game_controller`'s instance.

Level transitions use `room_goto()`. Restart uses `room_restart()`.

### 1.5 Victory/Defeat System
`obj_game_controller` tracks `apprentices_exited` and `apprentices_alive`. Checked every frame:
- **Win:** `apprentices_exited >= win_threshold`
- **Lose:** `apprentices_alive + apprentices_exited < win_threshold` (impossible to win)

On win/lose, set `global.paused = true` and show the appropriate UI overlay.

### 1.6 UI System
`obj_ui` draws the HUD via the Draw GUI event:
- Role panel (available roles + remaining budget counts)
- Currently selected role (highlighted)
- Apprentice counter: `alive / threshold`
- Pause indicator

During pause, the UI panel is interactive (clickable role buttons). Selection state stored in `obj_game_controller.selected_role`.

---

## 2. Objects

| Object | Responsibilities | Key Interactions |
|--------|-----------------|------------------|
| `obj_apprentice` | Movement, state machine, collision detection, role behavior execution, death/exit | Collides with tiles, hazards, exit. Reads `global.paused`. |
| `obj_game_controller` | Level metadata, role budget, assignment logic, win/lose checks, pause state, spawning | Receives click input for role assignment. Tracks all apprentices via instance list. |
| `obj_hazard` | Represents a lethal obstacle. Holds `hazard_type`. | Detected by apprentices via `place_meeting()` or proximity check. |
| `obj_exit` | Level exit trigger. | On collision with apprentice → signals exit to controller, destroys/hides apprentice. |
| `obj_barrier_zone` | Invisible child object attached to Aegimancer. Represents the shield radius. | Hazards check for overlap with this before killing apprentices. `barrier_hits` tracked here. |
| `obj_terrain_block` | Geomancer-spawned terrain. Solid. | Created by Geomancer during casting. Added to collision layer or acts as solid instance. |
| `obj_ice_platform` | Cryomancer-spawned temporary terrain. | Created on liquid/fire hazards. Has a `timer` that destroys it after expiration. |
| `obj_wind_object` | Designer-placed moving platform/fan/elevator. Has `active` flag. | Aeromancer activates it on proximity. Carries apprentices when active. |
| `obj_ui` | HUD rendering and role button click detection. | Reads from `obj_game_controller` for budget/state. |

---

## 3. Apprentice State Machine

```
┌─────────────────────────────────────────────────────┐
│                    STATES                            │
├──────────┬──────────┬──────────┬────────────────────┤
│ Walking  │ Casting  │  Dead    │  Exited            │
└──────────┴──────────┴──────────┴────────────────────┘
```

**Transitions:**

| From | To | Condition |
|------|----|-----------|
| Walking | Casting | Apprentice has a role AND encounters a matching obstacle |
| Walking | Dead | Contacts hazard with no counter-role and no barrier protection |
| Walking | Exited | Contacts `obj_exit` |
| Walking | Dead | Falls off bottom of room (y > room_height) |
| Casting | Walking | Cast action completes (animation timer expires, terrain/effect spawned) |
| Casting | Dead | Killed during cast (e.g., barrier breaks mid-cast from separate hazard) |

**Notes:**
- Dead and Exited are terminal states (no transitions out).
- `global.paused == true` freezes all transitions — Step logic skips when paused.

---

## 4. Gameplay Flow

**Level Initialization:**
1. Room loads → `obj_game_controller` Creation Code sets `win_threshold`, `apprentice_count`, `role_budget[]`.
2. `obj_game_controller` Create event spawns `apprentice_count` instances of `obj_apprentice` at designated spawn marker positions (or uses pre-placed instances).
3. UI initializes, displays role panel and counter.

**Role Assignment:**
1. Player presses pause key → `global.paused = true`.
2. Player clicks a role button in the UI → `selected_role` set.
3. Player clicks an apprentice instance → if `apprentice.role == ROLE.NONE` and `role_budget[selected_role] > 0`: assign role, decrement budget, unpause.

**Hazard Interaction:**
1. Apprentice Step event detects hazard ahead (via `place_meeting` offset check or `collision_line`).
2. If apprentice role counters hazard type → transition to Casting, perform role action.
3. If no counter and no barrier → transition to Dead.
4. If inside `obj_barrier_zone` → hazard hit absorbed, `barrier_hits--`. If hits reach 0, destroy barrier zone.

**Victory:**
- Apprentice touches `obj_exit` → `apprentices_exited++`, apprentice state = Exited, instance becomes invisible/deactivated.
- Controller checks: if `apprentices_exited >= win_threshold` → show win overlay.

**Defeat:**
- Apprentice dies → `apprentices_alive--`.
- Controller checks: if `apprentices_alive + apprentices_exited < win_threshold` → show lose overlay.

**Restart:**
- Player presses restart key or clicks restart button → `room_restart()`.

---

## 5. Data Model

### obj_apprentice
```
state           : enum (WALKING, CASTING, DEAD, EXITED)
role            : enum (NONE, GEO, CRYO, AEGI, AERO)
direction       : -1 or 1 (horizontal facing)
move_speed      : real (pixels per frame, e.g., 1.5)
cast_timer      : int (frames remaining in cast animation)
sprite_index    : assigned per role/state
```

### obj_game_controller
```
win_threshold       : int
apprentice_count    : int
apprentices_alive   : int
apprentices_exited  : int
role_budget[]       : array indexed by ROLE enum
selected_role       : enum (current tool selection)
level_state         : enum (PLAYING, WON, LOST)
```

### obj_hazard
```
hazard_type     : enum (GAP, SPIKES, LIQUID, FIRE, HAZARD_TERRAIN)
```

### obj_barrier_zone
```
barrier_hits    : int (starts at 2)
owner           : instance id of parent Aegimancer
```

### obj_ice_platform
```
lifetime        : int (frames until destruction)
timer           : int (counts down each frame)
```

### obj_wind_object
```
active          : bool
move_path       : predefined path or target positions
speed           : real
```

---

## 6. Room Structure

Each level is one GameMaker room. Layers (bottom to top):

| Layer | Type | Contents |
|-------|------|----------|
| `bg_background` | Background | Solid color or tiled background art |
| `tiles_visual` | Tile Layer | Visual terrain tiles (non-colliding, decorative) |
| `tiles_collision` | Tile Layer | Collision tilemap (1-bit: solid or empty). Used by movement code. |
| `instances_hazards` | Instance Layer | `obj_hazard` instances placed by designer |
| `instances_environment` | Instance Layer | `obj_wind_object`, `obj_exit`, spawn markers |
| `instances_entities` | Instance Layer | `obj_apprentice` (if pre-placed) or spawned at runtime |
| `instances_controller` | Instance Layer | Single `obj_game_controller` instance with Creation Code |
| `ui` | Instance Layer | `obj_ui` (persistent or per-room) |

**Collision tilemap convention:** Tile index 0 = empty (no collision). Any non-zero tile = solid.

---

## 7. Interaction Rules

| Hazard Type | Geomancer | Cryomancer | Aegimancer | Aeromancer |
|-------------|-----------|------------|------------|------------|
| Gap/Pit | ✅ Builds bridge | ✗ | ✗ (barrier doesn't prevent falling) | ✗ (activates nearby wind object if present) |
| Spikes | ✅ Builds bridge over | ✗ | ✅ Barrier absorbs hit | ✗ |
| Liquid | ✗ | ✅ Freezes surface (temporary) | ✅ Barrier absorbs hit | ✗ |
| Fire/Flames | ✗ | ✅ Extinguishes (temporary) | ✅ Barrier absorbs hit | ✗ |
| Hazardous Terrain | ✗ | ✅ Solidifies (temporary) | ✅ Barrier absorbs hit | ✗ |

**Aeromancer special case:** The Aeromancer does not directly counter hazards. Instead, when it encounters a designer-placed `obj_wind_object` in proximity, it activates that object (sets `active = true`), enabling traversal for all apprentices.

**Aegimancer note:** The barrier does NOT prevent falling into gaps (no floor = no protection). It only absorbs damage from contact hazards.

---

## 8. Out of Scope

- Entity Component System (ECS)
- Generic entity frameworks or plugin architectures
- Deep inheritance hierarchies (use flat objects with enums)
- Networking / multiplayer
- Save/load systems
- Procedural level generation
- Undo/rewind mechanics
- Sound system (stretch goal, not in spec)
- Dialogue or cutscene systems
- Meta-progression between levels
