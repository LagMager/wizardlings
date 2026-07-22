if (!counts_initialized) {
    apprentice_count = instance_number(obj_apprentice);
    apprentices_alive = apprentice_count;
    apprentices_exited = 0;
    apprentices_dead = 0;
    counts_initialized = true;
    core_debug_check("multiple apprentices preplaced", apprentice_count > 1);
    core_debug_check("designer win threshold is reachable", (win_threshold > 0) && (win_threshold <= apprentice_count));
}

if (keyboard_check_pressed(ord("R"))) {
    room_restart();
    exit;
}

if (level_state == LEVEL_STATE.PLAYING) {
    if (keyboard_check_pressed(ord("P"))) {
        global.paused = !global.paused;
    }

    if (global.paused && (selected_role != ROLE.NONE) && mouse_check_button_pressed(mb_left)) {
        var _target = instance_position(mouse_x, mouse_y, obj_apprentice);
        if (_target != noone) core_assign_role(id, _target, selected_role);
    }

    // Victory resolves before defeat when terminal events share a frame.
    if (apprentices_exited >= win_threshold) {
        level_state = LEVEL_STATE.WON;
        global.paused = true;
        show_debug_message("[LEVEL] WON");
    } else if (counts_initialized && ((apprentices_alive + apprentices_exited) < win_threshold)) {
        level_state = LEVEL_STATE.LOST;
        global.paused = true;
        show_debug_message("[LEVEL] LOST");
    }
}

debug_frame += 1;
if (counts_initialized && (debug_frame >= global.core_config.debug_validation_period)) {
    debug_frame = 0;
    core_validate_runtime(id);
}

if (smoke_mode) {
    smoke_frame += 1;

    if ((global.smoke_cycle == 0) && (smoke_frame == 1)) {
        limited_budget = true;
        role_budget[ROLE.AEGI] = 1;
        var _limited_apprentice = instance_find(obj_apprentice, 0);
        global.paused = true;
        core_assign_role(id, _limited_apprentice, ROLE.AEGI);
        core_debug_check("limited mode decrements its budget", role_budget[ROLE.AEGI] == 0);
        limited_budget = false;

        var _smoke_roles = [ROLE.AERO, ROLE.CRYO, ROLE.CRYO, ROLE.GEO, ROLE.GEO];
        for (var _smoke_index = 0; _smoke_index < array_length(_smoke_roles); ++_smoke_index) {
            var _smoke_apprentice = instance_find(obj_apprentice, _smoke_index + 1);
            global.paused = true;
            core_assign_role(id, _smoke_apprentice, _smoke_roles[_smoke_index]);
        }
        global.paused = true;
        var _reassignment_rejected = !core_assign_role(id, _limited_apprentice, ROLE.CRYO);
        global.paused = false;
        core_debug_check("role assignment is permanent", _reassignment_rejected);
        core_debug_check("smoke assigned all four roles", instance_number(obj_barrier_zone) == 1);
        core_debug_check("unlimited mode preserves budgets", role_budget[ROLE.GEO] == 99);

        var _smoke_spikes = noone;
        for (var _hazard_index = 0; _hazard_index < instance_number(obj_hazard); ++_hazard_index) {
            var _candidate_hazard = instance_find(obj_hazard, _hazard_index);
            if (_candidate_hazard.hazard_type == HAZARD_TYPE.SPIKES) {
                _smoke_spikes = _candidate_hazard;
                break;
            }
        }
        var _shielded_apprentice = instance_find(obj_apprentice, 0);
        var _first_absorb = core_try_absorb_hazard(_shielded_apprentice, _smoke_spikes);
        var _second_absorb = core_try_absorb_hazard(_shielded_apprentice, _smoke_spikes);
        var _third_absorb = core_try_absorb_hazard(_shielded_apprentice, _smoke_spikes);
        core_debug_check("barrier absorbs exactly two discrete hits", _first_absorb && _second_absorb && !_third_absorb);
    }

    if ((global.smoke_cycle == 0) && (smoke_frame == 2)) {
        var _paused_apprentice = instance_find(obj_apprentice, 0);
        smoke_pause_x = _paused_apprentice.x;
        smoke_pause_v = _paused_apprentice.v_speed;
        global.paused = true;
    }
    if ((global.smoke_cycle == 0) && (smoke_frame == 3)) {
        var _paused_probe = instance_find(obj_apprentice, 0);
        core_debug_check(
            "pause preserves position and velocity",
            (_paused_probe.x == smoke_pause_x) && (_paused_probe.v_speed == smoke_pause_v)
        );
        global.paused = false;
    }

    if (smoke_frame >= 900) {
        core_validate_runtime(id);
        if (global.smoke_cycle == 0) {
            var _smoke_wind = instance_find(obj_wind_object, 0);
            core_debug_check("smoke created permanent terrain", instance_number(obj_terrain_block) > 0);
            core_debug_check("Aeromancer completed the wind route", instance_exists(_smoke_wind) && _smoke_wind.route_complete);
            core_debug_check("solved smoke cycle reaches victory", level_state == LEVEL_STATE.WON);
            global.smoke_cycle = 1;
            room_restart();
            exit;
        } else {
            core_debug_check("unassisted smoke cycle reaches defeat", level_state == LEVEL_STATE.LOST);
            show_debug_message("[SMOKE] COMPLETE: victory and defeat cycles passed");
            game_end();
        }
    }
}
