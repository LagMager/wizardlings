var _controller = core_controller();
if (!instance_exists(_controller)) exit;
if (_controller.level_state != LEVEL_STATE.PLAYING) exit;

var _chosen = ROLE.NONE;
if (keyboard_check_pressed(ord("1"))) _chosen = ROLE.GEO;
if (keyboard_check_pressed(ord("2"))) _chosen = ROLE.CRYO;
if (keyboard_check_pressed(ord("3"))) _chosen = ROLE.AEGI;
if (keyboard_check_pressed(ord("4"))) _chosen = ROLE.AERO;

if (mouse_check_button_pressed(mb_left)) {
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    for (var _role = ROLE.GEO; _role <= ROLE.AERO; ++_role) {
        var _index = _role - ROLE.GEO;
        var _left = button_x + (_index * (button_width + button_gap));
        if (point_in_rectangle(_mx, _my, _left, button_y, _left + button_width, button_y + button_height)) {
            _chosen = _role;
        }
    }
}

if (_chosen != ROLE.NONE) {
    if (!_controller.limited_budget || (_controller.role_budget[_chosen] > 0)) {
        _controller.selected_role = _chosen;
        global.paused = true;
    }
}
