/// @description Level Select input

var _prev_index = cursor_index;
var _prev_back = back_selected;

// Navigation
if (keyboard_check_pressed(vk_right)) {
    if (!back_selected) cursor_index = min(cursor_index + 1, total_levels - 1);
}
if (keyboard_check_pressed(vk_left)) {
    if (!back_selected) cursor_index = max(cursor_index - 1, 0);
}
if (keyboard_check_pressed(vk_down)) {
    if (!back_selected) {
        if (cursor_index + grid_cols >= total_levels) {
            back_selected = true;
        } else {
            cursor_index = min(cursor_index + grid_cols, total_levels - 1);
        }
    }
}
if (keyboard_check_pressed(vk_up)) {
    if (back_selected) {
        back_selected = false;
    } else {
        cursor_index = max(cursor_index - grid_cols, 0);
    }
}

// Mouse support
if (mouse_check_button_pressed(mb_left)) {
    // Check grid cells
    for (var _i = 0; _i < total_levels; _i++) {
        var _col = _i mod grid_cols;
        var _row = _i div grid_cols;
        var _cx = grid_start_x + _col * cell_w;
        var _cy = grid_start_y + _row * cell_h;
        
        if (point_in_rectangle(mouse_x, mouse_y, _cx, _cy, _cx + cell_w - 4, _cy + cell_h - 2)) {
            cursor_index = _i;
            back_selected = false;
            // Treat as confirm
            if (_i < levels_unlocked) {
                if (_i < array_length(level_rooms)) {
                    room_goto(level_rooms[_i]);
                }
            }
            break;
        }
    }
    
    // Check back button
    var _back_x = 120;
    var _back_y = 166;
    var _back_w = 80;
    var _back_h = 12;
    if (point_in_rectangle(mouse_x, mouse_y, _back_x, _back_y, _back_x + _back_w, _back_y + _back_h)) {
        room_goto(rm_main_menu);
    }
}

// Confirm
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    if (back_selected) {
        room_goto(rm_main_menu);
    } else if (cursor_index < levels_unlocked) {
        if (cursor_index < array_length(level_rooms)) {
            room_goto(level_rooms[cursor_index]);
        }
    }
}

// Escape goes back
if (keyboard_check_pressed(vk_escape)) {
    room_goto(rm_main_menu);
}
