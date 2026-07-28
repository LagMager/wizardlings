/// @description Vertical Moving Platform — Movement

if (global.paused || !platform_active) exit;

if (!_layout_applied) {
    platform_v_finalize_config(id);
}

if (endpoint_wait > 0) {
    endpoint_wait -= 1;
    exit;
}

if (!platform_has_aero_onboard(id)) exit;

var _old_y = y;
y += move_speed * move_dir;

if (move_dir < 0) {
    if (y <= top_y + 0.001) {
        y = top_y;
        move_dir = 1;
        endpoint_wait = endpoint_pause_frames;
    }
} else {
    if (y >= bottom_y - 0.001) {
        y = bottom_y;
        move_dir = -1;
        endpoint_wait = endpoint_pause_frames;
    }
}

var _dy = y - _old_y;
platform_carry_passengers(id, 0, _dy);
