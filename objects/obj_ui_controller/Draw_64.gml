/// @description UI Controller — Draw GUI
///
/// All UI rendering happens here. GUI coords are 320×180.
/// The UI only READS game state — never modifies it.

ui_ensure_gui_size();
draw_set_font(Font1);
draw_set_alpha(1);

var _controller = core_controller();
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

// ============================================================================
// LEVEL PREVIEW — click to begin spawning / movement
// ============================================================================
if (!global.level_started) {
    draw_set_alpha(0.35);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_gui_w * 0.5, _gui_h * 0.5 - 6, "CLICK TO START");
    draw_set_colour(make_colour_rgb(180, 180, 200));
    draw_set_valign(fa_top);
    draw_text(_gui_w * 0.5, _gui_h * 0.5 + 6, "Pan: WASD · Zoom: wheel");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    exit;
}

// ============================================================================
// HUD (always visible during gameplay and pause)
// ============================================================================
if (ui_state == UI_STATE.GAMEPLAY || ui_state == UI_STATE.PAUSED) {
    
    var _bar = ui_role_bar_layout();
    var _bar_x = _bar.bar_x;
    var _bar_y = _bar.bar_y;
    var _btn_w = _bar.btn_w;
    var _btn_h = _bar.btn_h;
    var _btn_gap = _bar.btn_gap;
    
    // --- Top bar background ---
    draw_set_alpha(0.85);
    draw_set_colour(make_colour_rgb(18, 18, 32));
    draw_rectangle(0, 0, _gui_w, 14, false);
    draw_set_alpha(1);
    
    // --- Role buttons ---
    for (var _role = ROLE.GEO; _role <= ROLE.AERO; ++_role) {
        var _index = _role - ROLE.GEO;
        var _bx = _bar_x + (_index * (_btn_w + _btn_gap));
        var _enabled = roles_enabled[_role];
        var _role_colour = _enabled ? ui_get_role_colour(_role) : make_colour_rgb(60, 60, 60);
        
        var _selected = (instance_exists(_controller) && _controller.selected_role == _role);
        
        // Button fill
        draw_set_colour(_selected ? _role_colour : make_colour_rgb(30, 30, 50));
        draw_rectangle(_bx, _bar_y, _bx + _btn_w, _bar_y + _btn_h, false);
        
        // Button border
        draw_set_colour(_role_colour);
        draw_rectangle(_bx, _bar_y, _bx + _btn_w, _bar_y + _btn_h, true);
        
        // Label
        draw_set_colour(_selected ? make_colour_rgb(18, 18, 32) : _role_colour);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        var _label = ui_get_role_name(_role);
        draw_text(_bx + _btn_w * 0.5, _bar_y + _btn_h * 0.5, _label);
        
        // Budget indicator (if limited)
        if (instance_exists(_controller) && _controller.limited_budget) {
            draw_set_colour(c_white);
            draw_set_halign(fa_right);
            draw_set_valign(fa_top);
            draw_text(_bx + _btn_w - 1, _bar_y, string(_controller.role_budget[_role]));
        }
    }
    
    // --- Status info (right side) ---
    draw_set_halign(fa_right);
    draw_set_valign(fa_middle);
    draw_set_colour(c_white);
    
    if (instance_exists(_controller)) {
        var _status = string(_controller.apprentices_alive) + " alive  " 
                    + string(_controller.apprentices_exited) + "/" + string(_controller.win_threshold) + " saved";
        draw_text(_gui_w - 4, 7, _status);
    }
    
    // --- Tooltip for selected role ---
    if (instance_exists(_controller) && _controller.selected_role != ROLE.NONE) {
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_colour(ui_get_role_colour(_controller.selected_role));
        draw_text(4, 16, ui_get_role_tooltip(_controller.selected_role));
    }
    
    // --- Role assignment hint ---
    if (instance_exists(_controller) && global.paused && ui_state == UI_STATE.GAMEPLAY
        && (_controller.selected_role != ROLE.NONE)) {
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_set_colour(make_colour_rgb(200, 200, 255));
        draw_text(_gui_w * 0.5, 16, "Click apprentice · Esc or click void to cancel");
    }
    
    // --- Tutorial hint ---
    if (show_hint && tutorial_hint != "") {
        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);
        draw_set_colour(make_colour_rgb(200, 200, 255));
        draw_text(_gui_w * 0.5, _gui_h - 4, tutorial_hint);
    }
}

