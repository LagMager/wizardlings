var _colour = active ? make_colour_rgb(255, 220, 96) : make_colour_rgb(96, 120, 150);
draw_set_colour(_colour);
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
draw_set_colour(make_colour_rgb(220, 245, 255));
for (var _x = bbox_left + 5; _x < bbox_right; _x += 16) {
    draw_line(_x, bbox_top + 4, _x + 8, bbox_top + 4);
    draw_line(_x + 4, bbox_top + 8, _x + 12, bbox_top + 8);
}
draw_set_colour(c_white);
if (!active) draw_text(bbox_left, bbox_top + 18, "WIND");
