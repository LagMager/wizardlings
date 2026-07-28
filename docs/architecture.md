# Wizardlings — Architecture Specification

**Version:** 1.0  
**Date:** 2026-07-27  
**Engine:** GameMaker Studio 2 (GML)  

---

## 1. Architecture Overview

The architecture separates concerns into five layers:

```
┌─────────────────────────────────────────────────────────┐
│                    SCRIPTS (Logic Layer)                  │
│  scr_core · scr_capabilities · scr_signals              │
│  scr_movement · scr_interaction · scr_camera            │
├─────────────────────────────────────────────────────────┤
│                 PARENT OBJECTS (Interface Layer)          │
│  obj_environment_parent                                  │
│    ├── obj_platform_parent                               │
│    ├── obj_hazard_parent                                 │
│    ├── obj_interactable_parent                           │
│    └── obj_mechanism_parent                              │
├─────────────────────────────────────────────────────────┤
│              CHILD OBJECTS (Implementation Layer)         │
│  obj_platform_moving_h · obj_platform_moving_v           │
│  obj_platform_falling · obj_hazard_spikes                │
│  obj_hazard_water · obj_hazard_fire · obj_hazard_lava    │
│  obj_interactable_button · obj_interactable_lever        │
│  obj_mechanism_door · obj_mechanism_bridge               │
├─────────────────────────────────────────────────────────┤
│               TILEMAP COLLISION (Static Terrain)         │
│  Floors · Walls · Ceilings · Slopes                     │
│  Managed by core_setup_collision_tilemap()               │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Object Hierarchy

```
obj_environment_parent          [Abstract root - no behavior]
├── obj_platform_parent         [Base: platform_active, carries passengers]
│   ├── obj_platform_static     [Doesn't move, just solid]
│   ├── obj_platform_moving_h   [Horizontal ping-pong]
│   ├── obj_platform_moving_v   [Vertical ping-pong]
│   └── obj_platform_falling    [Falls when stepped on, respawns]
│
├── obj_hazard_parent           [Base: affect(), can_be_countered(), on_neutralize()]
│   ├── obj_hazard_spikes       [Countered by BUILD_BRIDGE]
│   ├── obj_hazard_water        [Countered by FREEZE_WATER]
│   ├── obj_hazard_fire         [Countered by EXTINGUISH_FIRE]
│   ├── obj_hazard_lava         [Uncounterable - must avoid]
│   ├── obj_hazard_void         [Fall-through death zone]
│   └── obj_hazard_sawblade     [Moving hazard with its own Step]
│
├── obj_interactable_parent     [Base: activate(), signal_channel]
│   ├── obj_interactable_button        [One-shot trigger]
│   ├── obj_interactable_lever         [Toggle on/off]
│   └── obj_interactable_pressure_plate [Active while stood on]
│
└── obj_mechanism_parent        [Base: on_signal(), mechanism_state]
    ├── obj_mechanism_door      [Opens/closes on signal]
    └── obj_mechanism_bridge    [Extends/retracts on signal]
```

**Existing objects NOT in the hierarchy** (intentional):
- `obj_apprentice` — The player entity, not an environment object.
- `obj_game_controller` — System singleton.
- `obj_ui` — HUD overlay.
- `obj_exit` — Could optionally become a mechanism child later.
- `obj_barrier_zone` — Attached to Aegimancer, not environment.
- `obj_terrain_block` / `obj_ice_platform` — Created dynamically by casting.
  These participate in instance collision but don't need parent hierarchy.
- `obj_wind_object` — Already functions as a mechanism. Could be refactored
  into obj_mechanism_parent later if desired.
- `obj_hazard` — **Legacy object, kept for backward compatibility with Room1.**
  New levels should use typed hazard children (obj_hazard_spikes, etc).

---

## 3. Collision Architecture

### Two Independent Systems

```
Apprentice Movement
├── 1. Tilemap Collision (static terrain)
│   └── core_rect_hits_tilemap() → checks global.collision_tilemap
│       Used for: walking, walls, ground, ceilings
│
└── 2. Instance Collision (dynamic objects)
    └── core_rect_hits_instances() → checks obj_terrain_block, obj_ice_platform,
        obj_wind_object, obj_platform_parent children
        Used for: spawned terrain, moving platforms, mechanisms
```

### Why Separate?
- Tilemaps are O(1) lookups — instant, no iteration.
- Instance collision is O(n) — only used for dynamic objects.
- Tilemap terrain never moves, so it's pure data. Editing a tile is trivial.
- Objects have behavior (movement, timers, destruction). They need Step events.

### Adding New Solid Objects
To make a new object participate in instance collision, add it to
`core_rect_hits_instances()` in `scr_core.gml`.

---

## 4. Capability System

### Philosophy
Instead of:
```gml
// BAD — tightly coupled
if (role == ROLE.CRYO) { freeze_water(); }
```

We use:
```gml
// GOOD — decoupled, extensible
if (capability_has(apprentice, CAP.FREEZE_WATER)) { on_neutralize(apprentice); }
```

### Current Capability Map

| Role | Capabilities |
|------|-------------|
| NONE | RIDE_PLATFORM, USE_SWITCH |
| GEO  | BUILD_BRIDGE, RIDE_PLATFORM, USE_SWITCH |
| CRYO | FREEZE_WATER, EXTINGUISH_FIRE, SOLIDIFY_TERRAIN, RIDE_PLATFORM, USE_SWITCH |
| AEGI | PROJECT_BARRIER, RIDE_PLATFORM, USE_SWITCH |
| AERO | CONTROL_WIND, PUSH_OBJECTS, RIDE_PLATFORM, USE_SWITCH |

### Adding a New Role
1. Add to `ROLE` enum in `scr_core.gml`.
2. Add a case in `capability_init()` in `scr_capabilities.gml`.
3. Done. All environment objects that check capabilities will work.

---

## 5. Signal System

### Flow

```
[Interactable]  ──signal_emit("channel", value)──→  [Signal Registry]  ──on_signal(value)──→  [Mechanism]
```

### Designer Workflow
1. Place `obj_interactable_button` in room.
2. In its Creation Code: `signal_channel = "door_1";`
3. Place `obj_mechanism_door` in room.
4. In its Creation Code: `signal_channel = "door_1";`
5. When apprentice hits button → door opens. No code changes needed.

### Multiple listeners per channel
Multiple mechanisms can listen on the same channel. One button can open
multiple doors simultaneously.

---

## 6. Platform System

### Design Principle
Platforms are responsible for carrying their passengers. Characters never
check what type of platform they're on.

### How Carrying Works
1. Platform moves itself (changes its x/y).
2. Platform calls `platform_carry_passengers(id, dx, dy)`.
3. The function finds all apprentices whose feet are at the platform's top.
4. Those apprentices move by the same delta.

### Adding a New Platform Type
1. Create child of `obj_platform_parent`.
2. Call `event_inherited()` in Create.
3. Implement your own Step movement.
4. Call `platform_carry_passengers(id, dx, dy)` after moving.
5. Done.

---

## 7. Hazard System

### Polymorphic Interface

Every hazard child defines:
- `required_capability` — What CAP flag counters it.
- `affect(target)` — What happens on contact (default: kill).
- `can_be_countered(target)` — Checks if target has the required capability.
- `on_neutralize(source)` — What happens when countered (build bridge, freeze, etc).

### Interaction Flow
1. Apprentice detects `obj_hazard_parent` ahead (via `interaction_check_hazard_ahead`).
2. Calls `hazard.can_be_countered(self)`.
3. If true → begin casting → on complete → `hazard.on_neutralize(self)`.
4. If false and touching → `hazard.affect(self)` → typically death.
5. Barrier absorption check happens before affect() kills.

---

## 8. Scripts Reference

| Script | Responsibility |
|--------|---------------|
| `scr_core` | Enums, config, tilemap collision, cast system, role assignment, validation |
| `scr_camera` | Pixel-perfect camera: init, update, zoom, pan, helpers |
| `scr_capabilities` | CAP enum, capability_init(), capability_has/any/all() |
| `scr_signals` | Signal registry: init, register, emit, unregister |
| `scr_interaction` | Collision queries against parent objects (hazard, platform, interactable) |
| `scr_movement` | Reusable movement: horizontal, gravity, ground check, platform carrying |

---

## 9. Folder Organization

```
Wizardlings/
├── docs/
│   ├── vision.md
│   ├── requirements.md
│   ├── technical_design.md
│   └── architecture.md          ← This document
├── scripts/
│   ├── scr_core/                ← Enums, config, collision, core logic
│   ├── scr_camera/              ← Pixel-perfect camera system
│   ├── scr_capabilities/        ← Capability bitmask system
│   ├── scr_signals/             ← Event channel system
│   ├── scr_interaction/         ← Environment query helpers
│   └── scr_movement/            ← Reusable physics/movement
├── objects/
│   ├── obj_apprentice/          ← Player entity
│   ├── obj_game_controller/     ← Level management singleton
│   ├── obj_ui/                  ← HUD
│   ├── obj_environment_parent/  ← Abstract root (no behavior)
│   ├── obj_platform_parent/     ← Platform interface
│   ├── obj_platform_moving_h/   ← Horizontal mover
│   ├── obj_platform_moving_v/   ← Vertical mover
│   ├── obj_platform_falling/    ← Crumble platform
│   ├── obj_hazard_parent/       ← Hazard interface
│   ├── obj_hazard_spikes/       ← Spike hazard (countered by Geo)
│   ├── obj_hazard_water/        ← Water hazard (countered by Cryo)
│   ├── obj_interactable_parent/ ← Interactable interface
│   ├── obj_interactable_button/ ← One-shot button
│   ├── obj_mechanism_parent/    ← Mechanism interface
│   ├── obj_mechanism_door/      ← Signal-driven door
│   ├── obj_hazard/              ← Legacy hazard (backward compat)
│   ├── obj_terrain_block/       ← Geomancer-spawned solid
│   ├── obj_ice_platform/        ← Cryomancer-spawned temporary solid
│   ├── obj_wind_object/         ← Aeromancer-activated mover
│   ├── obj_barrier_zone/        ← Aegimancer shield radius
│   ├── obj_exit/                ← Level exit trigger
│   └── obj_spawn_point/         ← Apprentice spawner
├── rooms/
│   ├── rm_main_menu/
│   ├── rm_level_select/
│   ├── Room1/                   ← Uses legacy obj_hazard (still works)
│   └── Room2/
└── sprites/ tilesets/ options/
```

---

## 10. Design Decisions & Rationale

| Decision | Rationale |
|----------|-----------|
| Bitmask capabilities instead of arrays | O(1) checks, no allocation, trivially combinable with bitwise OR |
| Signals instead of direct references | Designer doesn't need to wire instance IDs; just matching string names |
| Parent objects with method overrides | GameMaker's native inheritance; collision checks against parent catch all children |
| Tilemaps for static terrain | Performance (O(1) lookups), easy level editing, no instance overhead |
| platform_carry_passengers in scripts | Reusable by all platform types without code duplication |
| Legacy obj_hazard preserved | Room1 still works without migration; new levels use typed children |
| event_inherited() in every child Create | Ensures parent interface is always initialized correctly |

---

## 11. Pitfalls & How to Avoid Them

| Pitfall | Solution |
|---------|----------|
| Forgetting `event_inherited()` in child Create | Parent variables won't exist → crashes. Always call it first. |
| Signal channel typo | Button says "door_A", door says "door_a" → nothing happens. Use constants or validate at boot. |
| Mechanism registering before signal_channel is set | Registration happens in Step (deferred) because room Creation Code runs after Create. |
| Platform carrying applied before platform moves | Always carry AFTER moving. `platform_carry_passengers` uses post-move position. |
| Adding solid object but forgetting core_rect_hits_instances | Apprentices walk through it. Must add to the collision function. |
| Circular signal loops | Button A → opens Door → triggers Button B → closes Door → repeat. Keep signal graphs acyclic. |
| Testing obj_hazard_parent collision but legacy obj_hazard isn't a child | Legacy levels use obj_hazard directly. New levels use typed children. Don't mix in the same room. |

---

## 12. Migration Guide (Legacy → New Architecture)

For existing levels (Room1, Room2) that use `obj_hazard`:
- **No changes needed.** The legacy `obj_hazard` still works via `scr_core` functions.
- New levels should place typed hazard children (`obj_hazard_spikes`, etc) instead.
- When you're ready to migrate a room: replace each `obj_hazard` instance with the
  appropriate typed child and remove its Creation Code (behavior is in the child now).

---

## 13. Future Expansion Checklist

| To Add | Steps |
|--------|-------|
| New wizard role | 1. Add to ROLE enum. 2. Add case in capability_init(). 3. Optionally add cast action. |
| New hazard | 1. Create child of obj_hazard_parent. 2. Set required_capability. 3. Override on_neutralize(). |
| New platform | 1. Create child of obj_platform_parent. 2. Implement Step movement. 3. Call platform_carry_passengers(). |
| New interactable | 1. Create child of obj_interactable_parent. 2. Override activate(). 3. Set signal_channel. |
| New mechanism | 1. Create child of obj_mechanism_parent. 2. Override on_signal(). 3. Register on channel. |
| Boss encounter | Create standalone object. Can use capability_has() to check player abilities. |

---

*This architecture prioritizes simplicity, extensibility, and GameMaker's strengths. Every new gameplay element is a single object file with a Create event — no framework overhead, no entity systems, just clean inheritance and reusable scripts.*
