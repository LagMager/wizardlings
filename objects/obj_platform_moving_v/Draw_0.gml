/// @description Draw vertical moving platform
draw_set_colour(make_colour_rgb(100, 80, 60));
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
draw_set_colour(make_colour_rgb(140, 120, 90));
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_top + 2, false);
draw_set_colour(c_white);
