/// @description Water/Liquid Hazard
///
/// PURPOSE: Liquid hazard that kills on contact. Cryomancer can freeze it.
/// PARENT: obj_hazard_parent
/// COUNTERED BY: CAP.FREEZE_WATER (Cryomancer)
///
/// Uses your sprite for visuals. Lethal contact uses the liquid body only (see
/// liquid_contact_top_offset), not transparent padding in the sprite mask.
/// When frozen, frame 3 shows ice and walk collision uses the top of the bbox only
/// (no separate obj_ice_platform — that object used a tall apprentice mask and blocked movement).

event_inherited();

required_capability = CAP.FREEZE_WATER;
ice_effect = noone;
freeze_timer = 0;

// Last sub-image is the frozen state (Sprite5: frames 0–1 liquid, 2 frozen).
frozen_image_index = max(0, image_number - 1);
if (image_number > 2) {
    image_speed = 0.12;
} else {
    image_speed = 0;
}

// Pixels below bbox_top where the liquid body begins (Creation Code to tune)
if (!variable_instance_exists(id, "liquid_contact_top_offset")) {
    var _h = bbox_bottom - bbox_top + 1;
    liquid_contact_top_offset = floor(_h * 0.25);
}

/// Override: can_be_countered — Cryo only while water is active and unfrozen
can_be_countered = function(_target) {
    if (!hazard_active || is_neutralized) return false;
    return capability_has(_target, CAP.FREEZE_WATER);
};

/// Override: on_neutralize — Cryomancer freezes the surface (visual + walk strip on this instance)
on_neutralize = function(_source) {
    if (is_neutralized) return;

    is_neutralized = true;
    hazard_active = false;
    image_index = frozen_image_index;
    image_speed = 0;
    freeze_timer = global.core_config.ice_lifetime;
    ice_effect = noone;
};

/// Method: on_ice_melted — Called when freeze_timer expires.
on_ice_melted = function() {
    is_neutralized = false;
    hazard_active = true;
    ice_effect = noone;
    freeze_timer = 0;
    image_index = 0;
    image_speed = (image_number > 2) ? 0.12 : 0;
};
