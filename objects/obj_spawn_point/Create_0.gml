/// @description Spawn point configuration

// How many apprentices to spawn in total
spawn_total = 10;

// Frames between each spawn
spawn_interval = 60;  // 1 second at 60fps

// Internal tracking
spawn_count = 0;
spawn_timer = 0;
spawning_active = true;

// Direction spawned apprentices will face (1 = right, -1 = left)
spawn_direction = 1;

// Layer to spawn apprentices on
spawn_layer = "Instances";
