/// @description Platform Parent — Base Initialization
///
/// PURPOSE: Root parent for all platform objects (static, moving, falling).
/// RESPONSIBILITY: Provides common interface for passenger carrying.
/// PARENT: obj_environment_parent
///
/// PUBLIC VARIABLES:
///   platform_active : bool — Whether the platform is currently functional.
///   platform_width  : real — World width in pixels (from room scale or creation code).
///   platform_height : real — World height in pixels.
///
/// PUBLIC METHODS (override in children):
///   None at parent level — children implement their own movement.
///
/// INTERACTION FLOW:
///   1. Platform moves itself in its Step event.
///   2. Platform calls platform_carry_passengers(id, dx, dy) after moving.
///   3. Apprentices ride automatically without knowing platform type.
///
/// WHY THIS DESIGN:
///   Characters never need to check what KIND of platform they're on.
///   Platforms are responsible for carrying their passengers.
///   Adding a new platform type = new child object, zero changes elsewhere.

platform_active = true;
platform_width = 0;
platform_height = 0;
requires_aero = true;
platform_sync_size_from_room();
