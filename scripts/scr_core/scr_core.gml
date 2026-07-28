enum AP_STATE {
    WALKING,
    CASTING,
    GAP_JUMP,
    CLIMBING,
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
        hazard_detection_distance: 48,
        wind_detection_distance: 40,
        terrain_height: 16,
        ice_lifetime: 360,
        barrier_radius: 40,
        barrier_hits: 2,
        wind_speed: 1,
        cull_margin: 48,
        gap_jump_max_width: 96,
        gap_jump_duration: 28,
        gap_jump_height: 22,
        gap_jump_edge_tolerance: 4,
        ladder_climb_speed: 1,
        debug_validation_period: 300
    };
}

function core_controller() {
    if (instance_exists(obj_game_controller)) {
        return instance_find(obj_game_controller, 0);
    }
    return noone;
}

function core_environment_layer() {
    /// Layer for spawned ice, bridges, etc. Falls back to Instances if the env layer is missing.
    if (layer_exists("instances_environment")) return "instances_environment";
    return "Instances";
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

function core_rect_hits_tilemap_horizontal(_left, _right, _foot_bottom) {
    if (!variable_global_exists("collision_tilemap")) return false;
    var _tilemap = global.collision_tilemap;
    if (_tilemap == -1) return false;

    var _step = global.core_config.tile_size;
    for (var _row = 0; _row <= 1; ++_row) {
        var _y = _foot_bottom - (_row * _step);
        if (core_tile_is_solid(_tilemap, _left, _y)) return true;
        if (core_tile_is_solid(_tilemap, _right, _y)) return true;
    }
    return false;
}

function core_apprentice_has_floor_support(_apprentice) {
    var _left = _apprentice.bbox_left;
    var _right = _apprentice.bbox_right - 1;
    var _top = _apprentice.bbox_top;
    var _bottom = _apprentice.bbox_bottom;
    var _probe_bottom = _bottom + 1;
    if (core_rect_hits_tilemap(_left, _top, _right, _probe_bottom)) return true;
    return core_rect_hits_instances(_left, _top, _right, _probe_bottom);
}

function core_is_frozen_water(_water) {
    if (!instance_exists(_water)) return false;
    if ((_water.object_index != obj_hazard_water)
        && !object_is_ancestor(_water.object_index, obj_hazard_water)) return false;
    return variable_instance_exists(_water, "is_neutralized")
        && _water.is_neutralized
        && variable_instance_exists(_water, "hazard_active")
        && !_water.hazard_active;
}

function core_frozen_water_walk_top(_water) {
    return _water.bbox_top;
}

function core_rect_hits_frozen_water(_left, _top, _right, _bottom) {
    var _count = instance_number(obj_hazard_water);
    for (var _i = 0; _i < _count; ++_i) {
        var _water = instance_find(obj_hazard_water, _i);
        if (!core_is_frozen_water(_water)) continue;

        var _strip_top = core_frozen_water_walk_top(_water);
        var _strip_bottom = _strip_top + global.core_config.terrain_height - 1;
        if ((_left <= _water.bbox_right)
            && (_right >= _water.bbox_left)
            && (_top <= _strip_bottom)
            && (_bottom >= _strip_top)) return true;
    }
    return false;
}

function core_rect_hits_ladder_tops(_left, _top, _right, _bottom) {
    var _count = instance_number(obj_ladder);
    for (var _i = 0; _i < _count; ++_i) {
        var _ladder = instance_find(obj_ladder, _i);
        var _strip_top = _ladder.bbox_top;
        var _strip_bottom = _strip_top + global.core_config.terrain_height - 1;
        if ((_left <= _ladder.bbox_right)
            && (_right >= _ladder.bbox_left)
            && (_top <= _strip_bottom)
            && (_bottom >= _strip_top)) return true;
    }
    return false;
}

function core_rect_hits_instances(_left, _top, _right, _bottom) {
    if (collision_rectangle(_left, _top, _right, _bottom, obj_terrain_block, false, true) != noone) return true;
    if (core_rect_hits_frozen_water(_left, _top, _right, _bottom)) return true;
    if (core_rect_hits_ladder_tops(_left, _top, _right, _bottom)) return true;
    if (collision_rectangle(_left, _top, _right, _bottom, obj_ice_platform, false, true) != noone) return true;

    var _wind = collision_rectangle(_left, _top, _right, _bottom, obj_wind_object, false, true);
    if ((_wind != noone) && _wind.solid_enabled) return true;

    var _plat = collision_rectangle(_left, _top, _right, _bottom, obj_platform_parent, false, true);
    if ((_plat != noone) && _plat.platform_active) return true;
    return false;
}

function core_rect_is_solid(_left, _top, _right, _bottom) {
    return core_rect_hits_tilemap(_left, _top, _right, _bottom)
        || core_rect_hits_instances(_left, _top, _right, _bottom);
}

function core_geo_build_bridge(_left, _top, _width, _source_hazard) {
    /// Geomancer bridge: visible terrain instance plus collision tile strip aligned to the walk surface.
    instance_create_layer(
        _left,
        _top,
        core_environment_layer(),
        obj_terrain_block,
        {
            block_width: _width,
            block_height: global.core_config.terrain_height,
            source_hazard: _source_hazard
        }
    );

    var _tilemap = global.collision_tilemap;
    if (_tilemap == -1) return;

    var _tile_size = global.core_config.tile_size;
    var _start_col = floor(_left / _tile_size);
    var _end_col = ceil((_left + _width) / _tile_size) - 1;
    var _row = floor(_top / _tile_size);

    var _fill_tile = tilemap_get(_tilemap, _start_col - 1, _row);
    if (_fill_tile == 0) _fill_tile = tilemap_get(_tilemap, _end_col + 1, _row);
    if (_fill_tile == 0) _fill_tile = 1;

    for (var _col = _start_col; _col <= _end_col; _col++) {
        tilemap_set(_tilemap, _fill_tile, _col, _row);
    }
}

function core_is_gap_hazard(_hazard) {
    if (!instance_exists(_hazard)) return false;
    if (_hazard.object_index == obj_hazard_gap) return true;
    if (object_is_ancestor(_hazard.object_index, obj_hazard_gap)) return true;
    if (variable_instance_exists(_hazard, "hazard_type") && (_hazard.hazard_type == HAZARD_TYPE.GAP)) return true;
    return false;
}

function core_gap_can_clear(_apprentice, _gap) {
    if (!instance_exists(_apprentice) || !instance_exists(_gap)) return false;
    if (!capability_has(_apprentice, CAP.VOIDWALK)) return false;
    if (!core_hazard_is_lethal(_gap)) return false;

    var _width = _gap.bbox_right - _gap.bbox_left + 1;
    return (_width <= global.core_config.gap_jump_max_width);
}

function core_gap_ahead_in_range(_apprentice, _gap, _distance) {
    if (!instance_exists(_gap)) return false;

    if (_apprentice.move_sign > 0) {
        var _dist = _gap.bbox_left - _apprentice.bbox_right;
        return (_dist >= 0) && (_dist <= _distance);
    }
    var _dist_left = _apprentice.bbox_left - _gap.bbox_right;
    return (_dist_left >= 0) && (_dist_left <= _distance);
}

function core_gap_at_jump_edge(_apprentice, _gap) {
    if (!instance_exists(_apprentice) || !instance_exists(_gap)) return false;

    var _edge_tol = global.core_config.gap_jump_edge_tolerance;
    var _floor_tol = 4;
    if (abs(_apprentice.bbox_bottom - _gap.bbox_top) > _floor_tol) return false;

    if (_apprentice.move_sign > 0) {
        return (_apprentice.bbox_right >= _gap.bbox_left - 1)
            && (_apprentice.bbox_right <= _gap.bbox_left + _edge_tol);
    }
    return (_apprentice.bbox_left <= _gap.bbox_right + 1)
        && (_apprentice.bbox_left >= _gap.bbox_right - _edge_tol);
}

function core_gap_jumpable(_apprentice, _gap) {
    if (_apprentice.state != AP_STATE.WALKING) return false;
    if (!core_apprentice_collides(_apprentice, 0, 1)) return false;
    if (!core_gap_can_clear(_apprentice, _gap)) return false;
    return core_gap_at_jump_edge(_apprentice, _gap);
}

function core_begin_gap_jump(_apprentice, _gap) {
    if (!core_gap_jumpable(_apprentice, _gap)) return false;

    var _foot_offset = _apprentice.bbox_bottom - _apprentice.y;
    var _origin_offset = _apprentice.x - _apprentice.bbox_left;

    _apprentice.jump_start_x = _apprentice.x;
    _apprentice.jump_start_y = _apprentice.y;
    if (_apprentice.move_sign > 0) {
        _apprentice.jump_land_x = _gap.bbox_right + 1 + _origin_offset;
    } else {
        _apprentice.jump_land_x = _gap.bbox_left - 1 - (_apprentice.bbox_right - _apprentice.x);
    }
    _apprentice.jump_land_y = _gap.bbox_top - _foot_offset;

    _apprentice.jump_t = 0;
    _apprentice.jump_duration = global.core_config.gap_jump_duration;
    _apprentice.jump_peak = global.core_config.gap_jump_height;
    _apprentice.jump_gap = _gap;
    _apprentice.state = AP_STATE.GAP_JUMP;
    _apprentice.v_speed = 0;
    _apprentice.v_remainder = 0;
    _apprentice.h_remainder = 0;
    return true;
}

function core_step_gap_jump(_apprentice) {
    if (_apprentice.state != AP_STATE.GAP_JUMP) return;

    _apprentice.jump_t += 1;
    var _duration = max(1, _apprentice.jump_duration);
    var _u = _apprentice.jump_t / _duration;

    if (_u >= 1) {
        _apprentice.x = _apprentice.jump_land_x;
        _apprentice.y = _apprentice.jump_land_y;
        _apprentice.jump_gap = noone;
        _apprentice.state = AP_STATE.WALKING;
        return;
    }

    _apprentice.x = lerp(_apprentice.jump_start_x, _apprentice.jump_land_x, _u);
    var _base_y = lerp(_apprentice.jump_start_y, _apprentice.jump_land_y, _u);
    _apprentice.y = _base_y - (_apprentice.jump_peak * sin(pi * _u));
}

function core_hazard_detection_distance(_apprentice) {
    if (instance_exists(_apprentice) && (_apprentice.role == ROLE.AERO)) {
        return global.core_config.detection_distance;
    }
    return global.core_config.hazard_detection_distance;
}

function core_apprentice_nudge_inside_room(_apprentice) {
    if (!instance_exists(_apprentice)) return;
    if (_apprentice.bbox_left < 0) _apprentice.x -= _apprentice.bbox_left;
    if (_apprentice.bbox_right >= room_width) {
        _apprentice.x += (room_width - 1) - _apprentice.bbox_right;
    }
}

function core_apprentice_bounce_horizontal(_apprentice) {
    if (!instance_exists(_apprentice)) return;
    _apprentice.move_sign *= -1;
    _apprentice.h_remainder = 0;
    _apprentice.gap_jump_target = noone;
    core_apprentice_nudge_inside_room(_apprentice);
    core_apprentice_set_facing(_apprentice, _apprentice.move_sign);
}

function core_apprentice_collides(_apprentice, _dx, _dy) {
    var _left = _apprentice.bbox_left + _dx;
    var _top = _apprentice.bbox_top + _dy;
    var _right = _apprentice.bbox_right + _dx - 1;
    var _bottom = _apprentice.bbox_bottom + _dy - 1;

    if (_dx != 0) {
        if (_left < 0 || _right >= room_width) return true;
    }

    if (_dx != 0 && _dy == 0) {
        // Horizontal: skip tile side-walls when airborne (e.g. over obj_hazard_gap void).
        if (core_apprentice_has_floor_support(_apprentice)) {
            if (core_rect_hits_tilemap_horizontal(_left, _right, _bottom)) return true;
        }
    } else if (core_rect_hits_tilemap(_left, _top, _right, _bottom)) {
        return true;
    }

    // Instance masks use rectangle overlap semantics: anticipate support while
    // falling, but ignore the one-pixel support seam during horizontal motion.
    var _instance_bottom = _bottom;
    if (_dy > 0) _instance_bottom += 1;
    if (_dx != 0) _instance_bottom -= 1;
    return core_rect_hits_instances(_left, _top, _right, _instance_bottom);
}

function core_hazard_is_lethal(_hazard) {
    if (!instance_exists(_hazard)) return false;
    
    // New typed hazards (obj_hazard_parent children) use hazard_active
    if (variable_instance_exists(_hazard, "hazard_active")) {
        return _hazard.hazard_active;
    }
    
    // Legacy obj_hazard
    return _hazard.active
        && (_hazard.neutralizer_count <= 0)
        && !_hazard.geo_resolved
        && !_hazard.wind_resolved;
}

function core_role_counters_hazard(_role, _hazard_type) {
    switch (_role) {
        case ROLE.GEO:
            return (_hazard_type == HAZARD_TYPE.GAP);
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
    
    // Check legacy obj_hazard first
    var _legacy = collision_rectangle(
        _left,
        _apprentice.bbox_top - 8,
        _right,
        _apprentice.bbox_bottom + 64,
        obj_hazard,
        false,
        true
    );
    if (_legacy != noone) return _legacy;
    
    var _hazard = collision_rectangle(
        _left,
        _apprentice.bbox_top - 8,
        _right,
        _apprentice.bbox_bottom + 64,
        obj_hazard_parent,
        false,
        true
    );
    if (_hazard == noone) return noone;

    if (core_is_gap_hazard(_hazard)
        && variable_instance_exists(_hazard, "geo_resolved") && _hazard.geo_resolved
        && (_apprentice.bbox_right >= _hazard.bbox_left)
        && (_apprentice.bbox_left <= _hazard.bbox_right)
        && core_apprentice_has_floor_support(_apprentice)) {
        return noone;
    }

    return _hazard;
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

function core_find_wind_for_gap(_gap) {
    if (!instance_exists(_gap)) return noone;
    if (variable_instance_exists(_gap, "linked_wind") && instance_exists(_gap.linked_wind)) {
        return _gap.linked_wind;
    }
    return collision_rectangle(
        _gap.bbox_left,
        _gap.bbox_top - 48,
        _gap.bbox_right,
        _gap.bbox_bottom + 64,
        obj_wind_object,
        false,
        true
    );
}

function core_wind_resolve_gap(_wind) {
    if (!instance_exists(_wind)) return;

    var _gap = noone;
    if (variable_instance_exists(_wind, "source_hazard") && instance_exists(_wind.source_hazard)) {
        _gap = _wind.source_hazard;
    }
    if (_gap == noone) {
        _gap = collision_rectangle(
            _wind.bbox_left,
            _wind.bbox_top,
            _wind.bbox_right,
            _wind.bbox_bottom + 32,
            obj_hazard,
            false,
            true
        );
    }
    if (_gap == noone) {
        _gap = collision_rectangle(
            _wind.bbox_left,
            _wind.bbox_top,
            _wind.bbox_right,
            _wind.bbox_bottom + 32,
            obj_hazard_parent,
            false,
            true
        );
    }
    if (_gap == noone) return;

    if (variable_instance_exists(_gap, "wind_resolved")) _gap.wind_resolved = true;
    if (variable_instance_exists(_gap, "hazard_type") && (_gap.hazard_type == HAZARD_TYPE.GAP)) {
        if (variable_instance_exists(_gap, "is_neutralized")) _gap.is_neutralized = true;
        if (variable_instance_exists(_gap, "hazard_active")) _gap.hazard_active = false;
    }
    if (object_is_ancestor(_gap.object_index, obj_hazard_gap) || (_gap.object_index == obj_hazard_gap)) {
        _gap.is_neutralized = true;
        _gap.hazard_active = false;
    }
}

function core_hazard_contact_top(_hazard) {
    if (!instance_exists(_hazard)) return 0;
    if ((_hazard.object_index == obj_hazard_water)
        || object_is_ancestor(_hazard.object_index, obj_hazard_water)) {
        var _offset = 0;
        if (variable_instance_exists(_hazard, "liquid_contact_top_offset")) {
            _offset = _hazard.liquid_contact_top_offset;
        } else {
            var _h = _hazard.bbox_bottom - _hazard.bbox_top + 1;
            _offset = floor(_h * 0.25);
        }
        return _hazard.bbox_top + _offset;
    }
    return _hazard.bbox_top;
}

function core_hazard_surface_y(_hazard) {
    return core_hazard_contact_top(_hazard);
}

function core_hazard_contact_overlap(_apprentice, _hazard) {
    if (!instance_exists(_apprentice) || !instance_exists(_hazard)) return false;
    var _top = core_hazard_contact_top(_hazard);
    return rectangle_in_rectangle(
        _apprentice.bbox_left,
        _apprentice.bbox_top,
        _apprentice.bbox_right,
        _apprentice.bbox_bottom,
        _hazard.bbox_left,
        _top,
        _hazard.bbox_right,
        _hazard.bbox_bottom
    );
}

function core_apprentice_standing_on_ice(_apprentice) {
    if (!instance_exists(_apprentice)) return noone;
    var _ice = collision_rectangle(
        _apprentice.bbox_left,
        _apprentice.bbox_bottom,
        _apprentice.bbox_right,
        _apprentice.bbox_bottom + 2,
        obj_ice_platform,
        false,
        true
    );
    if (_ice == noone) return noone;
    if (abs(_apprentice.bbox_bottom - _ice.bbox_top) > 3) return noone;
    return _ice;
}

function core_apprentice_standing_on_frozen_water(_apprentice) {
    if (!instance_exists(_apprentice)) return noone;

    var _count = instance_number(obj_hazard_water);
    for (var _i = 0; _i < _count; ++_i) {
        var _water = instance_find(obj_hazard_water, _i);
        if (!core_is_frozen_water(_water)) continue;

        var _top = core_frozen_water_walk_top(_water);
        if (abs(_apprentice.bbox_bottom - _top) > 3) continue;
        if (_apprentice.bbox_right < _water.bbox_left) continue;
        if (_apprentice.bbox_left > _water.bbox_right) continue;
        return _water;
    }
    return noone;
}

function core_apprentice_supported_by_hazard(_apprentice, _hazard) {
    if (!instance_exists(_apprentice) || !instance_exists(_hazard)) return false;

    var _ice = core_apprentice_standing_on_ice(_apprentice);
    if ((_ice != noone) && instance_exists(_ice.source_hazard) && (_ice.source_hazard == _hazard)) return true;

    var _water = core_apprentice_standing_on_frozen_water(_apprentice);
    return (_water == _hazard);
}

function core_apprentice_set_facing(_apprentice, _new_facing) {
    if (!instance_exists(_apprentice)) return;
    _new_facing = (_new_facing < 0) ? -1 : 1;
    if (_new_facing == _apprentice.facing) return;
    // spr_apprentice origin is feet-center (7, 15) so image_xscale flips in place.
    _apprentice.facing = _new_facing;
    _apprentice.image_xscale = _new_facing;
    _apprentice.image_yscale = 1;
}

function core_snap_apprentice_to_ladder(_apprentice, _ladder) {
    if (!instance_exists(_apprentice) || !instance_exists(_ladder)) return;
    var _center_x = (_apprentice.bbox_left + _apprentice.bbox_right + 1) * 0.5;
    var _ladder_center = (_ladder.bbox_left + _ladder.bbox_right + 1) * 0.5;
    _apprentice.x += _ladder_center - _center_x;
}

function core_apprentice_overlaps_ladder_column(_apprentice, _ladder) {
    return (_apprentice.bbox_right >= _ladder.bbox_left)
        && (_apprentice.bbox_left <= _ladder.bbox_right);
}

function core_ladder_touching(_apprentice) {
    var _count = instance_number(obj_ladder);
    for (var _i = 0; _i < _count; ++_i) {
        var _ladder = instance_find(obj_ladder, _i);
        if (!core_apprentice_overlaps_ladder_column(_apprentice, _ladder)) continue;
        if (_apprentice.bbox_top > _ladder.bbox_bottom + 2) continue;
        if (_apprentice.bbox_bottom < _ladder.bbox_top - 8) continue;
        return _ladder;
    }
    return noone;
}

function core_try_mount_ladder(_apprentice, _ladder) {
    if (!instance_exists(_apprentice) || !instance_exists(_ladder)) return false;
    if (_apprentice.state != AP_STATE.WALKING) return false;
    if (!core_apprentice_overlaps_ladder_column(_apprentice, _ladder)) return false;

    var _on_top = abs(_apprentice.bbox_bottom - _ladder.bbox_top) <= 3;
    if (_on_top) return false;

    if (!core_apprentice_collides(_apprentice, 0, 1)) return false;
    if (_apprentice.bbox_bottom <= _ladder.bbox_top + 4) return false;

    _apprentice.climb_dir = 1;
    core_snap_apprentice_to_ladder(_apprentice, _ladder);
    core_apprentice_set_facing(_apprentice, 1);
    _apprentice.state = AP_STATE.CLIMBING;
    _apprentice.climb_ladder = _ladder;
    _apprentice.v_speed = 0;
    _apprentice.v_remainder = 0;
    _apprentice.h_remainder = 0;
    return true;
}

function core_step_climb(_apprentice) {
    if (_apprentice.state != AP_STATE.CLIMBING) return;
    if (!instance_exists(_apprentice.climb_ladder)) {
        _apprentice.state = AP_STATE.WALKING;
        _apprentice.climb_ladder = noone;
        _apprentice.climb_dir = 1;
        return;
    }

    var _ladder = _apprentice.climb_ladder;
    var _speed = global.core_config.ladder_climb_speed;
    if (variable_instance_exists(_ladder, "climb_speed")) _speed = _ladder.climb_speed;

    core_snap_apprentice_to_ladder(_apprentice, _ladder);

    _apprentice.y -= _speed;

    if (_apprentice.bbox_bottom <= _ladder.bbox_top + 1) {
        var _foot = _apprentice.bbox_bottom - _apprentice.y;
        _apprentice.y = _ladder.bbox_top - _foot;
        _apprentice.state = AP_STATE.WALKING;
        _apprentice.climb_ladder = noone;
        _apprentice.climb_dir = 1;
        _apprentice.v_speed = 0;
        _apprentice.v_remainder = 0;
        core_apprentice_set_facing(_apprentice, _apprentice.move_sign);
    }
}

function core_hazard_touching(_apprentice) {
    // Check legacy hazards
    var _legacy = collision_rectangle(
        _apprentice.bbox_left,
        _apprentice.bbox_top,
        _apprentice.bbox_right,
        _apprentice.bbox_bottom,
        obj_hazard,
        false,
        true
    );
    if (_legacy != noone) return _legacy;
    
    // Check new typed hazards
    var _hazard = collision_rectangle(
        _apprentice.bbox_left,
        _apprentice.bbox_top,
        _apprentice.bbox_right,
        _apprentice.bbox_bottom,
        obj_hazard_parent,
        false,
        true
    );
    if (_hazard == noone) return noone;

    if ((_hazard.object_index == obj_hazard_water)
        || object_is_ancestor(_hazard.object_index, obj_hazard_water)) {
        if (!core_hazard_contact_overlap(_apprentice, _hazard)) return noone;
    }
    return _hazard;
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

function core_try_exit(_apprentice) {
    if (!instance_exists(_apprentice)) return false;
    if ((_apprentice.state == AP_STATE.DEAD) || (_apprentice.state == AP_STATE.EXITED)) return false;

    var _exit = core_exit_touching(_apprentice);
    if (_exit == noone) return false;

    if (core_notify_terminal(_apprentice, AP_STATE.EXITED)) {
        _exit.exit_saved_count += 1;
        show_debug_message("[EXIT] Apprentice saved (" + string(_exit.exit_saved_count) + " through this exit)");
        return true;
    }
    return false;
}

function core_begin_cast(_apprentice, _target, _action) {
    if (!instance_exists(_apprentice)) return false;
    if ((_apprentice.state == AP_STATE.DEAD) || (_apprentice.state == AP_STATE.EXITED)) return false;
    if (_apprentice.state == AP_STATE.CASTING) return false;
    if (_apprentice.state == AP_STATE.CLIMBING) return false;

    _apprentice.state = AP_STATE.CASTING;
    _apprentice.cast_target = _target;
    _apprentice.cast_action = _action;
    _apprentice.cast_timer = global.core_config.cast_duration;
    _apprentice.h_remainder = 0;
    
    // Pick cast animation frame: 60% Cast A, 40% Cast B
    _apprentice.anim_cast_frame = (random(1) < 0.4) ? 12 : 11;

    if ((_action == CAST_ACTION.WIND) && instance_exists(_target)) {
        _target.activation_started = true;
        if (_target.object_index == obj_wind_object) {
            _target.active = true;
            _target.solid_enabled = true;
        }
    }
    return true;
}

function core_finish_cast(_apprentice) {
    if (!instance_exists(_apprentice)) return;
    var _target = _apprentice.cast_target;
    var _action = _apprentice.cast_action;

    if (instance_exists(_target)) {
        if ((_action == CAST_ACTION.WIND) && (_target.object_index == obj_wind_object)) {
            _target.active = true;
            _target.solid_enabled = true;
        }
        // --- New typed hazards: call on_neutralize() directly ---
        else if (variable_instance_exists(_target, "on_neutralize") && variable_instance_exists(_target, "hazard_active")) {
            _target.on_neutralize(_apprentice);
        }
        // --- Legacy obj_hazard handling ---
        else {
            switch (_action) {
                case CAST_ACTION.TERRAIN:
                    if (!_target.geo_resolved) {
                        _target.geo_resolved = true;
                        var _terrain_width = _target.bbox_right - _target.bbox_left + 1;
                        core_geo_build_bridge(_target.bbox_left, _target.bbox_top, _terrain_width, _target);
                    }
                    break;

                case CAST_ACTION.ICE:
                    if ((_target.cryo_effect == noone) || !instance_exists(_target.cryo_effect)) {
                        _target.cryo_pending = true;
                        var _ice_width = _target.bbox_right - _target.bbox_left + 1;
                        instance_create_layer(
                            _target.bbox_left,
                            _target.surface_y,
                            core_environment_layer(),
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
        // Mario-style death bounce — pop up then fall off screen
        _apprentice.death_bounce_active = true;
        _apprentice.death_bounce_vy = -3.5;
        _apprentice.death_timer = 0;
    }
    return true;
}

function core_try_absorb_hazard(_apprentice, _hazard) {
    if (!instance_exists(_hazard)) return false;
    
    // Gaps can't be absorbed by barriers (no floor = no protection)
    if (variable_instance_exists(_hazard, "hazard_type") && _hazard.hazard_type == HAZARD_TYPE.GAP) return false;
    // New typed gap hazards also can't be absorbed
    if (object_is_ancestor(_hazard.object_index, obj_hazard_gap) || _hazard.object_index == obj_hazard_gap) return false;

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
    if (core_apprentice_supported_by_hazard(_apprentice, _hazard)) return;
    if ((_apprentice.state == AP_STATE.GAP_JUMP) && instance_exists(_apprentice.jump_gap) && (_hazard == _apprentice.jump_gap)) {
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
    _apprentice.capabilities = capability_init(_role);
    if (_controller.limited_budget) _controller.role_budget[_role] -= 1;

    if (_role == ROLE.AEGI) {
        instance_create_layer(
            _apprentice.x + 8,
            _apprentice.y + 8,
            core_environment_layer(),
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
    /// Collision tilemap setup:
    ///
    /// The function searches for a tile layer that uses the ts_collision tileset.
    /// This means you can name the layer anything — as long as it uses ts_collision,
    /// it will be found and used as the collision map.
    ///
    /// DESIGNER WORKFLOW:
    ///   1. Create a tile layer in your room (any name works, but "tiles_collision" is conventional).
    ///   2. Assign the ts_collision tileset to it.
    ///   3. Paint solid tiles. Any non-zero tile = solid.
    ///   4. The layer will be hidden at runtime automatically.
    
    var _config = global.core_config;
    
    // --- Search all layers for one using ts_collision ---
    var _layer_count = layer_get_all();
    for (var _i = 0; _i < array_length(_layer_count); _i++) {
        var _layer = _layer_count[_i];
        var _tilemap = layer_tilemap_get_id(_layer);
        if (_tilemap != -1) {
            if (tilemap_get_tileset(_tilemap) == ts_collision) {
                layer_set_visible(_layer, false);
                global.collision_tilemap = _tilemap;
                show_debug_message("[COLLISION] Found painted collision tilemap on layer: " + layer_get_name(_layer));
                return _tilemap;
            }
        }
    }
    
    // --- FALLBACK: Legacy hardcoded collision for Room1 ---
    // Only runs if no ts_collision tilemap was found in the room.
    show_debug_message("[COLLISION] No painted ts_collision layer found — using legacy fallback");
    
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
    core_debug_check("state enum contract", (AP_STATE.WALKING == 0) && (AP_STATE.COUNT == 6));
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
