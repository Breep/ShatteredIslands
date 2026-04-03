class_name DeflectionShield
extends Summon

enum Modifier {
	BLOCKED_PROJECTILES,
	SHIELD_PER_BLOCK,
}

var _blocked_projectiles: int
var _shield_per_block: float

@onready var _projectile_detector: Area3D = %ProjectileDetector

func init(blocked_projectiles: int, shield_per_block: float) -> Summon:
	_blocked_projectiles = blocked_projectiles
	_shield_per_block = shield_per_block
	return self


func _ready() -> void:
	base_stats.health_max = _blocked_projectiles
	_health_bar.setup_grid_bar(1, -1)
	take_status(Status.Type.INVULNERABLE, -1, "Invulnerable")
	take_status(Status.Type.UNTARGETABLE, -1, "Untargetable")
	stat_modifiers_registry.recompute_all()
	_movement_module.orbit_entity(summoner, 2, 2, MovementModule.OrbitFacing.ANTI_CENTER)
	super._ready()


func process_tick() -> void:
	super.process_tick()
	_scan_and_destroy_projectiles()


func _on_died() -> void:
	super._on_died()
	_play_fall_anim()


func _play_fall_anim() -> void:
	var tween := create_tween().set_parallel()
	tween.tween_property(_visual_3d, "position:y", 0.0, 0.6) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(_visual_3d, "rotation:z", deg_to_rad(25.0), 0.6) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _scan_and_destroy_projectiles() -> void:
	if is_dead(): return
	for area in _projectile_detector.get_overlapping_areas():
		if not (area is Projectile): continue
		var projectile: Projectile = area
		if projectile.get_source() != null and projectile.get_source().team == summoner.team: continue
		projectile.queue_free()
		stats.health -= 1
