// Set game resolution
window_set_size(320, 180);
surface_resize(application_surface, 320, 180);

// Camera setup
cam_base_w = 320;
cam_base_h = 180;
cam_x = 0;
cam_y = 0;
cam_zoom = 1.0;
cam_zoom_min = 0.5;  // Zoom in (see less)
cam_zoom_max = 3.0;  // Zoom out (see more)
cam_pan_speed = 3;

var _cam = camera_create_view(cam_x, cam_y, cam_base_w, cam_base_h);
view_set_camera(0, _cam);
camera_set_view_size(_cam, cam_base_w, cam_base_h);
camera_set_view_pos(_cam, cam_x, cam_y);

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
