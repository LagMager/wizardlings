var _left = bbox_left;
var _top = bbox_top;
var _right = bbox_right;
var _bottom = bbox_bottom;
var _colour = make_colour_rgb(210, 56, 72);

switch (hazard_type) {
    case HAZARD_TYPE.GAP:
        _colour = make_colour_rgb(12, 10, 22);
        draw_set_colour(_colour);
        draw_rectangle(_left, _top, _right, _bottom, false);
        draw_set_colour(make_colour_rgb(88, 72, 120));
        for (var _gx = _left + 4; _gx < _right; _gx += 12) draw_line(_gx, _top + 4, _gx + 4, _top + 14);
        break;

    case HAZARD_TYPE.SPIKES:
        draw_set_colour(make_colour_rgb(208, 214, 224));
        draw_rectangle(_left, _top + 12, _right, _bottom, false);
        for (var _sx = _left; _sx < _right; _sx += 8) {
            draw_triangle(_sx, _top + 12, _sx + 4, _top, _sx + 8, _top + 12, false);
        }
        break;

    case HAZARD_TYPE.LIQUID:
        draw_set_colour(make_colour_rgb(52, 116, 220));
        draw_rectangle(_left, _top, _right, _bottom, false);
        draw_set_colour(make_colour_rgb(96, 190, 255));
        for (var _lx = _left; _lx < _right; _lx += 12) draw_line(_lx, _top + 3, _lx + 7, _top + 3);
        break;

    case HAZARD_TYPE.FIRE:
        draw_set_colour(make_colour_rgb(220, 58, 38));
        draw_rectangle(_left, _top + 10, _right, _bottom, false);
        draw_set_colour(make_colour_rgb(255, 190, 48));
        for (var _fx = _left; _fx < _right; _fx += 10) {
            draw_triangle(_fx, _top + 12, _fx + 5, _top, _fx + 10, _top + 12, false);
        }
        break;

    case HAZARD_TYPE.HAZARD_TERRAIN:
        draw_set_colour(make_colour_rgb(130, 66, 152));
        draw_rectangle(_left, _top, _right, _bottom, false);
        draw_set_colour(make_colour_rgb(230, 94, 190));
        for (var _tx = _left + 3; _tx < _right; _tx += 12) draw_circle(_tx, _top + 6, 2, false);
        break;
}

if ((neutralizer_count > 0) || geo_resolved || wind_resolved) {
    draw_set_alpha(0.35);
    draw_set_colour(c_white);
    draw_rectangle(_left, _top, _right, _bottom, true);
    draw_set_alpha(1);
}
draw_set_colour(c_white);
