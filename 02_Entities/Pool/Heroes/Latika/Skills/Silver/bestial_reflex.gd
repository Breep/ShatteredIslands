class_name SE_BestialReflex
extends SkillEffect

# Talent Silver "Réflexe Bestial" : quand les PV de Latika passent sous
# _hp_threshold_percent %, elle se soigne de _heal_amount, dash en arrière (loin de
# l'ennemi le plus proche) et devient inciblable _untargetable_duration s.
# Cooldown _cooldown s, ré-armé en début de combat. Survie d'urgence (voie solitaire).

@export var _hp_threshold_percent: float = 30.0
@export var _heal_amount: float = 1000.0
@export var _dash_distance: float = 4.0
@export var _dash_speed: float = 20.0
@export var _untargetable_duration: float = 2.0
@export var _cooldown: float = 15.0


func apply(ctx: SkillContext) -> void:
	var latika: Entity = ctx.entity
	if latika == null:
		Verbose.error("SE_BestialReflex: null owner", Verbose.Category.ENTITY_MODULE)
		return

	# Boxed pour vivre par instance (la resource SkillEffect peut être partagée).
	var ready_flag: Array[bool] = [true]
	var reset := func() -> void:
		ready_flag[0] = true
	latika.battle_callback_registry.register_battle_start(&"BestialReflexReset", reset)

	latika.stats.health_changed.connect(func(new_health: float) -> void:
		if not ready_flag[0] or latika.is_dead():
			return
		if new_health > latika.stats.health_max * _hp_threshold_percent / 100.0:
			return
		ready_flag[0] = false
		_trigger(latika)
		var rearm := func() -> void:
			ready_flag[0] = true
		latika.battle_callback_registry.register_oneshot(_cooldown, rearm, &"BestialReflexCooldown"))


func _trigger(latika: Entity) -> void:
	latika.heal.direct(latika, _heal_amount, &"BestialReflex")
	_dash_back(latika)
	latika.alterations.apply_state(Alteration.Type.UNTARGETABLE)
	var clear_untargetable := func() -> void:
		if is_instance_valid(latika):
			latika.alterations.cancel_state(Alteration.Type.UNTARGETABLE)
	latika.battle_callback_registry.register_oneshot(
		_untargetable_duration, clear_untargetable, &"BestialReflexUntargetable")


# Dash de retraite : s'éloigne de l'ennemi le plus proche (à plat), sinon recule
# selon l'orientation courante.
func _dash_back(latika: Entity) -> void:
	var away: Vector3
	var enemy: Entity = latika.target.get_target(TargetComponent.TargettingStrategy.CLOSEST_ENEMY)
	if is_instance_valid(enemy):
		away = latika.global_position - enemy.global_position
		away.y = 0.0
	if not is_instance_valid(enemy) or away.length() < 0.01:
		away = -latika.global_transform.basis.z
		away.y = 0.0
	away = away.normalized()
	latika.movement.rush(_dash_speed, latika.global_position + away * _dash_distance)
