if (!variable_instance_exists(id, "block_width")) block_width = 48;
if (!variable_instance_exists(id, "block_height")) block_height = global.core_config.terrain_height;
if (!variable_instance_exists(id, "source_hazard")) source_hazard = noone;
image_xscale = block_width / sprite_width;
image_yscale = block_height / sprite_height;
image_speed = 0;
