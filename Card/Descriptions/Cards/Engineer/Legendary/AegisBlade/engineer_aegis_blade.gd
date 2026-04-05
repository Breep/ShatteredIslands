class_name EngineerAegisBlade
extends HeroUpgrade

@export var _attack_ads: Array[float]
@export var _attack_speeds: Array[float]
@export var _shield_ad_maxs: Array[float]   # Asymptote : AD max apportée par le shield (a)
@export var _shield_ad_taus: Array[float]   # Montée : shield pour atteindre ~63% du max (Tau)
@export var _damage_as_shield_ratios: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Aegis Blade: Wrong card_lvl: ", card_lvl)
		return
	
	var attack_damage: float = _attack_ads[card_lvl - 1]
	var attack_speed: float = _attack_speeds[card_lvl - 1]
	var shield_ad_max: float = _shield_ad_maxs[card_lvl - 1]
	var shield_ad_tau: float = _shield_ad_taus[card_lvl - 1]
	var damage_as_shield_ratio: float = _damage_as_shield_ratios[card_lvl - 1]
	
	ctx.battle_callbacks.register_battle_start(&"Aegis Blade", func() -> void:
		var spawn_loc := SpawnLocationConfig.create_arena_center(5)
		ctx.hero.summon_entity(Entity.EntityType.AEGIS_BLADE, spawn_loc, {
			AegisBlade.Modifier.AD: attack_damage,
			AegisBlade.Modifier.AS: attack_speed,
			AegisBlade.Modifier.SHIELD_AD_MAX: shield_ad_max,
			AegisBlade.Modifier.SHIELD_AD_TAU: shield_ad_tau,
			AegisBlade.Modifier.DAMAGE_AS_SHIELD: damage_as_shield_ratio
		})
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Aegis Blade: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	var base_dmg: String = str(_attack_ads[cardlvl - 1])
	var shield_ad: String = str(_shield_ad_maxs[cardlvl - 1])
	var return_shield: String = str(_damage_as_shield_ratios[cardlvl - 1])
	
	return "Summon an Aegis blade with AD: " + base_dmg + " + " + shield_ad + "% of the hero [[SHIELD]]. Gives " + return_shield + "% of the AD as [[SHIELD]]."
