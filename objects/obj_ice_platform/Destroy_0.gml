if (!instance_exists(source_hazard)) exit;

if (variable_instance_exists(source_hazard, "on_ice_melted")) {
    source_hazard.on_ice_melted();
} else if (registered_with_hazard) {
    source_hazard.neutralizer_count = max(0, source_hazard.neutralizer_count - 1);
    if (source_hazard.cryo_effect == id) source_hazard.cryo_effect = noone;
    source_hazard.cryo_pending = false;
}

if (instance_exists(source_hazard) && variable_instance_exists(source_hazard, "ice_effect")) {
    if (source_hazard.ice_effect == id) source_hazard.ice_effect = noone;
}
