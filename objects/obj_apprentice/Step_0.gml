if (variable_global_exists("paused") && global.paused) {
    // Still animate death bounce while paused (visual only)
    if (death_bounce_active) {
        death_bounce_vy += death_bounce_gravity;
        y += death_bounce_vy;
        death_timer += 1;
        if (death_timer > 120) visible = false;
    }
    exit;
}
if ((state == AP_STATE.DEAD) || (state == AP_STATE.EXITED)) {
    // Death bounce animation
    if (death_bounce_active) {
        death_bounce_vy += death_bounce_gravity;
        y += death_bounce_vy;
        death_timer += 1;
        if (death_timer > 120) visible = false;
    }
    exit;
}

if (y > room_height + global.core_config.cull_margin) {
    core_notify_terminal(id, AP_STATE.DEAD);
    exit;
}

if (core_try_exit(id)) exit;

switch (state) {
    case AP_STATE.WALKING:
        if (role == ROLE.AERO) {
            var _wind = core_wind_ahead(id, global.core_config.wind_detection_distance);
            if ((_wind != noone) && !_wind.active && !_wind.activation_started) {
                core_begin_cast(id, _wind, CAST_ACTION.WIND);
                exit;
            }
        }

        var _look_ahead = core_hazard_detection_distance(id);
        var _hazard = core_hazard_ahead(id, _look_ahead);
        if (_hazard != noone) {
            if (capability_has(id, CAP.VOIDWALK) && core_is_gap_hazard(_hazard)
                && core_gap_can_clear(id, _hazard)
                && core_gap_ahead_in_range(id, _hazard, _look_ahead)) {
                gap_jump_target = _hazard;
            } else if (core_is_gap_hazard(_hazard)) {
                gap_jump_target = noone;
            }

            // --- New typed hazards (obj_hazard_parent children) ---
            if (variable_instance_exists(_hazard, "can_be_countered") && _hazard.hazard_active) {
                if (_hazard.can_be_countered(id)) {
                    var _cast = CAST_ACTION.NONE;
                    if (capability_has(id, CAP.BUILD_BRIDGE))    _cast = CAST_ACTION.TERRAIN;
                    else if (capability_has(id, CAP.FREEZE_WATER))   _cast = CAST_ACTION.ICE;
                    else if (capability_has(id, CAP.EXTINGUISH_FIRE)) _cast = CAST_ACTION.ICE;
                    else if (capability_has(id, CAP.SOLIDIFY_TERRAIN)) _cast = CAST_ACTION.ICE;
                    
                    if (_cast != CAST_ACTION.NONE) {
                        core_begin_cast(id, _hazard, _cast);
                        exit;
                    }
                }
            }
            // --- Legacy obj_hazard support ---
            else if (variable_instance_exists(_hazard, "hazard_type") && core_hazard_is_lethal(_hazard)) {
                if ((role == ROLE.GEO) && _hazard.geo_allowed && core_role_counters_hazard(role, _hazard.hazard_type)) {
                    core_begin_cast(id, _hazard, CAST_ACTION.TERRAIN);
                    exit;
                }
                if ((role == ROLE.CRYO) && core_role_counters_hazard(role, _hazard.hazard_type)) {
                    core_begin_cast(id, _hazard, CAST_ACTION.ICE);
                    exit;
                }
            }
        } else if (gap_jump_target != noone) {
            gap_jump_target = noone;
        }

        if (!platform_apprentice_riding(id)) {
            h_remainder += move_speed * move_sign;
            var _horizontal_pixels = floor(abs(h_remainder));
            if (_horizontal_pixels > 0) {
                h_remainder -= _horizontal_pixels * sign(h_remainder);
                repeat (_horizontal_pixels) {
                    if (core_apprentice_collides(id, move_sign, 0)) {
                        core_apprentice_bounce_horizontal(id);
                        break;
                    }
                    x += move_sign;
                    core_apprentice_set_facing(id, move_sign);
                }
            }
        } else {
            h_remainder = 0;
        }

        if (instance_exists(gap_jump_target) && core_gap_jumpable(id, gap_jump_target)) {
            if (core_begin_gap_jump(id, gap_jump_target)) {
                gap_jump_target = noone;
                exit;
            }
        }

        var _ladder = core_ladder_touching(id);
        if (_ladder != noone) core_try_mount_ladder(id, _ladder);
        break;

    case AP_STATE.CASTING:
        cast_timer -= 1;
        if (cast_timer <= 0) core_finish_cast(id);
        break;

    case AP_STATE.GAP_JUMP:
        core_step_gap_jump(id);
        break;

    case AP_STATE.CLIMBING:
        core_step_climb(id);
        break;
}

if (state != AP_STATE.CASTING && state != AP_STATE.GAP_JUMP && state != AP_STATE.CLIMBING) {
    v_speed = min(v_speed + global.core_config.gravity, global.core_config.max_fall_speed);
    v_remainder += v_speed;
    var _vertical_pixels = floor(abs(v_remainder));
    if (_vertical_pixels > 0) {
        var _vertical_sign = sign(v_remainder);
        v_remainder -= _vertical_pixels * _vertical_sign;
        repeat (_vertical_pixels) {
            if (core_apprentice_collides(id, 0, _vertical_sign)) {
                v_speed = 0;
                v_remainder = 0;
                break;
            }
            y += _vertical_sign;
        }
    }
}

if (core_try_exit(id)) exit;

if (state != AP_STATE.CASTING && state != AP_STATE.GAP_JUMP && state != AP_STATE.CLIMBING) {
    core_resolve_hazard_contact(id);
}

if (y > room_height + global.core_config.cull_margin) {
    core_notify_terminal(id, AP_STATE.DEAD);
}
