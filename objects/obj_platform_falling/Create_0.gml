/// @description Falling Platform
///
/// PURPOSE: A platform that falls after an apprentice stands on it briefly.
/// PARENT: obj_platform_parent

event_inherited();

fall_delay = 30;         // Frames before falling after contact
fall_timer = 0;          // Current timer
fall_speed = 0;          // Current fall velocity
fall_gravity = 0.3;      // Acceleration downward
is_falling = false;      // Has the platform started falling?
is_triggered = false;    // Has something stood on it?
respawn_time = 180;      // Frames until respawn (0 = never)
respawn_timer = 0;
original_y = y;
