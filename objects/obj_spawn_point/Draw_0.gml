/// @description Draw spawn point indicator (debug/editor visualization)

// Draw a simple marker so you can see the spawn point in-game
draw_set_color(c_lime);
draw_set_alpha(0.6);
draw_circle(x, y, 6, false);
draw_set_alpha(1.0);

// Show remaining count
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_text(x, y - 10, string(spawn_total - spawn_count));
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
