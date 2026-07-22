enum AP_STATE {
    WALKING,
    CASTING,
    DEAD,
    EXITED,
    COUNT
}

enum ROLE {
    NONE,
    GEO,
    CRYO,
    AEGI,
    AERO,
    COUNT
}

enum HAZARD_TYPE {
    GAP,
    SPIKES,
    LIQUID,
    FIRE,
    HAZARD_TERRAIN,
    COUNT
}

enum LEVEL_STATE {
    PLAYING,
    WON,
    LOST,
    COUNT
}

enum CAST_ACTION {
    NONE,
    TERRAIN,
    ICE,
    WIND,
    COUNT
}

function core_default_config() {
    return {
        tile_size: 8,
        move_speed: 1.25,
        gravity: 0.35,
        max_fall_speed: 7,
        cast_duration: 30,
        detection_distance: 112,
        wind_detection_distance: 128,
        terrain_height: 16,
        ice_lifetime: 360,
        barrier_radius: 40,
        barrier_hits: 2,
        wind_speed: 1,
        cull_margin: 48,
        debug_validation_period: 300
    };
}

function core_controller() {
    if (instance_exists(obj_game_controller)) {
        return instance_find(obj_game_controller, 0);
    }
    return noone;
}

function core_debug_check(_name, _condition) {
    var _status = _condition ? "PASS" : "FAIL";
    show_debug_message("[CHECK][" + _status + "] " + _name);
    return _condition;
}

function core_tile_is_solid(_tilemap, _x, _y) {
    if (_tilemap == -1) return false;
    var _data = tilemap_get_at_pixel(_tilemap, _x, _y);
    return (_data != 0) && (_data != -1);
}

function core_rect_hits_tilemap(_left, _top, _right, _bottom) {
    if (!variable_global_exists("collision_tilemap")) return false;
    var _tilemap = global.collision_tilemap;
    if (_tilemap == -1) return false;

    var _step = global.core_config.tile_size;
    for (var _x = _left; _x <= _right; _x += _step) {
        if (core_tile_is_solid(_tilemap, _x, _top)) return true;
        if (core_tile_is_solid(_tilemap, _x, _bottom)) return true;
    }
    for (var _y = _top; _y <= _bottom; _y += _step) {
        if (core_tile_is_solid(_tilemap, _left, _y)) return true;
        if (core_tile_is_solid(_tilemap, _right, _y)) return true;
    }

    if (core_tile_is_solid(_tilemap, _right, _top)) return true;
    if (core_tile_is_solid(_tilemap, _right, _bottom)) return true;
    if (core_tile_is_solid(_tilemap, _left, _bottom)) return true;
    return false;
}

function core_rect_hits_instances(_left, _top, _right, _bottom) {
    if (collision_rectangle(_left, _top, _right, _bottom, obj_terrain_block, false, true) != noone) return true;
    if (collision_rectangle(_left, _top, _right, _bottom, obj_ice_platform, false, true) != noone) return true;

    var _wind = collision_rectangle(_left, _top, _right, _bottom, obj_wind_object, false, true);
    if ((_wind != noone) && _wind.solid_enabled) return true;
    return false;
}

function core_rect_is_solid(_left, _top, _right, _bottom) {
    return core_rect_hits_tilemap(_left, _top, _right, _bottom)
        || core_rect_hits_instances(_left, _top, _right, _bottom);
}

function core_apprentice_collides(_apprentice, _dx, _dy) {
    var _left = _apprentice.bbox_left + _dx;
    var _top = _apprentice.bbox_top + _dy;
    var _right = _apprentice.bbox_right + _dx - 1;
    var _bottom = _apprentice.bbox_bottom + _dy - 1;

    if (core_rect_hits_tilemap(_left, _top, _right, _bottom)) return true;

    // Instance masks use rectangle overlap semantics: anticipate support while
    // falling, but ignore the one-pixel support seam during horizontal motion.
    var _instance_bottom = _bottom;
    if (_dy > 0) _instance_bottom += 1;
    if (_dx != 0) _instance_bottom -= 1;
    return core_rect_hits_instances(_left, _top, _right, _instance_bottom);
}

