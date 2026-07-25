/// @description Spawn apprentices on interval

if (!spawning_active) exit;
if (global.paused) exit;
if (spawn_count >= spawn_total) {
    spawning_active = false;
    exit;
}

spawn_timer += 1;

if (spawn_timer >= spawn_interval) {
    spawn_timer = 0;
    
    var _apprentice = instance_create_layer(x, y, spawn_layer, obj_apprentice);
    _apprentice.move_sign = spawn_direction;
    
    spawn_count += 1;
    
    // Update game controller counts
    var _controller = core_controller();
    if (instance_exists(_controller)) {
        _controller.apprentice_count += 1;
        _controller.apprentices_alive += 1;
    }
}
