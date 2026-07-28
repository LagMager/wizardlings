/// @description Draw gap
if (is_neutralized) exit;

// Dark void
draw_set_colour(make_colour_rgb(12, 10, 22));
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);

// Depth lines
draw_set_colour(make_colour_rgb(88, 72, 120));
for (var _gx = bbox_left + 4; _gx < bbox_right; _gx += 12) {
    draw_line(_gx, bbox_top + 4, _gx + 4, bbox_top + 14);
}
draw_set_colour(c_white);
