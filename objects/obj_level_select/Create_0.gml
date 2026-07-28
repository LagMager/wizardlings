/// @description Level Select initialization

window_set_size(320, 180);
surface_resize(application_surface, 320, 180);

level_rooms = [lvl_geo, lvl_cryo, lvl_aero, lvl_aegis, lvl_01];
total_levels = array_length(level_rooms);
levels_unlocked = total_levels;

grid_cols = total_levels;
grid_rows = 1;

grid_start_x = 40;
grid_start_y = 44;
cell_w = 44;
cell_h = 20;

back_selected = false;
cursor_index = 0;
