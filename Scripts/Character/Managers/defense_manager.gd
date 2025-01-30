class_name DefenseManager
extends Node

signal armor_gained(armor_stacks: int)

var _source: Character # Ref to character owner
var _defense_stats: CharacterDefenseStats # Ref to the owner auto attack stats

func start(source: Character, defense_stats: CharacterDefenseStats) -> void:
	if source == null:
		printerr("DefenseManager: source undef")
		return
	if defense_stats == null:
		printerr("DefenseManager: defense_stats undef")
		return
	
	_source = source
	_defense_stats = defense_stats
	_create_optional_timers()


#func handle_source_took_damage_from()


func _create_optional_timers() -> void:
	# Shield yourself
	if _defense_stats.periodic_armor_stacks_amount > 0:
		Utils.create_optional_timer(self, _defense_stats.periodic_armor_stacks_period, _on_periodic_armor_stacks_timer_timeout)
	
	# Shield strike
	if _defense_stats.shield_strike_damage_percent > 0:
		Utils.create_optional_timer(self, _defense_stats.shield_strike_period, _on_shield_strike_timer_timeout)


func _on_periodic_armor_stacks_timer_timeout() -> void:
	armor_gained.emit(_defense_stats.periodic_armor_stacks_amount)


var __armor_lost_since_last_shield_strike: int = 0
func _on_shield_strike_timer_timeout() -> void:
	print("Deal armor lost to closest enemy")
