if (state == AP_STATE.EXITED) exit;

var _body_colour = c_white;
switch (role) {
    case ROLE.GEO:  _body_colour = make_colour_rgb(126, 190, 72); break;
    case ROLE.CRYO: _body_colour = make_colour_rgb(92, 220, 255); break;
    case ROLE.AEGI: _body_colour = make_colour_rgb(205, 112, 255); break;
    case ROLE.AERO: _body_colour = make_colour_rgb(255, 224, 92); break;
}
if (state == AP_STATE.DEAD) _body_colour = make_colour_rgb(224, 64, 72);

var _flip = (move_sign < 0) ? -1 : 1;
draw_set_colour(make_colour_rgb(25, 22, 38));
draw_rectangle(x + 3, y + 5, x + 12, y + 15, false);
draw_set_colour(_body_colour);
draw_rectangle(x + 4, y + 6, x + 11, y + 14, false);
draw_triangle(x + 2, y + 6, x + 13, y + 6, x + 8, y, false);
draw_set_colour(make_colour_rgb(25, 22, 38));
draw_rectangle(x + 7 + (_flip * 2), y + 8, x + 8 + (_flip * 2), y + 9, false);

if (state == AP_STATE.CASTING) {
    draw_set_alpha(0.8);
    draw_set_colour(_body_colour);
    draw_circle(x + 8, y + 8, 11 + ((cast_timer div 4) mod 2), true);
    draw_set_alpha(1);
}
if (state == AP_STATE.DEAD) {
    draw_set_colour(c_white);
    draw_line(x + 3, y + 3, x + 13, y + 13);
    draw_line(x + 13, y + 3, x + 3, y + 13);
}

draw_set_colour(c_white);
