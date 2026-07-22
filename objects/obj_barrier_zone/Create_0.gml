if (!variable_instance_exists(id, "owner")) owner = noone;
radius = global.core_config.barrier_radius;
hits_remaining = global.core_config.barrier_hits;
broken = false;
if (instance_exists(owner)) {
    x = owner.x + 8;
    y = owner.y + 8;
}
