var _floor_colour = make_colour_rgb(58, 68, 92);
var _floor_highlight = make_colour_rgb(92, 108, 136);
var _segments = [
    [8, 208],
    [256, 704],
    [816, room_width - 8]
];

draw_set_colour(_floor_colour);
for (var _i = 0; _i < array_length(_segments); ++_i) {
    draw_rectangle(_segments[_i][0], 440, _segments[_i][1] - 1, room_height, false);
}
draw_rectangle(0, 0, 7, room_height, false);
draw_rectangle(room_width - 8, 0, room_width, room_height, false);

draw_set_colour(_floor_highlight);
for (var _j = 0; _j < array_length(_segments); ++_j) {
    draw_rectangle(_segments[_j][0], 440, _segments[_j][1] - 1, 443, false);
}

draw_set_colour(c_white);
