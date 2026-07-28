/// @description Apprentice sprite animation & drawing
///
/// Frame layout per 16-frame block:
///   +0       Idle
///   +1..+8   Walk (8 frames, looping)
///   +9       Exit
///   +10      Death
///   +11      Cast A (60% chance)
///   +12      Cast B (40% chance)
///   +13..+15 Empty / Aegi shield

if (!visible) exit;

// --- Determine variant offset based on role ---
var _offset = 64;  // Default (ROLE.NONE)
switch (role) {
    case ROLE.GEO:  _offset = 0;  break;
    case ROLE.CRYO: _offset = 16; break;
    case ROLE.AEGI: _offset = 32; break;
    case ROLE.AERO: _offset = 48; break;
}

// --- Determine which frame to show based on state ---
var _frame = 0;

switch (state) {
    case AP_STATE.WALKING:
        // Animate walk: cycle through frames +1 to +8
        anim_frame += anim_speed;
        if (anim_frame >= 8) anim_frame -= 8;
        _frame = _offset + 1 + floor(anim_frame);
        break;
        
    case AP_STATE.CASTING:
        // Show cast frame (A or B, chosen at cast start)
        _frame = _offset + anim_cast_frame;
        break;
        
    case AP_STATE.DEAD:
        _frame = _offset + 10;
        break;
        
    case AP_STATE.EXITED:
        _frame = _offset + 9;
        break;
}

// --- Flip based on move direction ---
var _scaleX = (move_sign < 0) ? -1 : 1;

// --- Draw the sprite ---
draw_sprite_ext(
    sprite_index,
    _frame,
    x, y,
    _scaleX, 1,
    0,
    c_white,
    1
);
