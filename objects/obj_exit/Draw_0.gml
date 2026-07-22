draw_set_colour(make_colour_rgb(44, 36, 70));
draw_rectangle(bbox_left, bbox_top + 8, bbox_right, bbox_bottom, false);
draw_set_colour(make_colour_rgb(88, 238, 170));
draw_rectangle(bbox_left + 5, bbox_top + 8, bbox_right - 5, bbox_bottom, false);
draw_circle((bbox_left + bbox_right) * 0.5, bbox_top + 8, (bbox_right - bbox_left) * 0.5, false);
draw_set_colour(c_white);
draw_text(bbox_left - 2, bbox_top - 14, "EXIT");
