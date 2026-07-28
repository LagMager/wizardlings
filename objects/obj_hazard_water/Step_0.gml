if (is_neutralized) {
    if (!(variable_global_exists("paused") && global.paused)) {
        freeze_timer -= 1;
        if (freeze_timer <= 0) on_ice_melted();
    }
    exit;
}

/// Keep liquid animation on frames before the frozen sub-image.
if (image_number <= 2) exit;

if (image_index >= frozen_image_index) {
    image_index = 0;
}
