/// @description Door — Animate open/close and register signal

// Deferred registration (signal_channel set in room Creation Code)
if (!registered && signal_channel != "") {
    signal_register(signal_channel, id, "on_signal");
    registered = true;
}

// Animate toward target state
var _target = mechanism_state ? 1.0 : 0.0;
open_progress = lerp(open_progress, _target, open_speed);

// Solid when closed (blocks apprentice collision via instance checks)
mechanism_solid = (open_progress < 0.9);
