class_name AttackOverdrive
extends CardEffect

## Warrior — bonus d'auto-attaque adapté au type du héros :
## héros à distance → +rebond(s) sur le projectile ; héros au corps-à-corps →
## la frappe touche une (des) cible(s) ennemie(s) supplémentaire(s) (cleave),
## avec TOUS les effets d'impact (dégâts + poison/ignite/exécution… des autres cartes).

@export var _bounce_count: Array[int]
@export var _cleave_targets: Array[int]
## Rayon (unités) autour de la cible dans lequel chercher les ennemis à cleave.
@export var _cleave_radius: float = 3.0

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var is_ranged: bool = owner.stats.auto_attack_type == EntityStats.AutoAttackType.RANGED
	var bounce: int = _bounce_count[card_lvl - 1]
	var cleave: int = _cleave_targets[card_lvl - 1]
	var radius_sq: float = _cleave_radius * _cleave_radius
	# Garde de ré-entrance : la frappe de cleave rejoue les effets d'auto-attaque
	# (donc ce callback) — sans ce flag, Overdrive se re-cleaverait à l'infini.
	var state := {&"cleaving": false}

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = card_name
	aa_mod.tags = [AutoAttackModifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.additional_effect_callback = func(cb_vars: Dictionary) -> void:
		if not is_instance_valid(owner): return
		if is_ranged:
			var proj: Projectile = cb_vars.get(AutoAttackModifier.VarType.PROJECTILE)
			if is_instance_valid(proj):
				proj.add_bounce(bounce)
			return
		# Mêlée — cleave.
		if state[&"cleaving"]: return
		var target: Entity = cb_vars.get(AutoAttackModifier.VarType.TARGET)
		if not is_instance_valid(target): return

		state[&"cleaving"] = true
		var excluded: Array[Entity] = [target]
		for i in cleave:
			var extra: Entity = owner.target.get_target_from(
				target.global_position, TargetComponent.TargettingFromStrategy.CLOSEST_ENEMY, excluded
			)
			# Plus d'ennemi, ou le plus proche est hors du rayon de cleave → stop.
			if not is_instance_valid(extra): break
			if extra.global_position.distance_squared_to(target.global_position) > radius_sq: break
			owner.auto_attack.resolve_strike(owner, extra)
			excluded.append(extra)
		state[&"cleaving"] = false

	owner.battle_callback_registry.register_battle_start(card_name, func() -> void:
		owner.auto_attack_modifier_registry.register_modifier(aa_mod)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "Si le héros est à distance : +" + _value(_bounce_count[card_lvl - 1]) \
		+ " rebond(s) d'auto-attaque. Si au corps-à-corps : la frappe touche +" \
		+ _value(_cleave_targets[card_lvl - 1]) + " cible(s) proche(s) avec tous ses effets (cleave)."
