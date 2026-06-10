class_name ChickenLordUndyingBrood
extends CardEffect

## Chicken Lord (Légendaire) — à la mort d'un summon du héros, une chance qu'il
## réapparaisse quelques secondes plus tard, au même endroit, avec une fraction
## de ses PV max. Générique : fonctionne pour tout type de summon (via
## Entity.spawned_entity_type). Un summon déjà ressuscité ne re-ressuscite pas.

const RESPAWN_DELAY: float = 3.0

@export var _respawn_chance: Array[float]
@export var _hp_percent: Array[float]

var _on_detected: Callable

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var chance: float = _respawn_chance[card_lvl - 1]
	var hp_percent: float = _hp_percent[card_lvl - 1]

	_on_detected = func(e: Entity) -> void:
		if not _is_owned_summon(e, owner): return
		e.died.connect(func() -> void:
			_try_respawn(e, owner, chance, hp_percent, card_name)
		, CONNECT_ONE_SHOT)
	owner.target.new_entity_detected.connect(_on_detected)


func revert(ctx: CardContext, _card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	if _on_detected.is_valid() and owner.target.new_entity_detected.is_connected(_on_detected):
		owner.target.new_entity_detected.disconnect(_on_detected)


func _try_respawn(dead: Entity, owner: Entity, chance: float, hp_percent: float, card_name: StringName) -> void:
	if not is_instance_valid(dead) or not is_instance_valid(owner): return
	# Un summon issu d'un respawn ne déclenche pas un nouveau respawn (anti-boucle).
	if dead.has_meta(&"sl_respawned"): return
	if not Utils.is_randomize_modifier_active(chance, owner.battle_id): return

	var entity_type: Entity.EntityType = dead.spawned_entity_type
	var spawn_pos: Vector3 = dead.global_position

	owner.battle_callback_registry.register_oneshot(RESPAWN_DELAY, func() -> void:
		if not is_instance_valid(owner) or owner.summon == null: return
		var revived: Entity = owner.summon.summon_entity(entity_type, SpawnLocationConfig.create_exact(spawn_pos), {})
		if not is_instance_valid(revived): return
		revived.set_meta(&"sl_respawned", true)
		if revived.stats != null:
			revived.stats.health = revived.stats.health_max * hp_percent / 100.0
	, StringName(String(card_name) + "_respawn_" + str(dead.uid)))


func _is_owned_summon(e: Entity, owner: Entity) -> bool:
	return e != null and is_instance_valid(e) and e.is_summoned() and e.summoner == owner


func get_description(card_lvl: int) -> String:
	return "Mort de summon : " + str(_respawn_chance[card_lvl - 1]) + "% de chance qu'il réapparaisse " \
		+ str(RESPAWN_DELAY) + "s plus tard au même endroit avec " + str(_hp_percent[card_lvl - 1]) + "% PV."
