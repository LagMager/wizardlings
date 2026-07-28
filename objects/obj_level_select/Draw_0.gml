/// @description Level Select drawing

// Background panel
draw_set_color(make_color_rgb(245, 235, 210));
draw_roundrect(28, 12, 292, 176, false);
draw_set_color(make_color_rgb(180, 150, 80));
draw_roundrect(28, 12, 292, 176, true);

// Title
draw_set_color(c_black);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text(160, 14, "LEVEL SELECT");

// Draw grid
for (var _i = 0; _i < total_levels; _i++) {
    var _col = _i mod grid_cols;
    var _row = _i div grid_cols;
    var _cx = grid_start_x + _col * cell_w;
    var _cy = grid_start_y + _row * cell_h;
    
    var _btn_x1 = _cx + 2;
    var _btn_y1 = _cy + 1;
    var _btn_x2 = _cx + cell_w - 6;
    var _btn_y2 = _cy + cell_h - 3;
    
    // Button background
    if (_i < levels_unlocked) {
        // Unlocked — light button
        draw_set_color(make_color_rgb(240, 235, 220));
    } else {
        // Locked — dark golden
        draw_set_color(make_color_rgb(160, 140, 60));
    }
    draw_roundrect(_btn_x1, _btn_y1, _btn_x2, _btn_y2, false);
    
    // Border (highlight if selected)
    if (!back_selected && cursor_index == _i) {
        draw_set_color(c_white);
    } else {
        draw_set_color(make_color_rgb(120, 100, 40));
    }
    draw_roundrect(_btn_x1, _btn_y1, _btn_x2, _btn_y2, true);
    
    // Content
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var _mid_x = (_btn_x1 + _btn_x2) * 0.5;
    var _mid_y = (_btn_y1 + _btn_y2) * 0.5;
    
    if (_i < levels_unlocked) {
        // Show level number
        draw_set_color(c_black);
        draw_text(_mid_x, _mid_y, string(_i + 1));
    } else {
        // Draw lock icon (simple representation)
        draw_set_color(c_white);
        // Lock body
        draw_roundrect(_mid_x - 4, _mid_y - 1, _mid_x + 4, _mid_y + 4, false);
        // Lock shackle
        draw_set_color(c_white);
        draw_roundrect(_mid_x - 3, _mid_y - 4, _mid_x + 3, _mid_y, true);
    }
}

// Back button
var _back_x = 120;
var _back_y = 166;
var _back_w = 80;
var _back_h = 12;

draw_set_color(make_color_rgb(240, 235, 220));
draw_roundrect(_back_x, _back_y, _back_x + _back_w, _back_y + _back_h, false);

if (back_selected) {
    draw_set_color(c_white);
} else {
    draw_set_color(make_color_rgb(120, 100, 40));
}
draw_roundrect(_back_x, _back_y, _back_x + _back_w, _back_y + _back_h, true);

draw_set_color(c_black);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(_back_x + _back_w * 0.5, _back_y + _back_h * 0.5, "BACK");

// Reset draw state
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
