class_name EngineerAegisBlade
extends HeroUpgrade

@export var _attack_speeds: Array[float]
@export var _shield_as_ad_ratios: Array[float]
@export var _damage_as_shield_ratios: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Aegis Blade: Wrong card_lvl: ", card_lvl)
		return
	
	var attack_speed: float = _attack_speeds[card_lvl - 1]
	var shield_as_ad_ratio: float = _shield_as_ad_ratios[card_lvl - 1]
	var damage_as_shield_ratio: float = _damage_as_shield_ratios[card_lvl - 1]
	
	ctx.battle_callbacks.register_battle_start("Aegis Blade", func() -> void:
		var spawn_loc := SpawnLocationConfig.create_arena_center(5)
		ctx.hero.summon_entity(Entity.EntityType.AEGIS_BLADE, spawn_loc, {
			AegisBlade.Modifier.AS: attack_speed,
			AegisBlade.Modifier.SHIELD_AS_AD: shield_as_ad_ratio,
			AegisBlade.Modifier.DAMAGE_AS_SHIELD: damage_as_shield_ratio
		})
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Aegis Blade: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return ""
