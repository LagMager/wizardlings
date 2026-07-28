/// @description Movement System
///
/// Reusable movement functions for entities that walk, fall, and collide.
/// Separates movement logic from the apprentice's Step event for clarity.
/// These functions work with tilemaps AND instance-based collisions.
///
/// ============================================================================

/// @function movement_apply_horizontal(_entity, _speed, _direction)
/// @description Move an entity horizontally with sub-pixel accumulation and collision.
///              Bounces off walls (reverses direction).
/// @param {Id.Instance} _entity     Entity with h_remainder, move_sign variables.
/// @param {real} _speed             Speed in pixels per frame.
/// @param {real} _direction         1 or -1.
/// @returns {bool}  True if the entity hit a wall and reversed.
function movement_apply_horizontal(_entity, _speed, _direction) {
    _entity.h_remainder += _speed * _direction;
    var _pixels = floor(abs(_entity.h_remainder));
    var _hit_wall = false;
    
    if (_pixels > 0) {
        _entity.h_remainder -= _pixels * sign(_entity.h_remainder);
        repeat (_pixels) {
            if (core_apprentice_collides(_entity, _direction, 0)) {
                _entity.move_sign *= -1;
                _entity.h_remainder = 0;
                _hit_wall = true;
                break;
            }
            _entity.x += _direction;
        }
    }
    
    return _hit_wall;
}


/// @function movement_apply_gravity(_entity)
/// @description Apply gravity and vertical movement with sub-pixel accumulation.
///              Uses global.core_config for gravity and max_fall_speed.
/// @param {Id.Instance} _entity  Entity with v_speed, v_remainder variables.
/// @returns {bool}  True if the entity landed on something.
function movement_apply_gravity(_entity) {
    _entity.v_speed = min(
        _entity.v_speed + global.core_config.gravity,
        global.core_config.max_fall_speed
    );
    
    _entity.v_remainder += _entity.v_speed;
    var _pixels = floor(abs(_entity.v_remainder));
    var _landed = false;
    
    if (_pixels > 0) {
        var _sign = sign(_entity.v_remainder);
        _entity.v_remainder -= _pixels * _sign;
        repeat (_pixels) {
            if (core_apprentice_collides(_entity, 0, _sign)) {
                _entity.v_speed = 0;
                _entity.v_remainder = 0;
                _landed = (_sign > 0);  // Only "landed" if moving downward
                break;
            }
            _entity.y += _sign;
        }
    }
    
    return _landed;
}


/// @function movement_is_on_ground(_entity)
/// @description Check if an entity is standing on solid ground (tilemap or instance).
/// @param {Id.Instance} _entity
/// @returns {bool}
function movement_is_on_ground(_entity) {
    return core_apprentice_collides(_entity, 0, 1);
}


/// @function movement_check_fall_death(_entity, _margin)
/// @description Check if an entity has fallen below the room + margin (void death).
/// @param {Id.Instance} _entity
/// @param {real} _margin  Extra pixels below room_height before triggering death.
/// @returns {bool}
function movement_check_fall_death(_entity, _margin) {
    return (_entity.y > room_height + _margin);
}


/// @function platform_carry_passengers(_platform, _dx, _dy)
/// @description Move all apprentices standing on top of a platform by the given delta.
///              Call this AFTER moving the platform itself.
///              Platforms use this to carry passengers without apprentices needing
///              to know what type of platform they're on.
/// @param {Id.Instance} _platform  The platform that moved.
/// @param {real} _dx               Horizontal distance the platform moved this frame.
/// @param {real} _dy               Vertical distance the platform moved this frame.
function platform_carry_passengers(_platform, _dx, _dy) {
    if (_dx == 0 && _dy == 0) return;
    
    var _plat_left = _platform.bbox_left;
    var _plat_right = _platform.bbox_right;
    var _plat_top = _platform.bbox_top;
    
    with (obj_apprentice) {
        if ((state == AP_STATE.DEAD) || (state == AP_STATE.EXITED)) continue;
        // Check if apprentice is standing on the platform (feet near platform top)
        if ((bbox_right >= _plat_left) && (bbox_left <= _plat_right)
            && (abs(bbox_bottom - _plat_top) <= 2)) {
            x += _dx;
            y += _dy;
        }
    }
}
