extends Control

@onready var _max_health_text_edit: TextEdit = %MaxHealthTextEdit
@onready var _current_health_text_edit: TextEdit = %CurrentHealthTextEdit

@onready var _poison_stacks_text_edit: TextEdit = %PoisonTextEdit
@onready var _armor_stacks_text_edit: TextEdit = %ArmorTextEdit
@onready var _ignite_stacks_text_edit: TextEdit = %IgniteStacksTextEdit
@onready var _regen_stacks_text_edit: TextEdit = %RegenStacksTextEdit

@onready var _mana_regen_text_edit: TextEdit = %ManaRegenTextEdit
@onready var _max_mana_text_edit: TextEdit = %MaxManaTextEdit

@onready var _damage_text_edit: TextEdit = %DamageTextEdit
@onready var _variation_text_edit: TextEdit = %VariationTextEdit

@onready var _magical_text_edit: TextEdit = %MagicalDamageTextEdit
@onready var _magical_variation_text_edit: TextEdit = %MagicalVariationTextEdit

@onready var _heal_text_edit: TextEdit = %HealTextEdit

@onready var _popup_positioner: Control = %RandomPopupStartPositioner

@onready var _entity_stats_left: UIEntityStats = %EntityStatsLeft
@onready var _entity_stats_right: UIEntityStats = %EntityStatsRight

const DARK_KNIGHT_SCENE : PackedScene = preload("res://Entities/Heroes/DarkKnight/dark_knight.tscn")

var _dark_knight: DarkKnight

@onready var _rng:= RandomNumberGenerator.new()

const UI_LABEL_POPUP_SCENE: PackedScene = preload("res://UI/InGame/FightingArea/EntityStats/LabelPopup/ui_label_popup.tscn")

func _ready() -> void:
	_rng.randomize()
	
	_dark_knight = DARK_KNIGHT_SCENE.instantiate()
	_dark_knight.hero_id = HeroDesc.HeroId.DARK_KNIGHT

	add_child(_dark_knight)
	_dark_knight.base_stats.reset_from_hero_desc(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT], 10)
	_dark_knight.stats.reset_from_hero_desc(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT], 10)
	_entity_stats_left.connect_entity(_dark_knight)
	_entity_stats_right.connect_entity(_dark_knight)


#region Start/Stop Battle
func _on_start_battle_pressed() -> void:
	_dark_knight.fighting_state = Hero.FightingState.FIGHTING


func _on_end_battle_pressed() -> void:
	_dark_knight.fighting_state = Hero.FightingState.CELEBRATING
#endregion

#region Stacks
#region ===== STACKS -> POISON
func _on_add_poison_button_pressed() -> void:
	var poison_stacks: int = int(_poison_stacks_text_edit.text)
	if poison_stacks >= 0:
		_dark_knight.take_condition_stacks(poison_stacks, Stack.Type.POISON, false, "Proto")

func _on_add_poison_button_critical_pressed() -> void:
	var poison_stacks: int = int(_poison_stacks_text_edit.text)
	if poison_stacks >= 0:
		_dark_knight.take_condition_stacks(poison_stacks*2, Stack.Type.POISON, true, "Proto")

func _on_reset_poison_button_pressed() -> void:
	_dark_knight.conditions.poison_stacks = 0
#endregion

#region ===== STACKS -> ARMOR
func _on_add_armor_button_pressed() -> void:
	var armor_stacks: int = int(_armor_stacks_text_edit.text)
	if armor_stacks >= 0:
		_dark_knight.take_condition_stacks(armor_stacks, Stack.Type.SHIELD, false, "Proto")

func _on_add_armor_button_critical_pressed() -> void:
	var armor_stacks: int = int(_armor_stacks_text_edit.text)
	if armor_stacks >= 0:
		_dark_knight.take_condition_stacks(armor_stacks*2, Stack.Type.SHIELD, true, "Proto")

func _on_reset_armor_button_pressed() -> void:
	_dark_knight.conditions.shield_stacks = 0
#endregion

#region ===== STACKS -> IGNITE
func _on_add_ignite_button_pressed() -> void:
	var ignite_stacks: int = int(_ignite_stacks_text_edit.text)
	if ignite_stacks >= 0:
		_dark_knight.take_condition_stacks(ignite_stacks, Stack.Type.IGNITE, false, "Proto")

func _on_add_ignite_button_critical_pressed() -> void:
	var ignite_stacks: int = int(_ignite_stacks_text_edit.text)
	if ignite_stacks >= 0:
		_dark_knight.take_condition_stacks(ignite_stacks*2, Stack.Type.IGNITE, true, "Proto")

func _on_reset_ignite_button_pressed() -> void:
	_dark_knight.conditions.ignite_stacks = 0
#endregion

