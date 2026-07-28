/// @description Door Mechanism
///
/// PURPOSE: A door that blocks passage until opened via signal.
/// PARENT: obj_mechanism_parent
///
/// BEHAVIOR:
///   - When mechanism_state == false: door is closed, blocks movement.
///   - When mechanism_state == true: door is open, apprentices can pass.
///   - Listens on signal_channel. Set it in room Creation Code.
///
/// DESIGNER SETUP:
///   signal_channel = "door_A";  // Must match a button/lever's channel

event_inherited();

door_height = 32;  // Height of the door in pixels
open_progress = 0; // 0 = closed, 1 = fully open (for animation)
open_speed = 0.05;

// Register with signal system
// Designer must set signal_channel in Creation Code before this runs,
// so we defer registration to the first Step frame.
registered = false;

/// Override: on_signal
on_signal = function(_value) {
    mechanism_state = _value;
};
