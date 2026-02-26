extends Control

#region ============================== Battle data stat viewer ==============================
@export var _bds_viewer: UIBattleDataStatViewer

@onready var _bds := BattleDataStat.new("TEST", BattleDataStat.Type.DAMAGE_DONE)

func _on_create_bds_button_pressed() -> void:
	_bds_viewer.connect_battle_data_stat(_bds)


func _on_add_physical_damage_button_pressed() -> void:
	_bds.register_action(Utils.ActionType.DAMAGE_PHYSICAL, 10)


func _on_add_magical_damage_button_pressed() -> void:
	_bds.register_action(Utils.ActionType.DAMAGE_MAGICAL, 10)


func _on_add_poison_damage_button_pressed() -> void:
	_bds.register_action(Utils.ActionType.DAMAGE_POISON, 10)


func _on_add_pure_damage_button_pressed() -> void:
	_bds.register_action(Utils.ActionType.DAMAGE_PURE, 12)
#endregion

#region ============================== Battle data stats panel ==============================
@export var _battle_data_stat_panel: UIBattleDataStatsPanel

var _battle_data_stats: Array[BattleDataStat]

func _on_add_bds_button_pressed() -> void:
	var i: int = _battle_data_stats.size()
	var bds := BattleDataStat.new("TEST" + str(i), BattleDataStat.Type.DAMAGE_DONE)
	_battle_data_stats.append(bds)
	_battle_data_stat_panel.add_battle_data_stat(bds)


func _add_random_value() -> void:
	if _battle_data_stats.is_empty(): return
	var bds: BattleDataStat = _battle_data_stats.pick_random()
	match bds.type:
		BattleDataStat.Type.DAMAGE_DONE:
			var r: int = randi()
			if r % 3 == 0: bds.register_action(Utils.ActionType.DAMAGE_PHYSICAL, 10)
			if r % 3 == 1: bds.register_action(Utils.ActionType.DAMAGE_MAGICAL, 10)
			if r % 3 == 2: bds.register_action(Utils.ActionType.DAMAGE_POISON, 10)


func _on_add_random_value_pressed() -> void:
	_add_random_value()
#endregion


var _bds_number: int = 0
@onready var _entity_bds_registry := EntityBDSRegistry.new("Breep")

@export var _ui_entity_bds_registry: UIEntityBDSRegistry

func _ready() -> void:
	_ui_entity_bds_registry.connect_entity_bds_registry(_entity_bds_registry)

#region ============================== Entity BDS Registry ==============================

#endregion


func _on_add_damage_done_button_pressed() -> void:
	_entity_bds_registry.register_action("TEST" + str(_bds_number), Utils.ActionType.DAMAGE_PHYSICAL, 10, false)
	_bds_number += 1


func _on_add_damage_received_button_pressed() -> void:
	_entity_bds_registry.register_interaction("TEST" + str(_bds_number), Utils.ActionType.DAMAGE_PHYSICAL, 10, false)
	_bds_number += 1


func _on_add_stack_inflicted_button_pressed() -> void:
	_entity_bds_registry.register_action("TEST" + str(_bds_number), Utils.ActionType.STACK_SHIELD, 10, false)
	_bds_number += 1


func _on_add_stack_received_button_pressed() -> void:
	_entity_bds_registry.register_interaction("TEST" + str(_bds_number), Utils.ActionType.STACK_SHIELD, 10, false)
	_bds_number += 1


func _on_add_heal_done_pressed() -> void:
	_entity_bds_registry.register_action("TEST" + str(_bds_number), Utils.ActionType.UTILITY_HEAL, 10, false)
	_bds_number += 1


func _on_add_heal_received_pressed() -> void:
	_entity_bds_registry.register_interaction("TEST" + str(_bds_number), Utils.ActionType.UTILITY_HEAL, 10, false)
	_bds_number += 1


func _on_add_misc_done_pressed() -> void:
	_entity_bds_registry.register_action("TEST" + str(_bds_number), Utils.ActionType.STATUS_STUN, 10, false)
	_bds_number += 1


func _on_add_misc_received_pressed() -> void:
	_entity_bds_registry.register_interaction("TEST" + str(_bds_number), Utils.ActionType.STATUS_STUN, 10, false)
	_bds_number += 1
