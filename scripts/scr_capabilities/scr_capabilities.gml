/// @description Capability System
///
/// Instead of checking role types directly (if role == ROLE.GEO), environment
/// objects query capabilities. This decouples hazards/interactables from specific
/// roles and makes adding new wizard types trivial.
///
/// Usage:
///   - Call capability_init(_role) in obj_apprentice when a role is assigned.
///   - Environment objects call capability_has(_apprentice, CAP.FREEZE_WATER)
///     instead of checking role == ROLE.CRYO.
///
/// To add a new role:
///   1. Add the role to the ROLE enum in scr_core.
///   2. Add a case to capability_init() mapping the new role to its capabilities.
///   3. Environment objects automatically support the new role if they check
///      capabilities rather than role identity.
///
/// ============================================================================

/// Capability flags — each represents something an apprentice CAN DO.
/// Use bitwise OR to combine, bitwise AND to check.
enum CAP {
    NONE            = 0,
    BUILD_BRIDGE    = 1 << 0,   // Can create solid terrain over gaps/spikes
    FREEZE_WATER    = 1 << 1,   // Can freeze liquid hazards
    EXTINGUISH_FIRE = 1 << 2,   // Can neutralize fire/flame hazards
    SOLIDIFY_TERRAIN= 1 << 3,   // Can solidify hazardous terrain
    PROJECT_BARRIER = 1 << 4,   // Projects a protective barrier around self
    CONTROL_WIND    = 1 << 5,   // Can activate wind-based mechanisms
    FIREPROOF       = 1 << 6,   // Immune to fire damage
    VOIDWALK        = 1 << 7,   // Can cross void/gaps without terrain
    USE_SWITCH      = 1 << 8,   // Can interact with switches/buttons/levers
    RIDE_PLATFORM   = 1 << 9,   // Can ride moving platforms (all have this by default)
    PUSH_OBJECTS    = 1 << 10,  // Can push moveable objects via wind
}


/// @function capability_init(_role)
/// @description Returns the capability bitmask for a given role.
///              Called when assigning a role to populate the apprentice's capabilities.
/// @param {real} _role  The ROLE enum value being assigned.
/// @returns {real}  Bitmask of capabilities granted by this role.
function capability_init(_role) {
    var _caps = CAP.RIDE_PLATFORM | CAP.USE_SWITCH;  // All roles can ride platforms and use switches
    
    switch (_role) {
        case ROLE.GEO:
            _caps |= CAP.BUILD_BRIDGE;
            break;
            
        case ROLE.CRYO:
            _caps |= CAP.FREEZE_WATER;
            _caps |= CAP.EXTINGUISH_FIRE;
            _caps |= CAP.SOLIDIFY_TERRAIN;
            break;
            
        case ROLE.AEGI:
            _caps |= CAP.PROJECT_BARRIER;
            break;
            
        case ROLE.AERO:
            _caps |= CAP.CONTROL_WIND;
            _caps |= CAP.PUSH_OBJECTS;
            _caps |= CAP.VOIDWALK;
            break;
            
        default:
            // ROLE.NONE — basic capabilities only
            break;
    }
    
    return _caps;
}


/// @function capability_has(_apprentice, _cap)
/// @description Checks if an apprentice has a specific capability.
///              Environment objects use this instead of checking role directly.
/// @param {Id.Instance} _apprentice  The apprentice instance to check.
/// @param {real} _cap  The CAP enum flag to test for.
/// @returns {bool}  True if the apprentice has the capability.
function capability_has(_apprentice, _cap) {
    if (!instance_exists(_apprentice)) return false;
    if (!variable_instance_exists(_apprentice, "capabilities")) return false;
    return (_apprentice.capabilities & _cap) != 0;
}


/// @function capability_has_any(_apprentice, _caps)
/// @description Checks if an apprentice has ANY of the given capabilities (OR logic).
/// @param {Id.Instance} _apprentice  The apprentice to check.
/// @param {real} _caps  Bitmask of capabilities (ORed together).
/// @returns {bool}
function capability_has_any(_apprentice, _caps) {
    if (!instance_exists(_apprentice)) return false;
    if (!variable_instance_exists(_apprentice, "capabilities")) return false;
    return (_apprentice.capabilities & _caps) != 0;
}


/// @function capability_has_all(_apprentice, _caps)
/// @description Checks if an apprentice has ALL of the given capabilities (AND logic).
/// @param {Id.Instance} _apprentice  The apprentice to check.
/// @param {real} _caps  Bitmask of capabilities (ORed together).
/// @returns {bool}
function capability_has_all(_apprentice, _caps) {
    if (!instance_exists(_apprentice)) return false;
    if (!variable_instance_exists(_apprentice, "capabilities")) return false;
    return (_apprentice.capabilities & _caps) == _caps;
}
