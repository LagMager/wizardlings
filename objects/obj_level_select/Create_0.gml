/// @description Level Select initialization

window_set_size(320, 180);
surface_resize(application_surface, 320, 180);

// Grid configuration
grid_cols = 5;
grid_rows = 8;
total_levels = grid_cols * grid_rows;  // 40 levels

// Grid positioning (centered in 320x180)
grid_start_x = 40;
grid_start_y = 24;
cell_w = 44;
cell_h = 18;

// Level unlock state (for now, only level 1 is unlocked)
levels_unlocked = 1;

// Room list — map level index to actual room asset
// Add rooms here as you create them
level_rooms = [Room1, Room2];

// Cursor / selection
cursor_index = 0;

// Back button
back_selected = false;
