/// @description Signal listen + animate scaleY downward (top-anchored sprite)

if (ladder_extend_channel != "" && !ladder_signal_registered) {
    signal_register(ladder_extend_channel, id, "on_signal");
    ladder_signal_registered = true;
}

if (!ladder_extend_active) exit;

ladder_extend_t = min(1, ladder_extend_t + ladder_extend_speed);
image_yscale = lerp(ladder_scale_y_start, ladder_scale_y_end, ladder_extend_t);

if (ladder_extend_t >= 1) {
    image_yscale = ladder_scale_y_end;
}
