// Set game resolution
window_set_size(320, 180);

// --- Pixel-Perfect Camera Configuration ---
cam_base_w = 320;           // Base resolution width (native "1x" view)
cam_base_h = 180;           // Base resolution height
cam_x = 0;                  // Camera world position X
cam_y = 0;                  // Camera world position Y
cam_zoom = 1.0;             // Start at native resolution (320x180)
cam_zoom_min = 0.5;         // Most zoomed-in (see half the base area — 160x90)
cam_zoom_max = 1.0;         // Cannot zoom out beyond native 320x180
target_zoom = 1.0;          // Start at native — gameplay code can zoom in from here
cam_zoom_speed = 0.1;       // Lerp speed (0.1 = smooth, 1.0 = instant)
cam_pan_speed = 3;          // Pixels per frame for keyboard panning
cam_snap_to_pixel = true;   // Round camera position to whole pixels

// Initialize the pixel-perfect camera (disables filtering, creates view, resizes surface)
camera_init();

global.core_config = core_default_config();
global.paused = false;
global.collision_tilemap = -1;

// Initialize the signal system for interactable→mechanism communication
signal_system_init();

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
