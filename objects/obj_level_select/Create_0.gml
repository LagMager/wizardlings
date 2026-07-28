/// @description Level Select initialization

window_set_size(320, 180);
surface_resize(application_surface, 320, 180);

// Grid configuration
grid_cols = 5;
grid_rows = 8;
total_levels = grid_cols * grid_rows;  // 40 levels

// Back button
back_selected = false;

// Layout tuned for 320×180 dark UI panel
grid_start_x = 36;
grid_start_y = 28;
cell_w = 44;
cell_h = 16;

// Level unlock state (for now, first N levels in level_rooms are selectable)
levels_unlocked = 4;

// Room list — map level index to actual room asset
level_rooms = [Room1, lvl_geo, lvl_cryo, lvl_aero];

// Cursor / selection
cursor_index = 0;

// Back button
back_selected = false;
