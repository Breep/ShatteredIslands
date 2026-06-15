class_name DragonFlightCameraZoom
extends Node

# Presentation-only helper for the dragon encounter: while "Vol fracassant" is airborne the
# dragon leaves the frozen combat framing, so this eases the locally-active CenterPointCamera
# into the cinematic dragon preset on flight_started, and back as soon as the dragon commits to
# flying home (flight_return_started) so the camera is settled before it lands. flight_landed is
# also wired as a safety net for abnormal ends (death / fight end mid-air) — restore() is
# idempotent, so whichever fires first wins and the later one is a no-op. Scoped to the dragon,
# never in the generic fight/island layer; touches no deterministic combat state (camera-local).

#region Export
@export var _flight_ability: ShatteringFlightAbility
## Camera preset eased into for the duration of the flight (defaults to the dedicated
## cinematic dragon framing).
@export var _flight_distance: CenterPointCamera.Distance = CenterPointCamera.Distance.DRAGON_FLIGHT
## Eased travel time of the dezoom / restore, in seconds.
@export var _zoom_duration: float = 2.0
#endregion

#region Node base functions
func _ready() -> void:
	if _flight_ability == null:
		Verbose.error("DragonFlightCameraZoom: no flight ability", Verbose.Category.ENTITY)
		return
	_flight_ability.flight_started.connect(_on_flight_started)
	_flight_ability.flight_return_started.connect(_on_flight_ended)
	_flight_ability.flight_landed.connect(_on_flight_ended)
#endregion

#region Callbacks
func _on_flight_started() -> void:
	var cam: CenterPointCamera = CenterPointCamera.active()
	if cam != null:
		cam.push_distance(_flight_distance, _zoom_duration)


func _on_flight_ended() -> void:
	var cam: CenterPointCamera = CenterPointCamera.active()
	if cam != null:
		cam.restore(_zoom_duration)
#endregion
