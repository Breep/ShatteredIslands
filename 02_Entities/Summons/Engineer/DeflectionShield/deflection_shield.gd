class_name DeflectionShield
extends Entity


func _init() -> void:
	super._init()
	_despawn_timer = 5.0
	category = Category.SUMMON

enum Modifier {
	BLOCKED_PROJECTILES,
	SHIELD_PER_BLOCK,
	RESPAWN_TIMER
}

var _blocked_projectiles: int
var _shield_per_block: float
var _respawn_timer: float

@onready var _projectile_detector: Area3D = %ProjectileDetector

func init(blocked_projectiles: int, shield_per_block: float, respawn_timer: float = -1.0) -> Entity:
	_blocked_projectiles = blocked_projectiles
	_shield_per_block = shield_per_block
	_respawn_timer = respawn_timer
	return self


func _ready() -> void:
	base_stats.health_max = _blocked_projectiles
	_health_bar.setup_grid_bar(1, -1)
	alterations.take_status(Alteration.Type.INVULNERABLE, -1, "Invulnerable")
	alterations.take_status(Alteration.Type.UNTARGETABLE, -1, "Untargetable")
	stat_modifiers_registry.recompute_all()
	movement.orbit_entity(summoner, 2, 2, MovementComponent.OrbitFacing.ANTI_CENTER)
	_despawn_timer = -1 # No despawn
	super._ready()


func process_tick() -> void:
	super.process_tick()
	_scan_and_destroy_projectiles()


func _on_died() -> void:
	super._on_died()
	_play_fall_anim()
	if _respawn_timer > 0:
		periodic_timer_registry.register_oneshot(_respawn_timer, resurrect.bind(100))


func _on_resurrected() -> void:
	super._on_resurrected()
	base_stats.health_max = _blocked_projectiles
	stat_modifiers_registry.recompute_all()
	alterations.take_status(Alteration.Type.INVULNERABLE, -1, "Invulnerable")
	alterations.take_status(Alteration.Type.UNTARGETABLE, -1, "Untargetable")
	_health_bar.setup_grid_bar(1, -1)
	var tween := create_tween().set_parallel()
	tween.tween_property(_visual_3d, "position:y", 2.8, 0.8) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(_visual_3d, "rotation:z", 0.0, 0.8) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(func() -> void:
		movement.orbit_entity(summoner, 2, 2, MovementComponent.OrbitFacing.ANTI_CENTER)
	)


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
