/// Collapsed until inst_B661969 is pressed; then extends downward
ladder_extend_channel = "lvl_01_ladder_puzzle";
ladder_scale_y_start = 2;
ladder_scale_y_end = 7;
ladder_extend_speed = 0.06;
image_yscale = ladder_scale_y_start;
signal_register(ladder_extend_channel, id, "on_signal");
ladder_signal_registered = true;
