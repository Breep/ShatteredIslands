class_name SE_CometeBasseCour
extends SkillEffect

# Passif "Comète de basse-cour": la première fois que le poulet passe sous _hp_threshold
# de ses PV, il se rue sur l'ennemi le plus proche, explose (AP x _ap_ignite_ratio Ignite
# dans un rayon _radius) et meurt. Le talent "Coquille solaire" relève le seuil via meta.

const THRESHOLD_META := &"celeste_comete_threshold"
const EXPLOSION_VFX := preload("res://22_VFX/VFX_Explosion_B.tscn")

@export var _hp_threshold: float = 0.35
@export var _ap_ignite_ratio: float = 2.0
@export var _radius: float = 3.0
@export var _rush_speed: float = 10.0


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	chicken.set_meta(THRESHOLD_META, _hp_threshold)

	var triggered: Array[bool] = [false]
	chicken.stats.health_changed.connect(func(new_health: float) -> void:
		if triggered[0] or chicken.stats.health_max <= 0.0:
			return
		var threshold: float = chicken.get_meta(THRESHOLD_META, _hp_threshold)
		if new_health / chicken.stats.health_max > threshold:
			return
		triggered[0] = true
		_launch_comet(chicken)
	)


func _launch_comet(chicken: Entity) -> void:
	if chicken.auto_attack != null:
		chicken.auto_attack.clear_target()
	var target: Entity = chicken.target.get_target(TargetComponent.TargettingStrategy.FARTHEST_ENEMY)
	var dest: Vector3 = target.global_position if is_instance_valid(target) else chicken.global_position
	if chicken.movement != null:
		chicken.movement.rush(_rush_speed, dest)

	chicken.battle_callback_registry.register_periodic(&"CometeArrival", 0.1, func() -> void:
		var arrived: bool = chicken.global_position.distance_squared_to(dest) < 1.0
		if is_instance_valid(target) and not target.is_dead():
			arrived = chicken.global_position.distance_squared_to(target.global_position) < 1.0
		if arrived or not is_instance_valid(target):
			chicken.battle_callback_registry.unregister(&"CometeArrival")
			_explode(chicken)
	, true)


func _explode(chicken: Entity) -> void:
	var vfx: Node3D = EXPLOSION_VFX.instantiate()
	chicken.get_tree().current_scene.add_child(vfx)
	vfx.global_position = chicken.global_position
	var anim_player: AnimationPlayer = vfx.get_node_or_null("AnimationPlayer")
	if anim_player != null:
		anim_player.play("Init")

	var ignite: float = chicken.stats.get_stat(EntityStats.StatType.AP) * _ap_ignite_ratio
	for enemy: Entity in chicken.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES, _radius):
		chicken.alterations.direct_stack(enemy, ignite, Alteration.Type.IGNITE, &"Comète de basse-cour")
	chicken.stats.health = 0


func get_description() -> String:
	return "La première fois qu'il passe sous " + _value(_hp_threshold * 100.0) \
		+ "% de ses PV, il se rue sur un ennemi et explose, infligeant [[IGNITE]] égal à " \
		+ _value(_ap_ignite_ratio) + "× son [[AP]] aux ennemis dans un rayon de " \
		+ _value(_radius) + ", puis meurt."
