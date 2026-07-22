draw_set_colour(make_colour_rgb(92, 148, 72));
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
draw_set_colour(make_colour_rgb(154, 210, 92));
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_top + 3, false);
draw_set_colour(make_colour_rgb(54, 88, 58));
for (var _x = bbox_left + 8; _x < bbox_right; _x += 12) draw_line(_x, bbox_top + 5, _x - 4, bbox_bottom);
draw_set_colour(c_white);
