/// @description Draw falling platform
var _shake = is_triggered && !is_falling ? irandom_range(-1, 1) : 0;
draw_set_colour(make_colour_rgb(160, 80, 60));
draw_rectangle(bbox_left + _shake, bbox_top, bbox_right + _shake, bbox_bottom, false);
draw_set_colour(make_colour_rgb(200, 120, 80));
draw_rectangle(bbox_left + _shake, bbox_top, bbox_right + _shake, bbox_top + 2, false);
draw_set_colour(c_white);
