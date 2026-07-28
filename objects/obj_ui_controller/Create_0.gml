/// @description UI Controller — Initialization
///
/// PURPOSE: Master controller for all in-game UI. Manages UI state transitions
///          and coordinates sub-objects (role selector, pause menu).
/// RESPONSIBILITY: Reads game state, never writes gameplay logic directly.
///
/// PUBLIC VARIABLES:
///   ui_state       : UI_STATE enum — current overlay being shown.
///   level_name     : string — display name for the current level.
///   tutorial_hint  : string — hint text shown when non-empty.
///   show_hint      : bool — whether to display the tutorial hint.
///   level_time     : real — frames elapsed since level start (for victory screen).
///   roles_enabled  : array — which roles are available (for tutorial levels).

// Lock GUI to game resolution for clean pixel scaling
display_set_gui_size(320, 180);

// UI state
ui_state = UI_STATE.GAMEPLAY;

// Level info (set in room Creation Code if needed)
level_name = "Level " + string(room);
tutorial_hint = "";
show_hint = false;

// Timer
level_time = 0;

// Role availability (all enabled by default; disable for tutorials)
roles_enabled = array_create(ROLE.COUNT, true);
roles_enabled[ROLE.NONE] = false;

// Pause menu cursor
pause_cursor = 0;
pause_options = ["RESUME", "RESTART", "LEVEL SELECT", "MAIN MENU"];
