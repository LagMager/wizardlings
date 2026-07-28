/// @description Main Menu initialization

// Menu resolution (matches game resolution)
window_set_size(320, 180);
surface_resize(application_surface, 320, 180);

title_text = "Wizardlings";
prompt_text = "Press ENTER to Play";

// Simple blink timer for the prompt
blink_timer = 0;
blink_visible = true;
blink_rate = 40;  // frames per toggle
