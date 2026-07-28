/// @description Draw falling platform
var _shake = is_triggered && !is_falling ? irandom_range(-1, 1) : 0;
platform_draw(_shake);