function core_hazard_is_lethal(_hazard) {
    if (!instance_exists(_hazard)) return false;
    return _hazard.active
        && (_hazard.neutralizer_count <= 0)
        && !_hazard.geo_resolved
        && !_hazard.wind_resolved;
}

function core_role_counters_hazard(_role, _hazard_type) {
    switch (_role) {
        case ROLE.GEO:
            return (_hazard_type == HAZARD_TYPE.GAP) || (_hazard_type == HAZARD_TYPE.SPIKES);
        case ROLE.CRYO:
            return (_hazard_type == HAZARD_TYPE.LIQUID)
                || (_hazard_type == HAZARD_TYPE.FIRE)
                || (_hazard_type == HAZARD_TYPE.HAZARD_TERRAIN);
        case ROLE.AEGI:
            return (_hazard_type != HAZARD_TYPE.GAP);
    }
    return false;
}

function core_hazard_ahead(_apprentice, _distance) {
    var _left;
    var _right;
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
        obj_hazard,
        false,
        true
    );
}

function core_wind_ahead(_apprentice, _distance) {
    var _left;
    var _right;
    if (_apprentice.move_sign > 0) {
        _left = _apprentice.bbox_right + 1;
        _right = _left + _distance;
    } else {
        _right = _apprentice.bbox_left - 1;
        _left = _right - _distance;
    }
    return collision_rectangle(
        _left,
        _apprentice.bbox_top - 24,
        _right,
        _apprentice.bbox_bottom + 72,
        obj_wind_object,
        false,
        true
    );
}

function core_hazard_touching(_apprentice) {
    return collision_rectangle(
        _apprentice.bbox_left,
        _apprentice.bbox_top,
        _apprentice.bbox_right,
        _apprentice.bbox_bottom,
        obj_hazard,
        false,
        true
    );
}

function core_exit_touching(_apprentice) {
    return collision_rectangle(
        _apprentice.bbox_left,
        _apprentice.bbox_top,
        _apprentice.bbox_right,
        _apprentice.bbox_bottom,
        obj_exit,
        false,
        true
    );
}

function core_begin_cast(_apprentice, _target, _action) {
    if (!instance_exists(_apprentice)) return false;
    if ((_apprentice.state == AP_STATE.DEAD) || (_apprentice.state == AP_STATE.EXITED)) return false;
    if (_apprentice.state == AP_STATE.CASTING) return false;

    _apprentice.state = AP_STATE.CASTING;
    _apprentice.cast_target = _target;
    _apprentice.cast_action = _action;
    _apprentice.cast_timer = global.core_config.cast_duration;
    _apprentice.h_remainder = 0;

    if ((_action == CAST_ACTION.WIND) && instance_exists(_target)) {
        _target.activation_started = true;
    }
    return true;
}

function core_finish_cast(_apprentice) {
    if (!instance_exists(_apprentice)) return;
    var _target = _apprentice.cast_target;
    var _action = _apprentice.cast_action;

    if (instance_exists(_target)) {
        switch (_action) {
            case CAST_ACTION.TERRAIN:
                if (!_target.geo_resolved) {
                    _target.geo_resolved = true;
                    var _terrain_width = _target.bbox_right - _target.bbox_left + 1;
                    instance_create_layer(
                        _target.bbox_left,
                        _target.surface_y,
                        "instances_environment",
                        obj_terrain_block,
                        {
                            block_width: _terrain_width,
                            block_height: global.core_config.terrain_height,
                            source_hazard: _target
                        }
                    );
                }
                break;

            case CAST_ACTION.ICE:
                if ((_target.cryo_effect == noone) || !instance_exists(_target.cryo_effect)) {
                    _target.cryo_pending = true;
                    var _ice_width = _target.bbox_right - _target.bbox_left + 1;
                    instance_create_layer(
                        _target.bbox_left,
                        _target.surface_y,
                        "instances_environment",
                        obj_ice_platform,
                        {
                            platform_width: _ice_width,
                            platform_height: global.core_config.terrain_height,
                            source_hazard: _target,
                            lifetime: global.core_config.ice_lifetime
                        }
                    );
                }
                break;

            case CAST_ACTION.WIND:
                _target.active = true;
                break;
        }
    }

    _apprentice.cast_target = noone;
    _apprentice.cast_action = CAST_ACTION.NONE;
    _apprentice.cast_timer = 0;
    if ((_apprentice.state != AP_STATE.DEAD) && (_apprentice.state != AP_STATE.EXITED)) {
        _apprentice.state = AP_STATE.WALKING;
    }
}

