if (!instance_exists(source_hazard)) {
    instance_destroy();
    exit;
}
if (global.paused) exit;

timer -= 1;
if (timer <= 0) instance_destroy();
