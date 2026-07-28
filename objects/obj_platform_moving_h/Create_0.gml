/// @description Horizontal Moving Platform
///
/// PURPOSE: A platform that moves back and forth horizontally.
/// PARENT: obj_platform_parent
///
/// PUBLIC VARIABLES:
///   move_distance : real — Total distance to travel from start position.
///   move_speed    : real — Pixels per frame.
///   start_x       : real — Starting X position (set automatically).
///
/// INTERACTION:
///   Moves itself, then calls platform_carry_passengers() to move riders.
///   Apprentices don't need to know this is a moving platform.

event_inherited();  // Call parent Create

move_distance = 64;
move_speed = 0.5;
start_x = x;
move_dir = 1;
