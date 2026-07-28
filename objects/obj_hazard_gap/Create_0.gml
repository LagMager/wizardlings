/// @description Gap/Void Hazard
///
/// PURPOSE: A gap in the floor that apprentices fall through and die.
///          Geomancer builds a permanent bridge. Aeromancer activates a nearby
///          wind object to create an air platform over it.
/// PARENT: obj_hazard_parent
/// COUNTERED BY: CAP.BUILD_BRIDGE (Geomancer) or CAP.CONTROL_WIND (Aeromancer)
///
/// BEHAVIOR:
///   - Apprentices walking over this fall to their death.
///   - Geomancer: builds solid terrain (obj_terrain_block) bridging the gap.
///   - Aeromancer: activates a linked obj_wind_object to provide a moving platform.
///   - Aegimancer barrier does NOT protect against gaps (no floor = no help).
///
/// DESIGNER VARIABLES:
///   gap_width       : real — Width of the gap in pixels (set via scale or Creation Code).
///   linked_wind     : Id.Instance — Optional. Wind object the Aeromancer activates.
///                     Set in room Creation Code if an Aero solution exists.

event_inherited();

// Gap dimensions — set via room Creation Code or instance scale
// If using a sprite, the bbox comes from the sprite. Otherwise set manually:
if (!variable_instance_exists(id, "gap_width")) gap_width = 32;
if (!variable_instance_exists(id, "gap_height")) gap_height = 32;

// Gaps can be countered by either BUILD_BRIDGE or CONTROL_WIND
required_capability = CAP.BUILD_BRIDGE | CAP.CONTROL_WIND;

// Designer can link a wind object for the Aeromancer solution
linked_wind = noone;

// Track resolution state per method
geo_resolved = false;
wind_resolved = false;

/// Override: can_be_countered — accepts either Geo or Aero
can_be_countered = function(_target) {
    if (geo_resolved || wind_resolved) return false;
    return capability_has_any(_target, CAP.BUILD_BRIDGE | CAP.CONTROL_WIND);
};

/// Override: on_neutralize — Geo builds bridge, Aero activates wind
on_neutralize = function(_source) {
    if (capability_has(_source, CAP.BUILD_BRIDGE)) {
        // Geomancer: fill the top of the gap with collision tiles (matches tilemap terrain)
        geo_resolved = true;
        is_neutralized = true;
        hazard_active = false;
        
        var _tile_size = global.core_config.tile_size;
        var _tilemap = global.collision_tilemap;
        
        if (_tilemap != -1) {
            // Fill one row of tiles across the gap at its top edge
            var _start_col = floor(bbox_left / _tile_size);
            var _end_col = ceil((bbox_right + 1) / _tile_size) - 1;
            var _row = floor(bbox_top / _tile_size);
            
            for (var _col = _start_col; _col <= _end_col; _col++) {
                tilemap_set(_tilemap, 1, _col, _row);
            }
        }
    } else if (capability_has(_source, CAP.CONTROL_WIND)) {
        // Aeromancer: activate linked wind object
        if (instance_exists(linked_wind) && !linked_wind.active) {
            linked_wind.active = true;
            linked_wind.activation_started = true;
            wind_resolved = true;
            is_neutralized = true;
            hazard_active = false;
        }
    }
};

/// Override: affect — falling into a gap is instant death
affect = function(_target) {
    core_notify_terminal(_target, AP_STATE.DEAD);
};
