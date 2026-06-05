class_name FlightPathProfile
extends Resource

# Procedural flight-path generator for the Skeleton Dragon's "Vol fracassant".
# Builds a smooth, always-valid Curve3D (analytic-ish tangents + banking baked into the
# per-point tilts) in takeoff-local space: the maneuver is a constant-radius aerial loop
# that, for an integer lap count, closes exactly on the takeoff spot — so the dragon
# leaves from and lands back home. Authored / previewed in shattering_flight.proto.tscn
# before being wired into ShatteringFlightAbility.

#region Export
## Radius of the loop above the arena (metres).
@export var radius: float = 15.0
## Peak altitude above the takeoff spot (metres).
@export var height: float = 8.0
## Number of full loops flown during the maneuver. Integer so the loop closes exactly
## back on the takeoff spot.
@export_range(1, 3, 1) var laps: int = 1
## Inclination of the loop's plane: 0 = flat disc (horizontal), 1 = strongly banked
## (the dragon dives one side and climbs the other, plane-in-a-turn look).
@export_range(0.0, 1.0, 0.01) var disc_tilt: float = 0.0
## Max inclination disc_tilt = 1 maps to.
@export_range(0.0, 85.0, 1.0) var max_disc_tilt_degrees: float = 60.0
## Control points per lap (more = smoother bake on long multi-lap paths).
@export_range(8, 48, 1) var points_per_lap: int = 20
#endregion

#region Public functions
func build_curve() -> Curve3D:
	var curve := Curve3D.new()
	var n := maxi(2, points_per_lap * laps + 1)
	var step := 1.0 / float(n - 1)
	var h := step * 0.25  # finite-difference window for tangents
	for i in n:
		var u := float(i) * step
		var p := _sample(u)
		var vel := (_sample(u + h) - _sample(u - h)) / (2.0 * h)
		var handle := vel * (step / 3.0)  # cubic-bezier handle ≈ velocity * Δu / 3
		curve.add_point(p, -handle, handle)
	return curve
#endregion

#region Private functions
# A constant-radius loop anchored at the origin: it passes through home at θ = 0 (start)
# and closes there again after an integer number of laps. `disc_tilt` rotates the loop's
# lateral sweep into the vertical, banking the whole circle; `height` lifts it into an
# arc that rises to mid-flight and settles back down to the takeoff spot.
func _sample(u: float) -> Vector3:
	var theta := TAU * float(laps) * u
	var t := deg_to_rad(disc_tilt * max_disc_tilt_degrees)
	var span := radius * sin(theta)            # lateral arm of the loop
	var depth := -radius * (1.0 - cos(theta))  # forward arm (-Z), passes home at θ = 0
	return Vector3(
		span * cos(t),
		height * sin(PI * u) + span * sin(t),
		depth)
#endregion