#region ===== STACKS -> REGEN
func _on_add_regen_button_pressed() -> void:
	var regen_stacks: int = int(_regen_stacks_text_edit.text)
	if regen_stacks >= 0:
		_dark_knight.take_condition_stacks(regen_stacks, Stack.Type.REGEN, false, "Proto")

func _on_add_regen_button_critical_pressed() -> void:
	var regen_stacks: int = int(_regen_stacks_text_edit.text)
	if regen_stacks >= 0:
		_dark_knight.take_condition_stacks(regen_stacks*2, Stack.Type.REGEN, true, "Proto")

func _on_reset_regen_button_pressed() -> void:
	_dark_knight.conditions.regen_stacks = 0
#endregion
#endregion

#region Attack
func _on_deal_physical_damage_button_pressed() -> void:
	var damage_raw := int(_damage_text_edit.text)
	var variation := int(_variation_text_edit.text)
	var damage: int = _rng.randi_range(clampi(damage_raw - variation, 0, 10000), clampi(damage_raw + variation, 0, 10000))
	_dark_knight.take_damage(damage, Utils.ActionType.DAMAGE_PHYSICAL, false, "Proto")


func _on_deal_critical_damage_button_pressed() -> void:
	var damage_raw := int(_damage_text_edit.text)
	var variation := int(_variation_text_edit.text)
	var damage: int = _rng.randi_range(clampi(damage_raw - variation, 0, 10000), clampi(damage_raw + variation, 0, 10000))
	_dark_knight.take_damage(damage*2, Utils.ActionType.DAMAGE_PHYSICAL, true, "Proto")


func _on_deal_magical_damage_button_pressed() -> void:
	var damage_raw := int(_magical_text_edit.text)
	var variation := int(_magical_variation_text_edit.text)
	var damage: int = _rng.randi_range(clampi(damage_raw - variation, 0, 10000), clampi(damage_raw + variation, 0, 10000))
	_dark_knight.take_damage(damage, Utils.ActionType.DAMAGE_MAGICAL, false, "Proto")


func _on_deal_magical_damage_critical_pressed() -> void:
	var damage_raw := int(_magical_text_edit.text)
	var variation := int(_magical_variation_text_edit.text)
	var damage: int = _rng.randi_range(clampi(damage_raw - variation, 0, 10000), clampi(damage_raw + variation, 0, 10000))
	_dark_knight.take_damage(damage*2, Utils.ActionType.DAMAGE_MAGICAL, true, "Proto")
#endregion

#region Mana
func _on_set_mana_regen_button_pressed() -> void:
	pass

func _on_set_max_mana_button_pressed() -> void:
	pass # Replace with function body.
#endregion


#region Health
func _on_set_current_health_button_pressed() -> void:
	var health: int = int(_current_health_text_edit.text)
	if health >= 0:
		_dark_knight.stats.health = health

func _on_set_max_health_button_pressed() -> void:
	var max_health: int = int(_max_health_text_edit.text)
	if max_health >= 0:
		_dark_knight.stats.health_max = max_health
#endregion


#region Heal
func _on_heal_button_pressed() -> void:
	var heal: int = int(_heal_text_edit.text)
	if heal >= 0:
		_dark_knight.take_heal(heal, false, "Proto")

func _on_heal_button_critical_pressed() -> void:
	var heal: int = int(_heal_text_edit.text)
	if heal >= 0:
		_dark_knight.take_heal(heal*2, true, "Proto")
#endregion

#region Random POPUP
const DAMAGE_TYPES: Array[Utils.ActionType] = [
	Utils.ActionType.DAMAGE_PHYSICAL,
	Utils.ActionType.DAMAGE_MAGICAL,
	Utils.ActionType.DAMAGE_POISON,
	Utils.ActionType.UTILITY_HEAL,
]
const STACK_TYPES: Array[Stack.Type] = [
	Stack.Type.POISON,
	Stack.Type.IGNITE,
	Stack.Type.REGEN,
	Stack.Type.SHIELD,
]
func _on_random_popup_button_pressed() -> void:
	if (_rng.randi() % 2 == 0):
		var random_value: int = _rng.randi_range(1, 200)
		var random_type: Utils.ActionType = DAMAGE_TYPES.pick_random()
		var is_critical: bool = (_rng.randi() % 5 == 0)
		var label_popup: LabelPopup = UI_LABEL_POPUP_SCENE.instantiate().setup_damage(random_value, random_type, _popup_positioner.global_position, is_critical)
		add_child(label_popup)
	else:
		var random_value: int = _rng.randi_range(1, 200)
		var random_type: Utils.ActionType = STACK_TYPES.pick_random()
		var is_critical: bool = (_rng.randi() % 5 == 0)
		var label_popup: LabelPopup = UI_LABEL_POPUP_SCENE.instantiate().setup_stack(random_value, random_type, _popup_positioner.global_position, is_critical)
		add_child(label_popup)
#endregion
