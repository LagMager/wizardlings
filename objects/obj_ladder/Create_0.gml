/// @description Ladder — apprentices climb to reach higher ground.
///
/// Scale Y sets climb height (top origin — grows downward).
/// Optional extend puzzle (Instance Creation Code):
///   ladder_extend_channel  — signal from obj_interactable_button
///   ladder_scale_y_start   — collapsed height (scaleY)
///   ladder_scale_y_end     — extended height (scaleY)
///   ladder_extend_speed    — 0–1 lerp per frame (default 0.06)

image_speed = 0;
if (!variable_global_exists("core_config")) {
    global.core_config = core_default_config();
}
if (!variable_instance_exists(id, "climb_speed")) {
    climb_speed = global.core_config.ladder_climb_speed;
}

ladder_extend_channel = "";
ladder_scale_y_start = image_yscale;
ladder_scale_y_end = 16;
ladder_extend_speed = 0.06;
ladder_extend_active = false;
ladder_extend_t = 0;
ladder_signal_registered = false;

on_signal = function(_value) {
    if (_value) ladder_extend_active = true;
};
