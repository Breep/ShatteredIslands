class_name UIEntityStatsContainer
extends Control

@export var _max_health_label: Label
@export var _mana_regen_label: Label
@export var _dodge_label: Label
@export var _ad_label: Label
@export var _attack_speed_label: Label
@export var _crit_chance_label: Label

func update_stats(stats: EntityStats) -> void:
	_max_health_label.text = str(stats.health_max)
	_mana_regen_label.text = str(stats.mana_regen)
	_dodge_label.text = str(20) + "%"
	_ad_label.text = str(stats.attack_damage)
	_attack_speed_label.text = str("%.1f" % stats.attack_speed)
	_crit_chance_label.text = str(int(stats.get_stat(EntityStats.StatType.CRIT_CHANCE, Utils.ActionType.DAMAGE_PHYSICAL))) + "%"
