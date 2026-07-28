/// @description Terrain Block — Created by Geomancer
///
/// Uses manual width/height for collision. The sprite is only used for bbox sizing.

if (!variable_instance_exists(id, "block_width")) block_width = 48;
if (!variable_instance_exists(id, "block_height")) block_height = 8;
if (!variable_instance_exists(id, "source_hazard")) source_hazard = noone;

// Scale sprite to match block dimensions for collision bbox
image_xscale = block_width / sprite_width;
image_yscale = block_height / sprite_height;
image_speed = 0;
image_alpha = 0;  // Hide the sprite — we draw manually
