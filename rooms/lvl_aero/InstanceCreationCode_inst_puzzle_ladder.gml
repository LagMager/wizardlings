/// Collapsed until puzzle button (inst_6CE00C84) is pressed; then extends down
ladder_extend_channel = "aero_ladder_puzzle";
ladder_scale_y_start = 2;
ladder_scale_y_end = 12;
ladder_extend_speed = 0.06;
image_yscale = ladder_scale_y_start;
signal_register(ladder_extend_channel, id, "on_signal");
ladder_signal_registered = true;
