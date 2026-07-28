/// @description Mechanism Parent — Base Initialization
///
/// PURPOSE: Root parent for doors, bridges, elevators, gates, moving walls.
/// RESPONSIBILITY: Listens for signals and reacts by changing state.
/// PARENT: obj_environment_parent
///
/// PUBLIC VARIABLES:
///   signal_channel   : string — Channel this mechanism listens on.
///   mechanism_state  : bool   — Current state (true = open/active, false = closed/inactive).
///   mechanism_solid  : bool   — Whether this mechanism blocks movement when closed.
///
/// PUBLIC METHODS (override in children):
///   on_signal(_value) — Called when the signal channel emits. Children override for
///                       specific open/close/toggle behavior.
///
/// INTERACTION FLOW:
///   1. An interactable emits signal_emit("door_A", true).
///   2. This mechanism registered on "door_A" receives on_signal(true).
///   3. Mechanism changes state (opens, moves, toggles, etc).
///
/// WHY THIS DESIGN:
///   Mechanisms react to signals — they don't poll or hold references to triggers.
///   A door doesn't know if it's opened by a button, lever, or pressure plate.
///   Adding a new mechanism = new child with its own on_signal() behavior.

signal_channel = "";
mechanism_state = false;
mechanism_solid = true;

/// Method: on_signal — Called by the signal system when the channel emits.
on_signal = function(_value) {
    mechanism_state = _value;
};

// Register with signal system if a channel is assigned.
// Children should call this in their Create after setting signal_channel.
// (Cannot auto-register here because signal_channel hasn't been set by child yet)
