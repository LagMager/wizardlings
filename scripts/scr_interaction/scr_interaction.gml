/// @description Interaction System
///
/// Provides helper functions for the apprentice to interact with environment objects
/// using the parent-based polymorphic hierarchy. The apprentice doesn't need to know
/// what specific hazard, platform, or interactable it's touching — it just interacts
/// with the parent type.
///
/// ============================================================================

/// @function interaction_check_hazard(_apprentice)
/// @description Check if an apprentice is touching any hazard parent.
///              The hazard's affect() method determines what happens.
///              Returns the hazard instance or noone.
/// @param {Id.Instance} _apprentice
/// @returns {Id.Instance}
function interaction_check_hazard(_apprentice) {
    return collision_rectangle(
        _apprentice.bbox_left,
        _apprentice.bbox_top,
        _apprentice.bbox_right,
        _apprentice.bbox_bottom,
        obj_hazard_parent,
        false,
        true
    );
}


/// @function interaction_check_hazard_ahead(_apprentice, _distance)
/// @description Check for hazards ahead of the apprentice within a detection range.
///              Used for pre-emptive casting (Geo/Cryo detect hazards before touching).
/// @param {Id.Instance} _apprentice
/// @param {real} _distance  Detection range in pixels.
/// @returns {Id.Instance}
function interaction_check_hazard_ahead(_apprentice, _distance) {
    var _left, _right;
    if (_apprentice.move_sign > 0) {
        _left = _apprentice.bbox_right + 1;
        _right = _left + _distance;
    } else {
        _right = _apprentice.bbox_left - 1;
        _left = _right - _distance;
    }
    return collision_rectangle(
        _left,
        _apprentice.bbox_top - 8,
        _right,
        _apprentice.bbox_bottom + 64,
        obj_hazard_parent,
        false,
        true
    );
}


/// @function interaction_check_interactable(_apprentice)
/// @description Check if an apprentice is touching any interactable.
///              Used for buttons, levers, pressure plates.
/// @param {Id.Instance} _apprentice
/// @returns {Id.Instance}
function interaction_check_interactable(_apprentice) {
    return collision_rectangle(
        _apprentice.bbox_left,
        _apprentice.bbox_top,
        _apprentice.bbox_right,
        _apprentice.bbox_bottom,
        obj_interactable_parent,
        false,
        true
    );
}


/// @function interaction_check_platform_below(_apprentice)
/// @description Check if an apprentice is standing on a platform parent object.
///              Used for platform carrying logic.
/// @param {Id.Instance} _apprentice
/// @returns {Id.Instance}
function interaction_check_platform_below(_apprentice) {
    return collision_rectangle(
        _apprentice.bbox_left,
        _apprentice.bbox_bottom,
        _apprentice.bbox_right,
        _apprentice.bbox_bottom + 2,
        obj_platform_parent,
        false,
        true
    );
}


/// @function interaction_check_exit(_apprentice)
/// @description Returns the obj_exit instance the apprentice is overlapping, or noone.
function interaction_check_exit(_apprentice) {
    return core_exit_touching(_apprentice);
}


/// @function interaction_check_mechanism(_apprentice)
/// @description Check if an apprentice is touching any mechanism (doors, bridges, etc).
/// @param {Id.Instance} _apprentice
/// @returns {Id.Instance}
function interaction_check_mechanism(_apprentice) {
    return collision_rectangle(
        _apprentice.bbox_left,
        _apprentice.bbox_top,
        _apprentice.bbox_right,
        _apprentice.bbox_bottom,
        obj_mechanism_parent,
        false,
        true
    );
}
