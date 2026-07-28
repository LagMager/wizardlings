/// @description Button — Check for contact

if (!interactable_active || is_triggered) exit;
if (global.paused) exit;

var _contact = collision_rectangle(
    bbox_left, bbox_top, bbox_right, bbox_bottom,
    obj_apprentice, false, true
);

if (_contact != noone) {
    if (requires_capability == CAP.NONE || capability_has(_contact, requires_capability)) {
        activate(_contact);
    }
}
