global.core_config = core_default_config();
global.paused = false;
global.collision_tilemap = -1;

level_state = LEVEL_STATE.PLAYING;
selected_role = ROLE.NONE;
limited_budget = false;
role_budget = array_create(ROLE.COUNT, 0);
role_budget[ROLE.GEO] = 99;
role_budget[ROLE.CRYO] = 99;
role_budget[ROLE.AEGI] = 99;
role_budget[ROLE.AERO] = 99;

apprentice_count = 0;
apprentices_alive = 0;
apprentices_exited = 0;
apprentices_dead = 0;
win_threshold = 2;
counts_initialized = false;
debug_frame = 0;
smoke_mode = (environment_get_variable("WIZARDLINGS_SMOKE") == "1");
smoke_frame = 0;
smoke_pause_x = 0;
smoke_pause_v = 0;
if (smoke_mode) {
    if (!variable_global_exists("smoke_cycle")) global.smoke_cycle = 0;
    game_set_speed(600, gamespeed_fps);
}

global.collision_tilemap = core_setup_collision_tilemap();
core_run_boot_checks();
