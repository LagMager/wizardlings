/// @description Draw spikes
if (is_neutralized) exit;

draw_set_colour(make_colour_rgb(208, 214, 224));
draw_rectangle(bbox_left, bbox_top + 12, bbox_right, bbox_bottom, false);
for (var _sx = bbox_left; _sx < bbox_right; _sx += 8) {
    draw_triangle(_sx, bbox_top + 12, _sx + 4, bbox_top, _sx + 8, bbox_top + 12, false);
}
draw_set_colour(c_white);
