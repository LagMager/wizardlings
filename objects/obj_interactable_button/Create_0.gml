/// @description Button Interactable
///
/// PURPOSE: A one-shot button that emits a signal when an apprentice walks over it.
/// PARENT: obj_interactable_parent
///
/// BEHAVIOR:
///   - Activates once when an apprentice enters its area.
///   - Emits signal_emit(signal_channel, true) permanently.
///   - Does not reset (use pressure_plate for toggle behavior).
///
/// DESIGNER SETUP:
///   Set signal_channel in room Creation Code (e.g. signal_channel = "door_A")

event_inherited();

one_shot = true;  // Only triggers once
