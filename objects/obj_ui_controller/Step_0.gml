/// @description UI Controller — Input & State Management

ui_ensure_gui_size();

var _controller = core_controller();
if (!instance_exists(_controller)) exit;

// --- Level preview: frozen until player starts (camera still works) ---
if (!global.level_started) {
    if (mouse_check_button_pressed(mb_left)
        || keyboard_check_pressed(vk_space)
        || keyboard_check_pressed(vk_enter)) {
        ui_start_level();
    }
    exit;
}

// --- Track level time while playing ---
if (ui_state == UI_STATE.GAMEPLAY && !global.paused) {
    level_time += 1;
}

// --- Detect game state changes from the controller ---
if (_controller.level_state == LEVEL_STATE.WON && ui_state != UI_STATE.VICTORY) {
    ui_state = UI_STATE.VICTORY;
}
if (_controller.level_state == LEVEL_STATE.LOST && ui_state != UI_STATE.DEFEAT) {
    ui_state = UI_STATE.DEFEAT;
}

// --- Input handling per UI state ---
switch (ui_state) {
    case UI_STATE.GAMEPLAY:
        // Cancel role pick before opening pause menu
        if (global.paused && (_controller.selected_role != ROLE.NONE)) {
            if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(mb_right)) {
                ui_cancel_role_assignment(_controller);
                exit;
            }
        }

        // Pause toggle (not while picking a role — Esc cancels pick instead)
        if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("P"))) {
            if (global.paused && (_controller.selected_role != ROLE.NONE)) {
                ui_cancel_role_assignment(_controller);
                exit;
            }
            ui_state = UI_STATE.PAUSED;
            global.paused = true;
            pause_cursor = 0;
            exit;
        }
        
        // Role selection (keyboard shortcuts)
        var _chosen = ROLE.NONE;
        if (keyboard_check_pressed(ord("1")) && roles_enabled[ROLE.GEO])  _chosen = ROLE.GEO;
        if (keyboard_check_pressed(ord("2")) && roles_enabled[ROLE.CRYO]) _chosen = ROLE.CRYO;
        if (keyboard_check_pressed(ord("3")) && roles_enabled[ROLE.AEGI]) _chosen = ROLE.AEGI;
        if (keyboard_check_pressed(ord("4")) && roles_enabled[ROLE.AERO]) _chosen = ROLE.AERO;
        
        // Role selection (mouse click on role bar)
        if (mouse_check_button_pressed(mb_left)) {
            var _mx = device_mouse_x_to_gui(0);
            var _my = device_mouse_y_to_gui(0);
            _chosen = ui_role_at_gui_point(_mx, _my);
        }
        
        if (_chosen != ROLE.NONE) {
            if (!_controller.limited_budget || (_controller.role_budget[_chosen] > 0)) {
                _controller.selected_role = _chosen;
                global.paused = true;
            }
        }
        
        // Click apprentice to assign (while paused with role selected)
        if (global.paused && (_controller.selected_role != ROLE.NONE) && mouse_check_button_pressed(mb_left)) {
            var _target = instance_position(mouse_x, mouse_y, obj_apprentice);
            if (_target != noone) {
                core_assign_role(_controller, _target, _controller.selected_role);
            } else {
                var _mx = device_mouse_x_to_gui(0);
                var _my = device_mouse_y_to_gui(0);
                if (ui_role_at_gui_point(_mx, _my) == ROLE.NONE) {
                    ui_cancel_role_assignment(_controller);
                }
            }
        }
        break;
        
    case UI_STATE.PAUSED:
        // Navigate pause menu
        if (keyboard_check_pressed(vk_down)) pause_cursor = (pause_cursor + 1) mod array_length(pause_options);
        if (keyboard_check_pressed(vk_up))   pause_cursor = (pause_cursor - 1 + array_length(pause_options)) mod array_length(pause_options);
        
        // Confirm
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
            switch (pause_cursor) {
                case 0: // Resume
                    ui_state = UI_STATE.GAMEPLAY;
                    global.paused = false;
                    break;
                case 1: // Restart
                    room_restart();
                    break;
                case 2: // Level Select
                    room_goto(rm_level_select);
                    break;
                case 3: // Main Menu
                    room_goto(rm_main_menu);
                    break;
            }
            exit;
        }
        
        // Escape unpauses
        if (keyboard_check_pressed(vk_escape)) {
            ui_state = UI_STATE.GAMEPLAY;
            global.paused = false;
        }
        break;
        
    case UI_STATE.VICTORY:
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
            room_goto_next();
        }
        if (keyboard_check_pressed(ord("R"))) {
            room_restart();
        }
        if (keyboard_check_pressed(vk_escape)) {
            room_goto(rm_level_select);
        }
        break;
        
    case UI_STATE.DEFEAT:
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("R"))) {
            room_restart();
        }
        if (keyboard_check_pressed(vk_escape)) {
            room_goto(rm_level_select);
        }
        break;
}
