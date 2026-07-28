/// @description Horizontal Moving Platform — Movement

if (global.paused || !platform_active) exit;

var _old_x = x;

x += move_speed * move_dir;

// Reverse at endpoints
if (abs(x - start_x) >= move_distance) {
    move_dir *= -1;
    x = start_x + (move_distance * sign(x - start_x));
}

// Carry any apprentices standing on top
var _dx = x - _old_x;
platform_carry_passengers(id, _dx, 0);
