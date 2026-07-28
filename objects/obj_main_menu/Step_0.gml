/// @description Main Menu input handling

// Blink the prompt text
blink_timer += 1;
if (blink_timer >= blink_rate) {
    blink_timer = 0;
    blink_visible = !blink_visible;
}

// Start game on Enter or Space — go to level select
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    room_goto(rm_level_select);
}
