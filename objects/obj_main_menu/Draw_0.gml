/// @description Main Menu drawing

draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Title
draw_text(160, 60, title_text);

// Blinking prompt
if (blink_visible) {
    draw_set_color(c_ltgray);
    draw_text(160, 120, prompt_text);
}

// Reset draw state
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
