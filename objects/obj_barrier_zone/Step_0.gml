if (!instance_exists(owner)) {
    instance_destroy();
    exit;
}
if ((owner.state == AP_STATE.DEAD) || (owner.state == AP_STATE.EXITED) || broken) {
    instance_destroy();
    exit;
}
x = owner.x + 8;
y = owner.y + 8;
