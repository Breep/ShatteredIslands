class_name TutorialBlocker
extends ColorRect

# Fullscreen ColorRect used by TutorialOverlay to block player input around a
# tutorial bubble. Overrides _has_point so clicks falling inside the active
# target's global rect pass through to the actual UI, while everything else is
# swallowed. Visible alpha controls the dim effect (0 = invisible blocker, 0.5 = modal dim).

#region ============================== Public variables ==============================
var target_rect: Rect2 = Rect2() ## Empty rect = block everything; non-empty = hole-punch this region.
#endregion


#region ============================== Public functions ==============================
func _has_point(point: Vector2) -> bool:
	if target_rect.size == Vector2.ZERO:
		return true
	var global_p: Vector2 = get_global_transform() * point
	return not target_rect.has_point(global_p)
#endregion
