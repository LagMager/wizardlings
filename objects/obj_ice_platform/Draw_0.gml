var _pulse = 20 * ((timer div 8) mod 2);
draw_set_colour(make_colour_rgb(120 + _pulse, 220, 255));
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
draw_set_colour(c_white);
draw_line(bbox_left, bbox_top + 2, bbox_right, bbox_top + 2);
for (var _x = bbox_left + 8; _x < bbox_right; _x += 14) draw_line(_x, bbox_top + 4, _x - 5, bbox_bottom - 2);
