class_name SE_ProtocoleGardien
extends SkillEffect

# Talent "Protocole gardien": la première fois qu'un héros allié passe sous _hp_threshold
# de ses PV, la Tour lui donne AP x _ap_ratio Shield (une seule fois par combat).

@export var _hp_threshold: float = 0.35
@export var _ap_ratio: float = 2.5


func apply(ctx: SkillContext) -> void:
	var tower: AegisTower = ctx.entity as AegisTower
	if tower == null:
		Verbose.error("SE_ProtocoleGardien: owner is not an AegisTower", Verbose.Category.ENTITY_MODULE)
		return

	var health_connections: Array[Dictionary] = []
	tower.battle_callback_registry.register_battle_start(&"ProtocoleGardien", func() -> void:
		_disconnect_health_changed_callbacks(health_connections)
		if not is_instance_valid(tower):
			return

		var triggered: Array[bool] = [false]
		for ally: Entity in tower.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES):
			if not is_instance_valid(ally) or ally.category != Entity.Category.HERO:
				continue
			var callback: Callable = _on_ally_health_changed.bind(tower, ally, triggered, health_connections)
			ally.stats.health_changed.connect(callback)
			health_connections.append({&"ally": ally, &"callback": callback})
	)
	tower.battle_callback_registry.register_battle_end(&"ProtocoleGardien", func() -> void:
		_disconnect_health_changed_callbacks(health_connections)
	)
	var died_callback: Callable = func(_self_ref: Entity = null) -> void:
		_disconnect_health_changed_callbacks(health_connections)
	tower.died.connect(died_callback, CONNECT_ONE_SHOT)


func get_description() -> String:
	return "La première fois qu'un héros allié passe sous " + _value(_hp_threshold * 100) \
		+ "% de ses PV, lui accorde un [[SHIELD]] égal à " + _value(_ap_ratio * 100) \
		+ "% de sa puissance magique (une fois par combat)."


func _on_ally_health_changed(new_health: float, tower: AegisTower, ally: Entity, triggered: Array[bool], connections: Array[Dictionary]) -> void:
	if triggered[0] or not is_instance_valid(tower) or not is_instance_valid(ally) or not tower.is_alive():
		return
	if ally.stats.health_max <= 0.0:
		return
	if new_health / ally.stats.health_max > _hp_threshold:
		return

	triggered[0] = true
	var shield: float = tower.stats.get_stat(EntityStats.StatType.AP) * _ap_ratio
	tower.alterations.direct_stack(ally, shield, Alteration.Type.SHIELD, &"Protocole gardien")
	_disconnect_health_changed_callbacks(connections)


func _disconnect_health_changed_callbacks(connections: Array[Dictionary]) -> void:
	for connection: Dictionary in connections:
		var ally: Entity = connection.get(&"ally") as Entity
		var callback: Callable = connection.get(&"callback")
		if is_instance_valid(ally) and ally.stats != null and ally.stats.health_changed.is_connected(callback):
			ally.stats.health_changed.disconnect(callback)
	connections.clear()
