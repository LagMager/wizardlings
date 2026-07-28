/// @description Button — Check for contact

if (!interactable_active || is_triggered) {
    image_index = is_triggered ? 1 : 0;
    image_speed = 0;
    exit;
}
if (global.paused) exit;
if (variable_global_exists("level_started") && !global.level_started) exit;

var _contact = collision_rectangle(
    bbox_left, bbox_top, bbox_right, bbox_bottom,
    obj_apprentice, false, true
);

if (_contact != noone) {
    if (requires_capability == CAP.NONE || capability_has(_contact, requires_capability)) {
        activate(_contact);
    }
}

image_index = is_triggered ? 1 : 0;
image_speed = 0;
