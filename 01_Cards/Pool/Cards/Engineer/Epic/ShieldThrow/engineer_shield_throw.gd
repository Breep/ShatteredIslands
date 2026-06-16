class_name EngineerShieldThrow
extends CardEffect

## Engineer — quand le shield a absorbé un seuil de dégâts cumulés, lance un
## bouclier qui inflige des dégâts magiques (ratio de l'AP du porteur) et rebondit
## entre les ennemis, regénérant du shield par cible touchée.

@export var _threshold: Array[float]
@export var _damage: Array[float]
@export var _damage_ratio: Array[float]
@export var _shield_return: Array[float]
@export var _bounces: Array[float]

enum {
	ACCUMULATED_LOSS,
	LAST_SHIELD
}

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var threshold: int = int(_threshold[card_lvl - 1])
	var damage: float = _damage[card_lvl - 1]
	var damage_ratio: float = _damage_ratio[card_lvl - 1]
	var shield_return: float = _shield_return[card_lvl - 1]
	var bounce: float = _bounces[card_lvl - 1]
	var state := {ACCUMULATED_LOSS: 0, LAST_SHIELD: 0}

	var trigger_shield_throw := func() -> void:
		var target: Entity = owner.target.get_target(TargetComponent.TargettingStrategy.CLOSEST_ENEMY)
		if target == null: return
		var proj_stats := ProjectileStats.new()
		proj_stats.bounces_remaining = bounce
		proj_stats.on_hit_callbacks.append(func(cb_vars: Dictionary) -> void:
			if not cb_vars.has(ProjectileStats.VarType.TARGET):
				return
			var hit_target: Entity = cb_vars[ProjectileStats.VarType.TARGET]
			if hit_target == null or not is_instance_valid(hit_target):
				return
			var total_damage: float = damage \
				+ damage_ratio * owner.stats.get_stat(EntityStats.StatType.AP)
			if total_damage > 0:
				owner.damage.direct(hit_target, total_damage, Utils.ActionType.DAMAGE_MAGICAL, card_name)
			if shield_return > 0:
				owner.alterations.inflict_condition_stacks(owner, shield_return, Alteration.Type.SHIELD, card_name)
		)
		owner.projectile.projectile_attack(target, Projectile.Type.SHIELD_THROW, owner, proj_stats)

	var on_shield_changed: Callable
	on_shield_changed = func(new_val: int) -> void:
		var loss: int = state[LAST_SHIELD] - new_val
		state[LAST_SHIELD] = new_val
		if loss <= 0:
			return
		state[ACCUMULATED_LOSS] += loss
		while threshold > 0 and state[ACCUMULATED_LOSS] >= threshold:
			state[ACCUMULATED_LOSS] -= threshold
			trigger_shield_throw.call()

	owner.battle_callback_registry.register_battle_start(card_name, func() -> void:
		state[ACCUMULATED_LOSS] = 0
		state[LAST_SHIELD] = owner.alterations.shield_stacks
		if not owner.alterations.shield_stacks_changed.is_connected(on_shield_changed):
			owner.alterations.shield_stacks_changed.connect(on_shield_changed)
	)
	owner.battle_callback_registry.register_battle_end(card_name, func() -> void:
		if owner.alterations.shield_stacks_changed.is_connected(on_shield_changed):
			owner.alterations.shield_stacks_changed.disconnect(on_shield_changed)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	var s: String = str(_threshold[card_lvl - 1]).pad_decimals(0)
	var d: String = str(_damage[card_lvl - 1]).pad_decimals(0)
	var dr: String = str(_damage_ratio[card_lvl - 1] * 100.0).pad_decimals(0)
	var b: String = str(_bounces[card_lvl - 1]).pad_decimals(1)
	var sr: String = str(_shield_return[card_lvl - 1]).pad_decimals(0)
	return "Après avoir absorbé " + s + " dégâts avec le [[SHIELD]], lance un bouclier : " \
		+ d + " + " + dr + "% de sa puissance magique en [[MAGICAL_DAMAGE]], " + b \
		+ " rebonds, génère " + sr + " [[SHIELD]] par ennemi touché."
