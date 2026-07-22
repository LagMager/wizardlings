var _alpha = 0.35 + (0.1 * ((current_time div 160) mod 2));
draw_set_alpha(_alpha);
draw_set_colour(make_colour_rgb(208, 128, 255));
draw_circle(x, y, radius, true);
draw_set_alpha(1);
draw_set_colour(c_white);
draw_text(x - 4, y - radius - 12, string(hits_remaining));
