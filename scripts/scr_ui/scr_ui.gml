/// @description UI Helper System
///
/// Provides constants, enums, utility functions, and reusable drawing helpers
/// for the entire UI layer. All UI objects reference these rather than
/// hardcoding values.
///
/// GUI is locked at 320×180 (matching game resolution).
/// All positions are relative to this coordinate space.
/// ============================================================================

// UI state machine — controls which overlay is showing
enum UI_STATE {
    GAMEPLAY,      // HUD visible, game running
    PAUSED,        // Pause menu open, game frozen
    VICTORY,       // Victory screen
    DEFEAT,        // Defeat screen
    COUNT
}

/// @function ui_ensure_gui_size()
/// @description Re-apply 320×180 GUI space (camera/surface changes can desync it).
function ui_ensure_gui_size() {
    display_set_gui_size(320, 180);
}

/// @function ui_role_bar_layout()
function ui_role_bar_layout() {
    return {
        bar_x: 4,
        bar_y: 2,
        btn_w: 36,
        btn_h: 12,
        btn_gap: 2
    };
}

/// @function ui_role_at_gui_point(_mx, _my)
function ui_role_at_gui_point(_mx, _my) {
    var _l = ui_role_bar_layout();
    for (var _role = ROLE.GEO; _role <= ROLE.AERO; ++_role) {
        var _index = _role - ROLE.GEO;
        var _bx = _l.bar_x + (_index * (_l.btn_w + _l.btn_gap));
        if (point_in_rectangle(_mx, _my, _bx, _l.bar_y, _bx + _l.btn_w, _l.bar_y + _l.btn_h)) {
            return _role;
        }
    }
    return ROLE.NONE;
}

/// @function ui_cancel_role_assignment(_controller)
function ui_cancel_role_assignment(_controller) {
    if (!instance_exists(_controller)) return;
    _controller.selected_role = ROLE.NONE;
    global.paused = false;
}

/// @function ui_start_level()
function ui_start_level() {
    global.level_started = true;
    global.paused = false;
}

// Role display names
function ui_get_role_name(_role) {
    switch (_role) {
        case ROLE.GEO:  return "GEO";
        case ROLE.CRYO: return "CRYO";
        case ROLE.AEGI: return "AEGI";
        case ROLE.AERO: return "AERO";
        default:        return "???";
    }
}

// Role colors
function ui_get_role_colour(_role) {
    switch (_role) {
        case ROLE.GEO:  return make_colour_rgb(126, 190, 72);
        case ROLE.CRYO: return make_colour_rgb(92, 220, 255);
        case ROLE.AEGI: return make_colour_rgb(205, 112, 255);
        case ROLE.AERO: return make_colour_rgb(255, 224, 92);
        default:        return c_white;
    }
}

/// @function ui_draw_button(_x, _y, _w, _h, _text, _hover, _colour)
/// @description Draws a simple button box. Returns true if clicked this frame.
function ui_draw_button(_x, _y, _w, _h, _text, _hover, _colour) {
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _is_hover = point_in_rectangle(_mx, _my, _x, _y, _x + _w, _y + _h);
    
    // Background
    draw_set_colour(_is_hover ? make_colour_rgb(60, 60, 80) : make_colour_rgb(30, 30, 50));
    draw_rectangle(_x, _y, _x + _w, _y + _h, false);
    
    // Border
    draw_set_colour(_is_hover ? c_white : _colour);
    draw_rectangle(_x, _y, _x + _w, _y + _h, true);
    
    // Label
    draw_set_colour(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_x + _w * 0.5, _y + _h * 0.5, _text);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    return _is_hover && mouse_check_button_pressed(mb_left);
}

/// @function ui_draw_panel(_x, _y, _w, _h, _alpha)
/// @description Draws a dark semi-transparent panel backdrop.
function ui_draw_panel(_x, _y, _w, _h, _alpha) {
    draw_set_alpha(_alpha);
    draw_set_colour(make_colour_rgb(12, 12, 24));
    draw_rectangle(_x, _y, _x + _w, _y + _h, false);
    draw_set_alpha(1);
    draw_set_colour(make_colour_rgb(80, 80, 120));
    draw_rectangle(_x, _y, _x + _w, _y + _h, true);
}
