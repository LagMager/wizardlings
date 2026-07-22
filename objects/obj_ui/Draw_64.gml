var _controller = core_controller();
draw_set_alpha(0.96);
draw_set_colour(make_colour_rgb(18, 18, 32));
draw_rectangle(0, 0, display_get_gui_width(), 64, false);
draw_set_alpha(1);

var _labels = ["GEO [1]", "CRYO [2]", "AEGI [3]", "AERO [4]"];
var _colours = [
    make_colour_rgb(126, 190, 72),
    make_colour_rgb(92, 220, 255),
    make_colour_rgb(205, 112, 255),
    make_colour_rgb(255, 224, 92)
];

if (instance_exists(_controller)) {
    for (var _role = ROLE.GEO; _role <= ROLE.AERO; ++_role) {
        var _index = _role - ROLE.GEO;
        var _left = button_x + (_index * (button_width + button_gap));
        var _selected = (_controller.selected_role == _role);
        draw_set_colour(_selected ? c_white : _colours[_index]);
        draw_rectangle(_left, button_y, _left + button_width, button_y + button_height, _selected);
        draw_set_colour(_selected ? make_colour_rgb(18, 18, 32) : c_white);
        var _budget = _controller.limited_budget ? string(_controller.role_budget[_role]) : "INF";
        draw_text(_left + 7, button_y + 8, _labels[_index] + " " + _budget);
    }

    draw_set_colour(c_white);
    draw_text(504, 12, "ALIVE " + string(_controller.apprentices_alive) + "  EXIT " + string(_controller.apprentices_exited) + "/" + string(_controller.win_threshold));
    draw_text(504, 34, global.paused ? "PAUSED - CLICK AN APPRENTICE" : "P: PAUSE   R: RESTART");

    if (_controller.level_state != LEVEL_STATE.PLAYING) {
        draw_set_alpha(0.88);
        draw_set_colour(make_colour_rgb(10, 10, 18));
        draw_rectangle(230, 190, 730, 350, false);
        draw_set_alpha(1);
        draw_set_colour(_controller.level_state == LEVEL_STATE.WON ? make_colour_rgb(88, 238, 170) : make_colour_rgb(238, 78, 88));
        var _result = (_controller.level_state == LEVEL_STATE.WON) ? "LEVEL COMPLETE" : "LEVEL LOST";
        draw_text(405, 240, _result);
        draw_set_colour(c_white);
        draw_text(378, 284, "PRESS R TO RESTART");
    }
}
draw_set_colour(c_white);
