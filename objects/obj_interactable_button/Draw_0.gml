/// @description Draw button
var _color = is_triggered ? make_colour_rgb(60, 200, 80) : make_colour_rgb(200, 60, 60);
draw_set_colour(_color);
draw_rectangle(bbox_left, bbox_top + 4, bbox_right, bbox_bottom, false);
draw_set_colour(make_colour_rgb(80, 80, 80));
draw_rectangle(bbox_left - 2, bbox_top + (is_triggered ? 6 : 0), bbox_right + 2, bbox_top + 4, false);
draw_set_colour(c_white);
