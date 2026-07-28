/// @description Draw terrain block using position + dimensions directly

var _left = x;
var _top = y;
var _right = x + block_width - 1;
var _bottom = y + block_height - 1;

// Main fill
draw_set_colour(make_colour_rgb(92, 148, 72));
draw_rectangle(_left, _top, _right, _bottom, false);

// Top highlight
draw_set_colour(make_colour_rgb(154, 210, 92));
draw_rectangle(_left, _top, _right, _top + 2, false);

// Texture lines
draw_set_colour(make_colour_rgb(54, 88, 58));
for (var _bx = _left + 8; _bx < _right; _bx += 12) {
    draw_line(_bx, _top + 3, _bx - 2, _bottom);
}
draw_set_colour(c_white);