// ============================================================================
// PAUSE MENU
// ============================================================================
if (ui_state == UI_STATE.PAUSED) {
    // Dim background
    draw_set_alpha(0.7);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1);
    
    // Panel
    var _panel_w = 120;
    var _panel_h = 70;
    var _panel_x = (_gui_w - _panel_w) * 0.5;
    var _panel_y = (_gui_h - _panel_h) * 0.5;
    ui_draw_panel(_panel_x, _panel_y, _panel_w, _panel_h, 0.95);
    
    // Title
    draw_set_colour(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text(_gui_w * 0.5, _panel_y + 4, "PAUSED");
    
    // Menu options
    var _opt_start_y = _panel_y + 18;
    var _opt_spacing = 12;
    
    for (var _i = 0; _i < array_length(pause_options); _i++) {
        var _opt_y = _opt_start_y + (_i * _opt_spacing);
        var _is_selected = (pause_cursor == _i);
        
        draw_set_colour(_is_selected ? make_colour_rgb(92, 220, 255) : make_colour_rgb(160, 160, 180));
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        
        var _prefix = _is_selected ? "> " : "  ";
        draw_text(_gui_w * 0.5, _opt_y, _prefix + pause_options[_i]);
    }
    
    // Mouse support for pause menu
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    for (var _i = 0; _i < array_length(pause_options); _i++) {
        var _opt_y = _opt_start_y + (_i * _opt_spacing);
        if (point_in_rectangle(_mx, _my, _panel_x, _opt_y, _panel_x + _panel_w, _opt_y + _opt_spacing)) {
            pause_cursor = _i;
            if (mouse_check_button_pressed(mb_left)) {
                switch (_i) {
                    case 0: ui_state = UI_STATE.GAMEPLAY; global.paused = false; break;
                    case 1: room_restart(); break;
                    case 2: room_goto(rm_level_select); break;
                    case 3: room_goto(rm_main_menu); break;
                }
            }
        }
    }
}

// ============================================================================
// VICTORY SCREEN
// ============================================================================
if (ui_state == UI_STATE.VICTORY) {
    // Dim
    draw_set_alpha(0.75);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1);
    
    // Panel
    var _panel_w = 160;
    var _panel_h = 90;
    var _panel_x = (_gui_w - _panel_w) * 0.5;
    var _panel_y = (_gui_h - _panel_h) * 0.5;
    ui_draw_panel(_panel_x, _panel_y, _panel_w, _panel_h, 0.95);
    
    // Title
    draw_set_colour(make_colour_rgb(88, 238, 170));
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text(_gui_w * 0.5, _panel_y + 6, "LEVEL COMPLETE!");
    
    // Stats
    draw_set_colour(c_white);
    if (instance_exists(_controller)) {
        draw_text(_gui_w * 0.5, _panel_y + 22, "Apprentices Saved: " + string(_controller.apprentices_exited) + "/" + string(_controller.win_threshold));
    }
    
    var _seconds = level_time div 60;
    var _minutes = _seconds div 60;
    _seconds = _seconds mod 60;
    draw_text(_gui_w * 0.5, _panel_y + 34, "Time: " + string(_minutes) + ":" + ((_seconds < 10) ? "0" : "") + string(_seconds));
    
    // Options
    draw_set_colour(make_colour_rgb(160, 160, 180));
    draw_text(_gui_w * 0.5, _panel_y + 52, "ENTER: Next Level");
    draw_text(_gui_w * 0.5, _panel_y + 64, "R: Restart   ESC: Level Select");
}

// ============================================================================
// DEFEAT SCREEN
// ============================================================================
if (ui_state == UI_STATE.DEFEAT) {
    // Dim
    draw_set_alpha(0.75);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1);
    
    // Panel
    var _panel_w = 140;
    var _panel_h = 60;
    var _panel_x = (_gui_w - _panel_w) * 0.5;
    var _panel_y = (_gui_h - _panel_h) * 0.5;
    ui_draw_panel(_panel_x, _panel_y, _panel_w, _panel_h, 0.95);
    
    // Title
    draw_set_colour(make_colour_rgb(238, 78, 88));
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text(_gui_w * 0.5, _panel_y + 6, "LEVEL FAILED");
    
    // Options
    draw_set_colour(make_colour_rgb(160, 160, 180));
    draw_text(_gui_w * 0.5, _panel_y + 28, "ENTER/R: Restart");
    draw_text(_gui_w * 0.5, _panel_y + 40, "ESC: Level Select");
}

// Reset draw state
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);
draw_set_alpha(1);
