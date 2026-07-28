/// @description Draw door

var _visible_height = door_height * (1.0 - open_progress);
if (_visible_height <= 1) exit;

draw_set_colour(make_colour_rgb(90, 70, 50));
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_top + _visible_height, false);
draw_set_colour(make_colour_rgb(60, 45, 35));
draw_rectangle(bbox_left + 2, bbox_top + 2, bbox_right - 2, bbox_top + _visible_height - 2, false);
// Handle
draw_set_colour(make_colour_rgb(200, 180, 60));
draw_circle(bbox_left + 6, bbox_top + _visible_height * 0.5, 2, false);
draw_set_colour(c_white);
