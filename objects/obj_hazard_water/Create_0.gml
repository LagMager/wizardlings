/// @description Water/Liquid Hazard
///
/// PURPOSE: Liquid hazard that kills on contact. Cryomancer can freeze it.
/// PARENT: obj_hazard_parent
/// COUNTERED BY: CAP.FREEZE_WATER (Cryomancer)
///
/// BEHAVIOR:
///   - Drowns apprentice on contact.
///   - Cryomancer creates temporary ice platform on the surface.
///   - Ice melts after ice_lifetime frames, hazard reactivates.

event_inherited();

required_capability = CAP.FREEZE_WATER;
ice_effect = noone;

/// Override: on_neutralize — Cryomancer freezes the surface
on_neutralize = function(_source) {
    is_neutralized = true;
    hazard_active = false;
    
    var _width = bbox_right - bbox_left + 1;
    ice_effect = instance_create_layer(
        bbox_left,
        bbox_top,
        "instances_environment",
        obj_ice_platform,
        {
            platform_width: _width,
            platform_height: global.core_config.terrain_height,
            source_hazard: id,
            lifetime: global.core_config.ice_lifetime
        }
    );
};

/// Method: on_ice_melted — Called when the ice platform expires.
on_ice_melted = function() {
    is_neutralized = false;
    hazard_active = true;
    ice_effect = noone;
};
