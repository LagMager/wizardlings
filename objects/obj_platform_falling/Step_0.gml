/// @description Falling Platform — Logic

if (global.paused || !platform_active) exit;

// Check if something is standing on us
if (!is_triggered && !is_falling) {
    var _rider = collision_rectangle(
        bbox_left, bbox_top - 2,
        bbox_right, bbox_top,
        obj_apprentice, false, true
    );
    if (_rider != noone) {
        is_triggered = true;
        fall_timer = fall_delay;
    }
}

// Countdown to fall
if (is_triggered && !is_falling) {
    fall_timer -= 1;
    if (fall_timer <= 0) {
        is_falling = true;
    }
}

// Fall
if (is_falling) {
    var _old_y = y;
    fall_speed += fall_gravity;
    y += fall_speed;
    platform_carry_passengers(id, 0, y - _old_y);
    
    // Destroy when off-screen
    if (y > room_height + 32) {
        if (respawn_time > 0) {
            // Reset for respawn
            visible = false;
            platform_active = false;
            is_falling = false;
            is_triggered = false;
            fall_speed = 0;
            respawn_timer = respawn_time;
        } else {
            instance_destroy();
        }
    }
}

// Respawn logic
if (!platform_active && respawn_timer > 0) {
    respawn_timer -= 1;
    if (respawn_timer <= 0) {
        y = original_y;
        visible = true;
        platform_active = true;
        is_falling = false;
        is_triggered = false;
        fall_speed = 0;
    }
}
