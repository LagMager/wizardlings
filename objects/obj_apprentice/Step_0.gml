if (global.paused) exit;
if ((state == AP_STATE.DEAD) || (state == AP_STATE.EXITED)) exit;

if (y > room_height + global.core_config.cull_margin) {
    core_notify_terminal(id, AP_STATE.DEAD);
    exit;
}

if (core_exit_touching(id) != noone) {
    core_notify_terminal(id, AP_STATE.EXITED);
    exit;
}

switch (state) {
    case AP_STATE.WALKING:
        if (role == ROLE.AERO) {
            var _wind = core_wind_ahead(id, global.core_config.wind_detection_distance);
            if ((_wind != noone) && !_wind.active && !_wind.activation_started) {
                core_begin_cast(id, _wind, CAST_ACTION.WIND);
                exit;
            }
        }

        var _hazard = core_hazard_ahead(id, global.core_config.detection_distance);
        if ((_hazard != noone) && core_hazard_is_lethal(_hazard)) {
            if ((role == ROLE.GEO) && _hazard.geo_allowed && core_role_counters_hazard(role, _hazard.hazard_type)) {
                core_begin_cast(id, _hazard, CAST_ACTION.TERRAIN);
                exit;
            }
            if ((role == ROLE.CRYO) && core_role_counters_hazard(role, _hazard.hazard_type)) {
                core_begin_cast(id, _hazard, CAST_ACTION.ICE);
                exit;
            }
        }

        h_remainder += move_speed * move_sign;
        var _horizontal_pixels = floor(abs(h_remainder));
        if (_horizontal_pixels > 0) {
            h_remainder -= _horizontal_pixels * sign(h_remainder);
            repeat (_horizontal_pixels) {
                if (core_apprentice_collides(id, move_sign, 0)) {
                    move_sign *= -1;
                    h_remainder = 0;
                    break;
                }
                x += move_sign;
            }
        }
        break;

    case AP_STATE.CASTING:
        cast_timer -= 1;
        if (cast_timer <= 0) core_finish_cast(id);
        break;
}

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

if (core_exit_touching(id) != noone) {
    core_notify_terminal(id, AP_STATE.EXITED);
    exit;
}

core_resolve_hazard_contact(id);

if (y > room_height + global.core_config.cull_margin) {
    core_notify_terminal(id, AP_STATE.DEAD);
}
