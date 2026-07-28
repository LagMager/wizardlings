/// @description Spikes Hazard
///
/// PURPOSE: Contact hazard that kills on touch. Geomancer can build a bridge over it.
/// PARENT: obj_hazard_parent
/// COUNTERED BY: CAP.BUILD_BRIDGE (Geomancer)
///
/// BEHAVIOR:
///   - Instant kill on contact (unless barrier absorbs).
///   - Geomancer builds solid terrain over the spikes area.
///   - Once bridged, is_neutralized = true and hazard becomes safe.

event_inherited();

required_capability = CAP.BUILD_BRIDGE;

/// Override: on_neutralize — Geomancer builds terrain over spikes
on_neutralize = function(_source) {
    is_neutralized = true;
    hazard_active = false;
    
    // Spawn terrain block over the spikes
    var _width = bbox_right - bbox_left + 1;
    instance_create_layer(
        bbox_left,
        bbox_top,
        "instances_environment",
        obj_terrain_block,
        {
            block_width: _width,
            block_height: global.core_config.terrain_height,
            source_hazard: id
        }
    );
};