function core_notify_terminal(_apprentice, _new_state) {
    if (!instance_exists(_apprentice)) return false;
    if ((_apprentice.state == AP_STATE.DEAD) || (_apprentice.state == AP_STATE.EXITED)) return false;

    if ((_apprentice.cast_action == CAST_ACTION.WIND) && instance_exists(_apprentice.cast_target)) {
        if (!_apprentice.cast_target.active) _apprentice.cast_target.activation_started = false;
    }

    _apprentice.state = _new_state;
    _apprentice.v_speed = 0;
    _apprentice.h_remainder = 0;
    _apprentice.v_remainder = 0;
    _apprentice.terminal_reported = true;

    var _controller = core_controller();
    if (instance_exists(_controller)) {
        _controller.apprentices_alive = max(0, _controller.apprentices_alive - 1);
        if (_new_state == AP_STATE.EXITED) {
            _controller.apprentices_exited += 1;
        } else {
            _controller.apprentices_dead += 1;
        }
    }

    if (_new_state == AP_STATE.EXITED) {
        _apprentice.visible = false;
    } else {
        _apprentice.image_blend = c_red;
    }
    return true;
}

function core_try_absorb_hazard(_apprentice, _hazard) {
    if (!instance_exists(_hazard)) return false;
    if (_hazard.hazard_type == HAZARD_TYPE.GAP) return false;

    var _cx = (_apprentice.bbox_left + _apprentice.bbox_right) * 0.5;
    var _cy = (_apprentice.bbox_top + _apprentice.bbox_bottom) * 0.5;
    var _count = instance_number(obj_barrier_zone);
    for (var _i = 0; _i < _count; ++_i) {
        var _barrier = instance_find(obj_barrier_zone, _i);
        if (instance_exists(_barrier) && (_barrier.hits_remaining > 0)) {
            if (point_distance(_cx, _cy, _barrier.x, _barrier.y) <= _barrier.radius) {
                _barrier.hits_remaining -= 1;
                show_debug_message("[BARRIER] Hit absorbed; remaining=" + string(_barrier.hits_remaining));
                if (_barrier.hits_remaining <= 0) {
                    _barrier.broken = true;
                    instance_destroy(_barrier);
                }
                return true;
            }
        }
    }
    return false;
}

function core_resolve_hazard_contact(_apprentice) {
    var _hazard = core_hazard_touching(_apprentice);
    if (_hazard == noone) {
        _apprentice.contact_hazard = noone;
        return;
    }
    if (!core_hazard_is_lethal(_hazard)) return;
    if (_hazard == _apprentice.contact_hazard) return;

    _apprentice.contact_hazard = _hazard;
    if (core_try_absorb_hazard(_apprentice, _hazard)) return;

    core_notify_terminal(_apprentice, AP_STATE.DEAD);
}

function core_assign_role(_controller, _apprentice, _role) {
    if (!instance_exists(_controller) || !instance_exists(_apprentice)) return false;
    if (_controller.level_state != LEVEL_STATE.PLAYING) return false;
    if (!global.paused) return false;
    if ((_role <= ROLE.NONE) || (_role >= ROLE.COUNT)) return false;
    if ((_apprentice.state == AP_STATE.DEAD) || (_apprentice.state == AP_STATE.EXITED)) return false;
    if (_apprentice.role != ROLE.NONE) return false;
    if (_controller.limited_budget && (_controller.role_budget[_role] <= 0)) return false;

    _apprentice.role = _role;
    if (_controller.limited_budget) _controller.role_budget[_role] -= 1;

    if (_role == ROLE.AEGI) {
        instance_create_layer(
            _apprentice.x + 8,
            _apprentice.y + 8,
            "instances_environment",
            obj_barrier_zone,
            { owner: _apprentice }
        );
    }

    _controller.selected_role = ROLE.NONE;
    global.paused = false;
    show_debug_message("[ROLE] Assigned role=" + string(_role) + " to apprentice=" + string(_apprentice.id));
    return true;
}

