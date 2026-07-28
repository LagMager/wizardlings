/// @description Pixel-Perfect Camera Zoom System
///
/// This script provides a complete camera system that:
///   - Zooms the entire game view via the active camera (not per-object scaling)
///   - Preserves pixel-art sharpness by snapping to integer zoom levels
///   - Aligns camera position to whole pixels to prevent sprite jitter
///   - Smoothly interpolates between zoom levels using lerp
///   - Works regardless of room size
///
/// ============================================================================
/// VARIABLE REFERENCE (stored on the calling instance, e.g. obj_game_controller)
/// ============================================================================
///
/// cam_base_w        : Base resolution width in pixels (e.g. 320). The "1x" view.
/// cam_base_h        : Base resolution height in pixels (e.g. 180). The "1x" view.
/// cam_x             : Current camera X position in world space (top-left corner).
/// cam_y             : Current camera Y position in world space (top-left corner).
/// cam_zoom          : Current zoom multiplier. 1.0 = native resolution.
///                     Values < 1 zoom in (fewer pixels visible, things look bigger).
///                     Values > 1 zoom out (more pixels visible, things look smaller).
/// cam_zoom_min      : Minimum allowed zoom (most zoomed-in). Should be a power-of-two
///                     fraction for pixel-perfect results (0.5, 1.0, etc).
/// cam_zoom_max      : Maximum allowed zoom (most zoomed-out).
/// target_zoom       : The desired zoom level. Gameplay code sets this to request zoom
///                     changes. The system will smoothly lerp cam_zoom toward it.
/// cam_zoom_speed    : Lerp speed per frame (0.0–1.0). Higher = snappier transitions.
///                     0.08–0.15 feels responsive; 1.0 = instant.
/// cam_pan_speed     : Pixels per frame the camera pans when using keyboard controls.
/// cam_snap_to_pixel : If true, camera position is rounded to whole pixels every frame.
///                     Essential for pixel art to avoid sub-pixel rendering artifacts.
///
/// ============================================================================


/// @function camera_init()
/// @description Call once in the Create event to set up the pixel-perfect camera.
///              Disables texture interpolation and configures the application surface.
function camera_init() {
    // --- Disable texture filtering globally ---
    // This is the single most important setting for pixel art.
    // It prevents GPU bilinear filtering from blurring sprites when scaled.
    gpu_set_texfilter(false);
    
    // --- Lock application surface to base resolution ---
    // The application surface is what GameMaker renders the game onto before
    // stretching it to the window. By keeping it at base resolution and letting
    // the window/viewport handle upscaling, we get crisp nearest-neighbor scaling.
    surface_resize(application_surface, cam_base_w, cam_base_h);
    
    // --- Create and assign camera ---
    var _cam = camera_create_view(cam_x, cam_y, cam_base_w, cam_base_h);
    view_set_camera(0, _cam);
    camera_set_view_size(_cam, cam_base_w, cam_base_h);
    camera_set_view_pos(_cam, cam_x, cam_y);
    
    // --- Ensure views are enabled ---
    // Views must be on for the camera to take effect.
    view_enabled = true;
    view_visible[0] = true;

    // Keep GUI aligned with base resolution after view/surface changes.
    display_set_gui_size(cam_base_w, cam_base_h);
}


/// @function camera_update()
/// @description Call every frame in the Step event. Handles smooth zoom interpolation,
///              pixel snapping, and applying the final camera transform.
function camera_update() {
    var _cam = view_get_camera(0);
    
    // --- Smooth zoom interpolation ---
    // Lerp from current zoom toward target_zoom at the configured speed.
    // This gives a buttery transition instead of jarring jumps.
    cam_zoom = lerp(cam_zoom, target_zoom, cam_zoom_speed);
    
    // --- Snap zoom to pixel-perfect values ---
    // For truly crisp pixel art, the view size must be an integer multiple of the
    // base resolution. We achieve this by quantizing the zoom to the nearest value
    // that produces whole-pixel dimensions.
    //
    // The "quantum" is 1/base_w — the smallest zoom change that shifts the view
    // by exactly 1 pixel in width. We round to this quantum.
    var _zoom_quantum = 1 / cam_base_w;
    var _snapped_zoom = round(cam_zoom / _zoom_quantum) * _zoom_quantum;
    
    // Clamp to configured bounds
    _snapped_zoom = clamp(_snapped_zoom, cam_zoom_min, cam_zoom_max);
    
    // --- Calculate view dimensions ---
    // Multiply base resolution by zoom. Because we snapped the zoom,
    // these will always be integers (or extremely close due to float precision).
    var _view_w = round(cam_base_w * _snapped_zoom);
    var _view_h = round(cam_base_h * _snapped_zoom);
    
    // --- Resize application surface to match view ---
    // This ensures a 1:1 texel-to-pixel mapping in the render target.
    // Every game pixel maps to exactly one surface pixel — no sub-pixel blending.
    surface_resize(application_surface, _view_w, _view_h);
    
    // --- Pixel-snap camera position ---
    // Fractional camera positions cause the GPU to sample between pixels,
    // producing shimmer/jitter on sprites. Floor to whole pixels.
    if (cam_snap_to_pixel) {
        cam_x = floor(cam_x);
        cam_y = floor(cam_y);
    }
    
    // --- Clamp camera to room bounds ---
    // Prevent the camera from showing void beyond the room edges.
    cam_x = clamp(cam_x, 0, max(0, room_width - _view_w));
    cam_y = clamp(cam_y, 0, max(0, room_height - _view_h));
    
    // --- Apply to camera ---
    camera_set_view_pos(_cam, cam_x, cam_y);
    camera_set_view_size(_cam, _view_w, _view_h);

    display_set_gui_size(cam_base_w, cam_base_h);
}


/// @function camera_set_target_zoom(_zoom)
/// @description Gameplay code calls this to request a zoom change.
///              The camera will smoothly interpolate to the new value.
/// @param {real} _zoom  The desired zoom multiplier.
function camera_set_target_zoom(_zoom) {
    target_zoom = clamp(_zoom, cam_zoom_min, cam_zoom_max);
}


/// @function camera_zoom_in(_amount)
/// @description Decrease target_zoom (zoom in = see fewer pixels, things look bigger).
/// @param {real} _amount  How much to subtract from target_zoom (positive value).
function camera_zoom_in(_amount) {
    camera_set_target_zoom(target_zoom - _amount);
}


/// @function camera_zoom_out(_amount)
/// @description Increase target_zoom (zoom out = see more pixels, things look smaller).
/// @param {real} _amount  How much to add to target_zoom (positive value).
function camera_zoom_out(_amount) {
    camera_set_target_zoom(target_zoom + _amount);
}


/// @function camera_get_view_width()
/// @description Returns the current camera view width in world pixels.
/// @returns {real}
function camera_get_view_width() {
    var _cam = view_get_camera(0);
    return camera_get_view_w(_cam);
}


/// @function camera_get_view_height()
/// @description Returns the current camera view height in world pixels.
/// @returns {real}
function camera_get_view_height() {
    var _cam = view_get_camera(0);
    return camera_get_view_h(_cam);
}


/// @function camera_center_on(_x, _y)
/// @description Centers the camera on a world position (pixel-snapped).
/// @param {real} _x  World X to center on.
/// @param {real} _y  World Y to center on.
function camera_center_on(_x, _y) {
    var _cam = view_get_camera(0);
    var _vw = camera_get_view_w(_cam);
    var _vh = camera_get_view_h(_cam);
    cam_x = _x - _vw * 0.5;
    cam_y = _y - _vh * 0.5;
    // Pixel snap and room clamp happen in camera_update()
}
