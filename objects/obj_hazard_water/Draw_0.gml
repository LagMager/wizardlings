/// @description Draw water
if (is_neutralized) exit;

draw_set_colour(make_colour_rgb(52, 116, 220));
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
draw_set_colour(make_colour_rgb(96, 190, 255));
for (var _lx = bbox_left; _lx < bbox_right; _lx += 12) {
    draw_line(_lx, bbox_top + 3, _lx + 7, bbox_top + 3);
}
draw_set_colour(c_white);
