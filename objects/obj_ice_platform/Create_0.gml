if (!variable_instance_exists(id, "platform_width")) platform_width = 48;
if (!variable_instance_exists(id, "platform_height")) platform_height = global.core_config.terrain_height;
if (!variable_instance_exists(id, "source_hazard")) source_hazard = noone;
if (!variable_instance_exists(id, "lifetime")) lifetime = global.core_config.ice_lifetime;

timer = lifetime;
registered_with_hazard = false;
image_xscale = platform_width / sprite_width;
image_yscale = platform_height / sprite_height;
image_speed = 0;

if (instance_exists(source_hazard)) {
    if (variable_instance_exists(source_hazard, "ice_effect")) {
        source_hazard.ice_effect = id;
    }
    if (variable_instance_exists(source_hazard, "neutralizer_count")) {
        source_hazard.neutralizer_count += 1;
    }
    if (variable_instance_exists(source_hazard, "cryo_effect")) {
        source_hazard.cryo_effect = id;
    }
    if (variable_instance_exists(source_hazard, "cryo_pending")) {
        source_hazard.cryo_pending = false;
    }
    registered_with_hazard = true;
}
