/// @description Hazard Parent — Base Initialization
///
/// PURPOSE: Root parent for all hazard objects.
/// RESPONSIBILITY: Defines the hazard interface. Children override affect().
/// PARENT: obj_environment_parent
///
/// PUBLIC VARIABLES:
///   hazard_active      : bool — Whether this hazard is currently lethal.
///   required_capability: real — CAP flag needed to counter this hazard (0 = uncounterable).
///   is_neutralized     : bool — Set to true when a capable apprentice resolves this.
///
/// PUBLIC METHODS (override in children):
///   affect(_target)           — Apply this hazard's effect to a target. Default = kill.
///   can_be_countered(_target) — Returns whether the target can counter this hazard.
///   on_neutralize(_source)    — Called when a capable entity neutralizes the hazard.
///
/// INTERACTION FLOW:
///   1. Apprentice touches obj_hazard_parent (collision check against parent).
///   2. System calls hazard.can_be_countered(apprentice) — checks capability.
///   3. If counterable → apprentice begins casting, then calls hazard.on_neutralize().
///   4. If not counterable → calls hazard.affect(apprentice) → default is death.
///
/// WHY THIS DESIGN:
///   The apprentice never checks "if hazard == spikes". It asks the hazard
///   "can I counter you?" and the hazard answers based on its own rules.
///   Adding a new hazard = new child object with its own affect() logic.

hazard_active = true;
required_capability = CAP.NONE;
is_neutralized = false;

/// Method: affect — Override in children to define what happens to the target.
affect = function(_target) {
    // Default: kill the target
    core_notify_terminal(_target, AP_STATE.DEAD);
};

/// Method: can_be_countered — Override for custom counter logic.
can_be_countered = function(_target) {
    if (required_capability == CAP.NONE) return false;
    return capability_has(_target, required_capability);
};

/// Method: on_neutralize — Override to define what happens when countered.
on_neutralize = function(_source) {
    is_neutralized = true;
    hazard_active = false;
};
