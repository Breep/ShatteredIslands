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

const CHARACTER_SCENE : PackedScene = preload("res://Entities/Character/character.tscn")

var _character: Character

@onready var _rng:= RandomNumberGenerator.new()

const UI_LABEL_POPUP_SCENE: PackedScene = preload("res://UI/InGame/FightingArea/EntityStats/LabelPopup/ui_label_popup.tscn")

func _ready() -> void:
	_rng.randomize()
	
	_character = CHARACTER_SCENE.instantiate()
	_character.player = Player.new()
	_character.player.skill_manager = SkillManager.new()
	_character.player.character = _character
	_character.hero_id = Hero.HeroId.DARK_KNIGHT
	
	add_child(_character)
	_character.base_stats.reset_from_hero(Shared.HEROES[Hero.HeroId.DARK_KNIGHT], 10)
	_character.stats.reset_from_hero(Shared.HEROES[Hero.HeroId.DARK_KNIGHT], 10)
	_entity_stats_left.connect_entity(_character)
	_entity_stats_right.connect_entity(_character)


#region Start/Stop Battle
func _on_start_battle_pressed() -> void:
	_character.fighting_state = Character.FightingState.POSITIONING
	_character.fighting_state = Character.FightingState.FIGHTING


func _on_end_battle_pressed() -> void:
	_character.fighting_state = Character.FightingState.CELEBRATING
#endregion

#region Stacks
#region ===== STACKS -> POISON
func _on_add_poison_button_pressed() -> void:
	var poison_stacks: int = int(_poison_stacks_text_edit.text)
	if poison_stacks >= 0:
		_character.take_condition_stacks(poison_stacks, Utils.StackType.POISON)

func _on_add_poison_button_critical_pressed() -> void:
	var poison_stacks: int = int(_poison_stacks_text_edit.text)
	if poison_stacks >= 0:
		_character.take_condition_stacks(poison_stacks, Utils.StackType.POISON)

func _on_reset_poison_button_pressed() -> void:
	_character.stats.poison_stacks = 0
#endregion

#region ===== STACKS -> ARMOR
func _on_add_armor_button_pressed() -> void:
	var armor_stacks: int = int(_armor_stacks_text_edit.text)
	if armor_stacks >= 0:
		_character.take_condition_stacks(armor_stacks, Utils.StackType.ARMOR)

func _on_add_armor_button_critical_pressed() -> void:
	var armor_stacks: int = int(_armor_stacks_text_edit.text)
	if armor_stacks >= 0:
		_character.take_condition_stacks(armor_stacks, Utils.StackType.ARMOR)

func _on_reset_armor_button_pressed() -> void:
	_character.stats.armor_stacks = 0
#endregion

#region ===== STACKS -> IGNITE
func _on_add_ignite_button_pressed() -> void:
	var ignite_stacks: int = int(_ignite_stacks_text_edit.text)
	if ignite_stacks >= 0:
		_character.take_condition_stacks(ignite_stacks, Utils.StackType.IGNITE)

func _on_add_ignite_button_critical_pressed() -> void:
	var ignite_stacks: int = int(_ignite_stacks_text_edit.text)
	if ignite_stacks >= 0:
		_character.take_condition_stacks(ignite_stacks, Utils.StackType.IGNITE)

func _on_reset_ignite_button_pressed() -> void:
	_character.stats.ignite_stacks = 0
#endregion

#region ===== STACKS -> REGEN
func _on_add_regen_button_pressed() -> void:
	var regen_stacks: int = int(_regen_stacks_text_edit.text)
	if regen_stacks >= 0:
		_character.take_condition_stacks(regen_stacks, Utils.StackType.REGEN)

func _on_add_regen_button_critical_pressed() -> void:
	var regen_stacks: int = int(_regen_stacks_text_edit.text)
	if regen_stacks >= 0:
		_character.take_condition_stacks(regen_stacks, Utils.StackType.REGEN)

func _on_reset_regen_button_pressed() -> void:
	_character.stats.regen_stacks = 0
#endregion

#region Attack
func _on_deal_physical_damage_button_pressed() -> void:
	var damage_raw := int(_damage_text_edit.text)
	var variation := int(_variation_text_edit.text)
	var damage: int = _rng.randi_range(clampi(damage_raw - variation, 0, 10000), clampi(damage_raw + variation, 0, 10000))
	_character.take_damage(damage, Utils.DamageType.PHYSICAL)


func _on_deal_critical_damage_button_pressed() -> void:
	var damage_raw := int(_damage_text_edit.text)
	var variation := int(_variation_text_edit.text)
	var damage: int = _rng.randi_range(clampi(damage_raw - variation, 0, 10000), clampi(damage_raw + variation, 0, 10000))
	_character.take_damage(damage*2, Utils.DamageType.PHYSICAL, true)


func _on_deal_magical_damage_button_pressed() -> void:
	var damage_raw := int(_magical_text_edit.text)
	var variation := int(_magical_variation_text_edit.text)
	var damage: int = _rng.randi_range(clampi(damage_raw - variation, 0, 10000), clampi(damage_raw + variation, 0, 10000))
	_character.take_damage(damage, Utils.DamageType.MAGICAL)
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
		_character.stats.health = health


func _on_set_max_health_button_pressed() -> void:
	var max_health: int = int(_max_health_text_edit.text)
	if max_health >= 0:
		_character.stats.health_max = max_health
#endregion

func _on_heal_button_pressed() -> void:
	var heal: int = int(_heal_text_edit.text)
	if heal >= 0:
		_character.take_heal(heal)

#region Random POPUP
const DAMAGE_TYPES: Array[Utils.DamageType] = [
	Utils.DamageType.PHYSICAL,
	Utils.DamageType.MAGICAL,
	Utils.DamageType.POISON,
	Utils.DamageType.HEAL,
]
const STACK_TYPES: Array[Utils.StackType] = [
	Utils.StackType.POISON,
	Utils.StackType.IGNITE,
	Utils.StackType.REGEN,
	Utils.StackType.ARMOR,
]
func _on_random_popup_button_pressed() -> void:
	if (_rng.randi() % 2 == 0):
		var random_value: int = _rng.randi_range(1, 200)
		var random_type: Utils.DamageType = DAMAGE_TYPES.pick_random()
		var is_critical: bool = (_rng.randi() % 5 == 0)
		var label_popup: LabelPopup = UI_LABEL_POPUP_SCENE.instantiate().setup_damage(random_value, random_type, _popup_positioner.global_position, is_critical)
		add_child(label_popup)
	else:
		var random_value: int = _rng.randi_range(1, 200)
		var random_type: Utils.DamageType = STACK_TYPES.pick_random()
		var is_critical: bool = (_rng.randi() % 5 == 0)
		var label_popup: LabelPopup = UI_LABEL_POPUP_SCENE.instantiate().setup_stack(random_value, random_type, _popup_positioner.global_position, is_critical)
		add_child(label_popup)
#endregion