function core_setup_collision_tilemap() {
    var _config = global.core_config;
    var _layer = layer_get_id("tiles_collision");
    if (_layer == -1) _layer = layer_create(500, "tiles_collision");

    var _columns = ceil(room_width / _config.tile_size);
    var _rows = ceil(room_height / _config.tile_size);
    var _tilemap = layer_tilemap_create(_layer, 0, 0, ts_collision, _columns, _rows);
    layer_set_visible(_layer, false);

    var _segments = [
        [8, 208],
        [256, 704],
        [816, room_width - 8]
    ];

    for (var _s = 0; _s < array_length(_segments); ++_s) {
        var _start_cell = floor(_segments[_s][0] / _config.tile_size);
        var _end_cell = ceil(_segments[_s][1] / _config.tile_size) - 1;
        for (var _tx = _start_cell; _tx <= _end_cell; ++_tx) {
            for (var _ty = floor(440 / _config.tile_size); _ty < _rows; ++_ty) {
                tilemap_set(_tilemap, 1, _tx, _ty);
            }
        }
    }

    for (var _wall_y = 0; _wall_y < _rows; ++_wall_y) {
        tilemap_set(_tilemap, 1, 0, _wall_y);
        tilemap_set(_tilemap, 1, _columns - 1, _wall_y);
    }

    global.collision_tilemap = _tilemap;
    return _tilemap;
}

function core_run_boot_checks() {
    show_debug_message("[CHECK] Wizardlings core boot checks");
    core_debug_check("collision tilemap cached", global.collision_tilemap != -1);
    core_debug_check("empty tile reports zero", tilemap_get_at_pixel(global.collision_tilemap, 80, 120) == 0);
    var _solid = tilemap_get_at_pixel(global.collision_tilemap, 80, 448);
    core_debug_check("solid tile reports data", (_solid != 0) && (_solid != -1));
    core_debug_check("invalid tilemap handle rejected", !core_tile_is_solid(-1, 80, 448));
    core_debug_check("state enum contract", (AP_STATE.WALKING == 0) && (AP_STATE.COUNT == 4));
    core_debug_check("exactly four assignable roles", (ROLE.COUNT - 1) == 4);
    core_debug_check("five hazard categories", HAZARD_TYPE.COUNT == 5);
    core_debug_check("movement config valid", (global.core_config.move_speed > 0) && (global.core_config.gravity > 0));
    core_debug_check("temporary ice duration valid", global.core_config.ice_lifetime > 0);
    core_debug_check("barrier contract is two hits", global.core_config.barrier_hits == 2);
}

function core_validate_runtime(_controller) {
    var _terminal_total = _controller.apprentices_alive
        + _controller.apprentices_exited
        + _controller.apprentices_dead;
    core_debug_check("apprentice counters remain conserved", _terminal_total == _controller.apprentice_count);

    var _barrier_count = instance_number(obj_barrier_zone);
    for (var _i = 0; _i < _barrier_count; ++_i) {
        var _barrier = instance_find(obj_barrier_zone, _i);
        core_debug_check(
            "barrier charges remain bounded",
            (_barrier.hits_remaining > 0) && (_barrier.hits_remaining <= global.core_config.barrier_hits)
        );
    }

    var _ice_count = instance_number(obj_ice_platform);
    for (var _j = 0; _j < _ice_count; ++_j) {
        var _ice = instance_find(obj_ice_platform, _j);
        core_debug_check("ice platform retains a live hazard owner", instance_exists(_ice.source_hazard));
    }
}
