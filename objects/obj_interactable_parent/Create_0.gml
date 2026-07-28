/// @description Interactable Parent — Base Initialization
///
/// PURPOSE: Root parent for buttons, levers, pressure plates, switches.
/// RESPONSIBILITY: Defines the activate() interface and signal emission.
/// PARENT: obj_environment_parent
///
/// PUBLIC VARIABLES:
///   signal_channel    : string — Channel name to emit signals on when activated.
///   interactable_active: bool  — Whether this interactable can currently be used.
///   requires_capability: real  — CAP flag required to interact (CAP.NONE = anyone).
///   is_triggered      : bool   — Current triggered state.
///
/// PUBLIC METHODS (override in children):
///   activate(_instigator)  — Called when something interacts with this object.
///   deactivate()           — Called when the interactable resets (if applicable).
///
/// INTERACTION FLOW:
///   1. Apprentice touches obj_interactable_parent.
///   2. System checks requires_capability against apprentice's capabilities.
///   3. If capable → calls interactable.activate(apprentice).
///   4. Interactable emits signal_emit(signal_channel, true).
///   5. Any mechanism listening on that channel reacts.
///
/// WHY THIS DESIGN:
///   Interactables and mechanisms are completely decoupled.
///   A button doesn't need a reference to its door — they share a channel name.
///   Adding a new interactable = new child with its own activate() behavior.

signal_channel = "";
interactable_active = true;
requires_capability = CAP.NONE;
is_triggered = false;

/// Method: activate — Override in children for specific behavior.
activate = function(_instigator) {
    if (!interactable_active) return;
    is_triggered = true;
    if (signal_channel != "") {
        signal_emit(signal_channel, true);
    }
};

/// Method: deactivate — Override for resettable interactables.
deactivate = function() {
    is_triggered = false;
    if (signal_channel != "") {
        signal_emit(signal_channel, false);
    }
};
