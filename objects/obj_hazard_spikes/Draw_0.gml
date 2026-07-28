/// Tile spr_spikes at native size; scaleX/scaleY size the hazard bounds.
if (is_neutralized) exit;

var _tile_w = sprite_get_width(sprite_index);
var _tile_h = sprite_get_height(sprite_index);
var _left = bbox_left;
var _y = bbox_top;

while (_left <= bbox_right) {
    draw_sprite_stretched(sprite_index, image_index, _left, _y, _tile_w, _tile_h * image_yscale);
    _left += _tile_w;
}
draw_set_colour(c_white);
