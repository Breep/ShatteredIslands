class_name ChickenLordCrumbleEggs
extends CardEffect

@export var _periods: Array[float]
@export var _damage_per_chickens: Array[float]
@export var _chicken_spawned_per_deaths: Array[int]
@export var _base_damages: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var period: float = _periods[card_lvl - 1]
	var damage_per_chicken: float = _damage_per_chickens[card_lvl - 1]
	var chicken_spawned_per_death: int = _chicken_spawned_per_deaths[card_lvl - 1]
	var base_damage: float = _base_damages[card_lvl - 1]
	
	var proj_stats := ProjectileStats.new()
	proj_stats.on_hit_callbacks.append(func(cb_vars: Dictionary) -> void:
		var hit_target: Entity = cb_vars.get(AutoAttackModifier.VarType.TARGET)
		if not is_instance_valid(hit_target): return
		var damage: float = base_damage + ctx.hero.families_stats.chicken_lord.alive_chicken_count * damage_per_chicken
		ctx.hero.damage.direct(hit_target, damage, Utils.ActionType.DAMAGE_MAGICAL, &"Crumble Egg")
		if hit_target.is_dead():
			for i in chicken_spawned_per_death:
				ctx.hero.summon.summon_entity(Entity.EntityType.CHICKEN_EGG, SpawnLocationConfig.create_entity_relative(hit_target, 1.5), {})
	)
	ctx.battle_callbacks.register_periodic("Crumble Eggs", period, func() -> void:
		var target: Entity = ctx.hero.target.get_target(TargetComponent.TargettingStrategy.LOWEST_HP_ENEMY)
		if target == null: return
		ctx.hero.projectile.projectile_attack(target, Projectile.Type.SMALL_EGG, ctx.hero, proj_stats)
		)

func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.battle_callbacks.unregister_all(&"Crumble Eggs")


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Crumble Eggs: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var p: String = str(_periods[cardlvl - 1]).pad_decimals(0)
	var dpc: String = str(_damage_per_chickens[cardlvl - 1]).pad_decimals(0)
	var cspd: String = str(_chicken_spawned_per_deaths[cardlvl - 1]).pad_decimals(0)
	return "Toutes les " + p + "s, lance un petit oeuf sur l'ennemi le plus faible. Inflige " + str(_base_damages[cardlvl - 1]) + " + " + dpc + " * <poulets vivants> [[MAGICAL_DAMAGE]]. Pond " + cspd + " oeuf en cas de kill."
