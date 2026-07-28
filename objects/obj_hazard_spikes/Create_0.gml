/// @description Spikes Hazard
///
/// PURPOSE: Contact hazard that kills on touch (Aegimancer barrier can absorb).
/// PARENT: obj_hazard_parent
///
/// BEHAVIOR:
///   - Instant kill on contact (unless barrier absorbs).
///   - Not countered by Geomancer bridge.

event_inherited();

required_capability = CAP.NONE;
hazard_type = HAZARD_TYPE.SPIKES;
image_speed = 0;
