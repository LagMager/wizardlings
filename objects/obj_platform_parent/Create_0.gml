/// @description Platform Parent — Base Initialization
///
/// PURPOSE: Root parent for all platform objects (static, moving, falling).
/// RESPONSIBILITY: Provides common interface for passenger carrying.
/// PARENT: obj_environment_parent
///
/// PUBLIC VARIABLES:
///   platform_active : bool — Whether the platform is currently functional.
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
