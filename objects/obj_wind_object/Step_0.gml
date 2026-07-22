if (active && !instance_exists(source_hazard)) {
    source_hazard = collision_rectangle(bbox_left, bbox_top - 16, bbox_right, bbox_bottom + 64, obj_hazard, false, true);
    if (instance_exists(source_hazard) && (source_hazard.hazard_type == HAZARD_TYPE.GAP)) {
        source_hazard.wind_resolved = true;
    }
    solid_enabled = true;
}

if (global.paused || !active || route_complete) exit;

var _old_x = x;
var _old_y = y;
var _distance = point_distance(x, y, target_x, target_y);
if (_distance <= move_speed) {
    x = target_x;
    y = target_y;
    route_complete = true;
} else {
    var _direction = point_direction(x, y, target_x, target_y);
    x += lengthdir_x(move_speed, _direction);
    y += lengthdir_y(move_speed, _direction);
}
solid_enabled = true;

var _dx = x - _old_x;
var _dy = y - _old_y;
var _old_left = _old_x;
var _old_right = _old_x + (sprite_width * abs(image_xscale)) - 1;
var _old_top = _old_y;
with (obj_apprentice) {
    if ((state != AP_STATE.DEAD) && (state != AP_STATE.EXITED)) {
        if ((bbox_right >= _old_left) && (bbox_left <= _old_right) && (abs(bbox_bottom - _old_top) <= 2)) {
            x += _dx;
            y += _dy;
        }
    }
}

if (route_complete) {
    var _gap = collision_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom + 32, obj_hazard, false, true);
    if ((_gap != noone) && (_gap.hazard_type == HAZARD_TYPE.GAP)) _gap.wind_resolved = true;
    show_debug_message("[WIND] Platform reached target");
}
