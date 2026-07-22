if (registered_with_hazard && instance_exists(source_hazard)) {
    source_hazard.neutralizer_count = max(0, source_hazard.neutralizer_count - 1);
    if (source_hazard.cryo_effect == id) source_hazard.cryo_effect = noone;
    source_hazard.cryo_pending = false;
}
