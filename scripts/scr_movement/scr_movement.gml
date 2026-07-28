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


/// @function platform_sync_size_from_room()
/// @description Apply room-editor scaleX/scaleY to platform_width/height and sprite mask.
function platform_sync_size_from_room() {
    if (sprite_index == -1) return;
    var _sw = sprite_get_width(sprite_index);
    var _sh = sprite_get_height(sprite_index);
    if (_sw <= 0 || _sh <= 0) return;

    if (!variable_instance_exists(id, "platform_width") || platform_width <= 0) {
        platform_width = _sw * abs(image_xscale);
    }
    if (!variable_instance_exists(id, "platform_height") || platform_height <= 0) {
        platform_height = _sh * abs(image_yscale);
    }
    image_xscale = platform_width / _sw;
    image_yscale = platform_height / _sh;
}


/// @function platform_apply_size(_width, _height)
function platform_apply_size(_width, _height) {
    platform_width = _width;
    platform_height = _height;
    if (sprite_index == -1) return;
    image_xscale = _width / sprite_get_width(sprite_index);
    image_yscale = _height / sprite_get_height(sprite_index);
}


/// @function platform_draw(_offset_x)
/// @description Stretch spr_platform to platform_width × platform_height (crisp pixels).
function platform_draw(_offset_x) {
    if (sprite_index == -1) return;
    if (is_undefined(_offset_x)) _offset_x = 0;

    var _w = round(platform_width);
    var _h = round(platform_height);
    if (_w <= 0) _w = round(sprite_get_width(sprite_index) * abs(image_xscale));
    if (_h <= 0) _h = round(sprite_get_height(sprite_index) * abs(image_yscale));

    draw_sprite_stretched(sprite_index, 0, x + _offset_x, y, _w, _h);
}


/// @function platform_v_finalize_config(_platform)
/// @description Apply travel range. Prefer platform_travel_px (Instance Creation Code).
function platform_v_finalize_config(_platform) {
    if (!instance_exists(_platform)) return;

    if (!variable_instance_exists(_platform, "bottom_y_anchor")) {
        _platform.bottom_y_anchor = _platform.y;
    }

    var _travel = 64;
    if (variable_instance_exists(_platform, "platform_travel_px")) {
        _travel = variable_instance_get(_platform, "platform_travel_px");
    } else if (variable_instance_exists(_platform, "move_height")) {
        _travel = variable_instance_get(_platform, "move_height");
    }

    var _speed = 0.5;
    if (variable_instance_exists(_platform, "platform_move_speed")) {
        _speed = variable_instance_get(_platform, "platform_move_speed");
    } else if (variable_instance_exists(_platform, "move_speed")) {
        _speed = variable_instance_get(_platform, "move_speed");
    }

    var _pause_sec = 3;
    if (variable_instance_exists(_platform, "platform_pause_sec")) {
        _pause_sec = variable_instance_get(_platform, "platform_pause_sec");
    } else if (variable_instance_exists(_platform, "endpoint_pause_seconds")) {
        _pause_sec = variable_instance_get(_platform, "endpoint_pause_seconds");
    }

    var _start_up = true;
    if (variable_instance_exists(_platform, "platform_starts_going_up")) {
        _start_up = variable_instance_get(_platform, "platform_starts_going_up");
    } else if (variable_instance_exists(_platform, "start_direction")) {
        _start_up = (variable_instance_get(_platform, "start_direction") < 0);
    }

    _platform.move_height = max(1, real(_travel));
    _platform.move_speed = real(_speed);
    _platform.start_direction = _start_up ? -1 : 1;
    _platform.endpoint_pause_seconds = max(0, real(_pause_sec));
    _platform.endpoint_pause_frames = round(_platform.endpoint_pause_seconds * game_get_speed(gamespeed_fps));
    _platform.move_distance = _platform.move_height;

    _platform.bottom_y = real(_platform.bottom_y_anchor);
    _platform.top_y = _platform.bottom_y - _platform.move_height;
    _platform.start_y = _platform.bottom_y;

    if (_platform.start_direction > 0) {
        _platform.y = _platform.top_y;
        _platform.move_dir = 1;
    } else {
        _platform.y = _platform.bottom_y;
        _platform.move_dir = -1;
    }

    with (_platform) {
        _layout_applied = true;
    }
}


/// @function platform_v_apply_layout(_platform)
/// @description Alias for finalize (legacy calls).
function platform_v_apply_layout(_platform) {
    platform_v_finalize_config(_platform);
}


/// @function platform_apprentice_on_top(_apprentice, _platform)
function platform_apprentice_on_top(_apprentice, _platform) {
    if (!instance_exists(_apprentice) || !instance_exists(_platform)) return false;
    if (!_platform.platform_active) return false;
    return ( _apprentice.bbox_right >= _platform.bbox_left
        && _apprentice.bbox_left <= _platform.bbox_right
        && abs(_apprentice.bbox_bottom - _platform.bbox_top) <= 2);
}


/// @function platform_apprentice_riding(_apprentice)
/// @description True while the apprentice is carried (auto-walk suppressed).
function platform_apprentice_riding(_apprentice) {
    if (!instance_exists(_apprentice)) return false;
    var _plat = collision_rectangle(
        _apprentice.bbox_left,
        _apprentice.bbox_bottom,
        _apprentice.bbox_right,
        _apprentice.bbox_bottom + 2,
        obj_platform_parent,
        false,
        true
    );
    if (_plat == noone || !_plat.platform_active) return false;

    if (variable_instance_exists(_plat, "endpoint_wait") && (_plat.endpoint_wait > 0)) {
        return false;
    }

    if (_plat.object_index == obj_platform_moving_v) {
        return platform_has_aero_onboard(_plat);
    }

    if (_plat.object_index == obj_platform_moving_h) {
        return platform_has_aero_onboard(_plat);
    }

    return false;
}


/// @function platform_has_aero_onboard(_platform)
/// @description Moving platforms only run when an Aeromancer is standing on them (if requires_aero).
function platform_has_aero_onboard(_platform) {
    if (!instance_exists(_platform) || !_platform.platform_active) return false;
    if (variable_instance_exists(_platform, "requires_aero") && !_platform.requires_aero) {
        return true;
    }

    var _left = _platform.bbox_left;
    var _right = _platform.bbox_right;
    var _top = _platform.bbox_top;
    var _found = false;

    with (obj_apprentice) {
        if (_found) continue;
        if (role != ROLE.AERO) continue;
        if ((state == AP_STATE.DEAD) || (state == AP_STATE.EXITED)) continue;
        if ((bbox_right >= _left) && (bbox_left <= _right) && (abs(bbox_bottom - _top) <= 2)) {
            _found = true;
        }
    }
    return _found;
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
