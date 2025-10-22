extends Control

@onready var _max_health_text_edit: TextEdit = %MaxHealthTextEdit
@onready var _current_health_text_edit: TextEdit = %CurrentHealthTextEdit

@onready var _poison_stacks_text_edit: TextEdit = %PoisonTextEdit
@onready var _armor_stacks_text_edit: TextEdit = %ArmorTextEdit
@onready var _ignite_stacks_text_edit: TextEdit = %IgniteStacksTextEdit

@onready var _mana_regen_text_edit: TextEdit = %ManaRegenTextEdit
@onready var _max_mana_text_edit: TextEdit = %MaxManaTextEdit

@onready var _damage_text_edit: TextEdit = %DamageTextEdit
@onready var _variation_text_edit: TextEdit = %VariationTextEdit

@onready var _magical_text_edit: TextEdit = %MagicalDamageTextEdit
@onready var _magical_variation_text_edit: TextEdit = %MagicalVariationTextEdit

@onready var _heal_text_edit: TextEdit = %HealTextEdit

@onready var _entity_stats: UIEntityStats = %EntityStats

const CHARACTER_SCENE : PackedScene = preload("res://Entities/Character/character.tscn")

var _character: Character

@onready var _rng:= RandomNumberGenerator.new()

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
	_entity_stats.connect_entity(_character)


#region Start/Stop Battle
func _on_start_battle_pressed() -> void:
	_character.fighting_state = GlobalFightingManager.FightingState.FIGHTING


func _on_end_battle_pressed() -> void:
	_character.fighting_state = GlobalFightingManager.FightingState.CELEBRATING
#endregion

#region Stacks
func _on_poison_button_pressed() -> void:
	var poison_stacks: int = int(_poison_stacks_text_edit.text)
	if poison_stacks >= 0:
		_character.stats.poison_stacks = poison_stacks


func _on_armor_button_pressed() -> void:
	var armor_stacks: int = int(_armor_stacks_text_edit.text)
	if armor_stacks >= 0:
		_character.stats.armor_stacks = armor_stacks


func _on_set_ignite_button_pressed() -> void:
	var ignite_stacks: int = int(_ignite_stacks_text_edit.text)
	if ignite_stacks >= 0:
		_character.stats.ignite_stacks = ignite_stacks
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
@onready var _control: Control = %Control
func _on_set_mana_regen_button_pressed() -> void:
	var damage_popup := UIDamagePopup.new().setup(42)
	add_child(damage_popup)
	damage_popup.position = _control.position

func _on_set_max_mana_button_pressed() -> void:
	pass # Replace with function body.
#endregion

#region Health
func _on_set_current_health_button_pressed() -> void:
	pass # Replace with function body.


func _on_set_max_health_button_pressed() -> void:
	pass # Replace with function body.
#endregion

func _on_heal_button_pressed() -> void:
	var heal: int = int(_heal_text_edit.text)
	if heal >= 0:
		_character.take_heal(heal)
