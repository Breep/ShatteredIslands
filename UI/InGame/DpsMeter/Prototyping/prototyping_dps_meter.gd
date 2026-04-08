extends Control

const HERO_NAMES: Array[String] = ["Warrior", "Mage", "Assassin", "Healer", "Tank", "Ranger", "Paladin", "Necro"]
const ACTION_NAMES: Array[String] = ["Auto Attack", "Spell 1", "Spell 2", "Ultimate", "Passive", "Item"]

@export var _dps_meter: UIDPSMeter
@export var _hero_count_spinbox: SpinBox
@export var _hero_selector: OptionButton
@export var _status_label: Label

var _heroes: Array[Hero]
var _players: Array[Player]


#region ============================== Node base functions ==============================
func _ready() -> void:
	GameManager.init()
	pass
#endregion



#region ============================== Setup ==============================
func _on_setup_button_pressed() -> void:
	_cleanup()
	var count: int = int(_hero_count_spinbox.value)
	for i: int in count:
		var player := Player.new()
		player.player_name = HERO_NAMES[i]
		_players.append(player)

		var hero := Hero.new()
		hero.entity_name = HERO_NAMES[i]
		hero.player = player
		hero.bds_registry = EntityBDSRegistry.new(hero)
		_heroes.append(hero)

	_dps_meter.set_heroes(_heroes)
	_update_hero_selector()
	_status_label.text = str(count) + " heroes created"
#endregion



#region ============================== Hero Selector ==============================
func _update_hero_selector() -> void:
	_hero_selector.clear()
	_hero_selector.add_item("-- None --")
	for hero: Hero in _heroes:
		_hero_selector.add_item(hero.entity_name)


func _on_hero_selector_item_selected(index: int) -> void:
	if index == 0:
		_dps_meter._rebuild_hero_bds_viewers(null)
	else:
		_dps_meter._rebuild_hero_bds_viewers(_heroes[index - 1])
#endregion



#region ============================== Random Actions ==============================
func _on_add_random_action_button_pressed() -> void:
	if _heroes.is_empty(): return
	var hero: Hero = _heroes.pick_random()
	_register_random_action_on(hero)


func _on_add_random_all_button_pressed() -> void:
	for hero: Hero in _heroes:
		_register_random_action_on(hero)


func _register_random_action_on(hero: Hero) -> void:
	var action_id: StringName = StringName(ACTION_NAMES.pick_random())
	var all_action_types: Array[Utils.ActionType] = [
		Utils.ActionType.DAMAGE_PHYSICAL, Utils.ActionType.DAMAGE_MAGICAL,
		Utils.ActionType.DAMAGE_POISON, Utils.ActionType.DAMAGE_PURE,
		Utils.ActionType.UTILITY_HEAL,
		Utils.ActionType.STACK_SHIELD, Utils.ActionType.STACK_IGNITE,
		Utils.ActionType.STACK_POISON, Utils.ActionType.STACK_REGEN,
		Utils.ActionType.STATUS_STUN, Utils.ActionType.STATUS_TAUNT,
	]
	var action_type: Utils.ActionType = all_action_types.pick_random()
	var value: float = randf_range(5.0, 50.0)
	hero.bds_registry.register_action(action_id, action_type, value, false)
#endregion



#region ============================== Cleanup ==============================
func _on_reset_button_pressed() -> void:
	_cleanup()
	_dps_meter.set_heroes([])
	_update_hero_selector()
	_status_label.text = "Reset"


func _cleanup() -> void:
	for hero: Hero in _heroes:
		hero.free()
	for player: Player in _players:
		player.free()
	_heroes.clear()
	_players.clear()
#endregion
