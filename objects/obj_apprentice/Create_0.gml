state = AP_STATE.WALKING;
role = ROLE.NONE;
capabilities = CAP.RIDE_PLATFORM | CAP.USE_SWITCH;  // Base capabilities for all apprentices
move_sign = 1;
facing = 1;
move_speed = global.core_config.move_speed;
v_speed = 0;
h_remainder = 0;
v_remainder = 0;
cast_timer = 0;
cast_target = noone;
cast_action = CAST_ACTION.NONE;
contact_hazard = noone;
terminal_reported = false;

jump_start_x = 0;
jump_start_y = 0;
jump_land_x = 0;
jump_land_y = 0;
jump_t = 0;
jump_duration = 0;
jump_peak = 0;
jump_gap = noone;
gap_jump_target = noone;
climb_ladder = noone;
climb_dir = 1;

// --- Sprite Animation System ---
// Frame layout: each role variant occupies 16 frames.
// Within a block: +0 idle, +1..+8 walk, +9 exit, +10 death, +11 cast A, +12 cast B, +13..+15 empty/shield
//
// Variant offsets (first frame of each block):
//   GEO = 0, CRYO = 16, AEGI = 32, AERO = 48, NONE = 64

sprite_index = spr_apprentice;
// spr_apprentice: origin (7, 15) = feet center; instance x/y is where the feet stand.
image_speed = 0;  // We control frames manually
image_xscale = 1;
image_yscale = 1;

// Animation state
anim_frame = 0;        // Current fractional frame accumulator
anim_speed = 0.15;     // Frames per game-frame (walk speed). Adjust to taste.
anim_cast_frame = 11;  // Which cast frame is active (11 = A, 12 = B)

// Death bounce (Mario-style)
death_bounce_active = false;
death_bounce_vy = -3.5;  // Initial upward velocity on death
death_bounce_gravity = 0.2;
death_timer = 0;

