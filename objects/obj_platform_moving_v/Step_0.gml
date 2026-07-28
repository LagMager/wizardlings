/// @description Vertical Moving Platform — Movement

if (global.paused || !platform_active) exit;

var _old_y = y;

y += move_speed * move_dir;

if (abs(y - start_y) >= move_distance) {
    move_dir *= -1;
    y = start_y + (move_distance * sign(y - start_y));
}

var _dy = y - _old_y;
platform_carry_passengers(id, 0, _dy);
