/// Tile spr_ladder at native size; instance scaleY only sizes climb/walk bounds.
var _tile_h = sprite_get_height(sprite_index);
var _left = bbox_left;
var _y = bbox_top;

while (_y <= bbox_bottom) {
    draw_sprite(sprite_index, image_index, _left, _y);
    _y += _tile_h;
}
