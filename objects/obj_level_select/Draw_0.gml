/// @description Level Select drawing — matches in-game UI palette (scr_ui / obj_ui_controller)

draw_set_font(Font1);

var _bg = make_colour_rgb(16, 16, 28);
var _panel = make_colour_rgb(18, 18, 32);
var _border = make_colour_rgb(80, 80, 120);
var _border_hi = make_colour_rgb(92, 220, 255);
var _cell = make_colour_rgb(30, 30, 50);
var _cell_hi = make_colour_rgb(44, 44, 68);
var _locked = make_colour_rgb(22, 22, 36);
var _text = make_colour_rgb(200, 200, 255);
var _text_dim = make_colour_rgb(120, 120, 140);
var _text_muted = make_colour_rgb(88, 88, 108);

// Full-screen backdrop (room bg is similar; this keeps edges consistent when letterboxed)
draw_set_colour(_bg);
draw_rectangle(0, 0, 320, 180, false);

// Main panel
draw_set_alpha(0.94);
draw_set_colour(_panel);
draw_rectangle(20, 10, 300, 158, false);
draw_set_alpha(1);
draw_set_colour(_border);
draw_rectangle(20, 10, 300, 158, true);

// Title
draw_set_colour(_text);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text(160, 14, "LEVELS");

// Level grid
for (var _i = 0; _i < total_levels; _i++) {
    var _col = _i mod grid_cols;
    var _row = _i div grid_cols;
    var _cx = grid_start_x + _col * cell_w;
    var _cy = grid_start_y + _row * cell_h;

    var _btn_x1 = _cx + 2;
    var _btn_y1 = _cy + 1;
    var _btn_x2 = _cx + cell_w - 6;
    var _btn_y2 = _cy + cell_h - 3;

    var _has_level = (_i < array_length(level_rooms));
    var _unlocked = _has_level && (_i < levels_unlocked);
    var _selected = (!back_selected && cursor_index == _i);

    draw_set_colour(_unlocked ? (_selected ? _cell_hi : _cell) : _locked);
    draw_rectangle(_btn_x1, _btn_y1, _btn_x2, _btn_y2, false);

    if (_selected) {
        draw_set_colour(_border_hi);
    } else {
        draw_set_colour(_unlocked ? _border : make_colour_rgb(50, 50, 70));
    }
    draw_rectangle(_btn_x1, _btn_y1, _btn_x2, _btn_y2, true);

    var _mid_x = (_btn_x1 + _btn_x2) * 0.5;
    var _mid_y = (_btn_y1 + _btn_y2) * 0.5;
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    if (_unlocked) {
        draw_set_colour(_selected ? c_white : _text);
        draw_text(_mid_x, _mid_y, string(_i + 1));
    } else {
        draw_set_colour(_text_dim);
        draw_rectangle(_mid_x - 3, _mid_y, _mid_x + 3, _mid_y + 3, false);
        draw_rectangle(_mid_x - 2, _mid_y - 3, _mid_x + 2, _mid_y - 1, true);
    }
}

// Back
var _back_x = 120;
var _back_y = 164;
var _back_w = 80;
var _back_h = 12;

draw_set_colour(back_selected ? _cell_hi : _cell);
draw_rectangle(_back_x, _back_y, _back_x + _back_w, _back_y + _back_h, false);
draw_set_colour(back_selected ? _border_hi : _border);
draw_rectangle(_back_x, _back_y, _back_x + _back_w, _back_y + _back_h, true);

draw_set_colour(back_selected ? c_white : _text_dim);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(_back_x + _back_w * 0.5, _back_y + _back_h * 0.5, "BACK");

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);
draw_set_alpha(1);
