/// @description Gap/Void Hazard
///
/// PURPOSE: A gap in the floor that apprentices fall through and die.
///          Geomancer builds a permanent bridge. Aeromancer leaps over with VOIDWALK.
///          Optional linked wind is for separate wind-platform puzzles (obj_wind_object).
/// PARENT: obj_hazard_parent
/// COUNTERED BY: CAP.BUILD_BRIDGE (Geomancer). Aeromancer jumps via CAP.VOIDWALK in code.
///
/// BEHAVIOR:
///   - Apprentices walking over this fall to their death.
///   - Geomancer: builds solid terrain (obj_terrain_block) bridging the gap.
///   - Aeromancer: auto gap-jump when the gap is ahead and within jump range.
///   - Aegimancer barrier does NOT protect against gaps (no floor = no help).
///
/// DESIGNER VARIABLES:
///   gap_width       : real — Width of the gap in pixels (set via scale or Creation Code).
///   linked_wind     : Id.Instance — Optional. Used when a wind platform marks this gap solved.

event_inherited();

if (!variable_instance_exists(id, "gap_width")) gap_width = 32;
if (!variable_instance_exists(id, "gap_height")) gap_height = 32;

required_capability = CAP.BUILD_BRIDGE;

linked_wind = noone;

geo_resolved = false;
wind_resolved = false;

/// Override: can_be_countered — Geomancer bridge only (Aero uses gap jump, not cast)
can_be_countered = function(_target) {
    if (geo_resolved || wind_resolved) return false;
    return capability_has(_target, CAP.BUILD_BRIDGE);
};

/// Override: on_neutralize — Geo builds bridge
on_neutralize = function(_source) {
    if (capability_has(_source, CAP.BUILD_BRIDGE)) {
        geo_resolved = true;
        is_neutralized = true;
        hazard_active = false;

        var _width = bbox_right - bbox_left + 1;
        core_geo_build_bridge(bbox_left, bbox_top, _width, id);
    }
};

/// Override: affect — falling into a gap is instant death
affect = function(_target) {
    core_notify_terminal(_target, AP_STATE.DEAD);
};
