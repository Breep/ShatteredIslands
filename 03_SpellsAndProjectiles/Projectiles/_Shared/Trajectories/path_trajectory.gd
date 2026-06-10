class_name PathTrajectory
extends ProjectileTrajectory

## Suit une Curve3D dont la FIN est le point d'impact. À l'init, la position de
## la cible est figée (snapshot) et la fin de la courbe y est ancrée : le
## projectile parcourt la courbe de son début (typiquement en l'air) jusqu'à sa
## fin, qui retombe exactement là où était la cible au moment du tir. Ne suit
## pas une cible mobile (météore, frappe en piqué…).
##
## Avancée à `speed` (hérité) modulée par un facteur qui démarre à
## `start_speed_ratio` (x% de la speed) puis croît sans plafond le long du
## path, façonné par `progress_power` :
##   facteur = start_speed_ratio + pow(progress, progress_power)
##   - progress_power = 1 : croissance linéaire à partir de x%
##   - progress_power > 1 : reste lent longtemps puis accélère fort à la fin
##     (effet chute / gravité, cf. meteor_visual.gd)
##
## Authoring : dessine la courbe en espace local "impact" — le DERNIER point est
## le point de chute, les points précédents décrivent d'où vient le projectile
## (ciel, côté…). Cf. meteor_curve_3d.tres : ciel (10, 50, 10) -> impact (0, 0, 0).

@export var curve: Curve3D
## Fraction de speed au démarrage (0..1). Doit rester > 0, sinon le projectile
## ne démarre jamais.
@export var start_speed_ratio: float = 0.1
## Exposant de la croissance du facteur de vitesse le long du path.
@export var progress_power: float = 2.0

var _dist: float = 0.0
var _baked_length: float = 0.0
var _anchor: Vector3 = Vector3.ZERO
var _impact_local: Vector3 = Vector3.ZERO
var _prev_world: Vector3 = Vector3.ZERO


func _on_init() -> void:
	_capture_anchor()
	if curve != null and curve.point_count >= 2:
		_baked_length = curve.get_baked_length()
		_impact_local = curve.sample_baked(_baked_length)
		_prev_world = _world_at(0.0)
		if _projectile:
			_projectile.global_position = _prev_world


func _on_retarget() -> void:
	_dist = 0.0
	_capture_anchor()
	_prev_world = _world_at(0.0)


func update(logic_pos: Vector3, delta: float) -> Vector3:
	if curve == null or curve.point_count < 2:
		return logic_pos
	var progress: float = clampf(_dist / maxf(_baked_length, 0.0001), 0.0, 1.0)
	var factor: float = start_speed_ratio + pow(progress, progress_power)
	_dist += speed * factor * delta
	var world_point: Vector3 = _world_at(_dist)
	_face(_prev_world, world_point)
	_prev_world = world_point
	return world_point


# Convertit une distance le long de la courbe en position monde : la fin de la
# courbe (impact) est recalée sur l'ancre (position figée de la cible).
func _world_at(dist: float) -> Vector3:
	return _anchor + (curve.sample_baked(dist) - _impact_local)


func _capture_anchor() -> void:
	if is_instance_valid(_target):
		_anchor = _target.global_position


# Oriente le visuel sur la tangente. Bascule l'axe up si la chute est quasi
# verticale, pour éviter le warning look_at (direction colinéaire à UP).
func _face(from: Vector3, to: Vector3) -> void:
	if not _projectile: return
	var dir: Vector3 = to - from
	if dir.length_squared() == 0.0: return
	var up: Vector3 = Vector3.UP
	if absf(dir.normalized().dot(Vector3.UP)) > 0.99:
		up = Vector3.FORWARD
	_projectile.look_at(to, up)
