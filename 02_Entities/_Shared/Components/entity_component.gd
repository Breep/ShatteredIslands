# Extensions de Entity
# Chaque EntityComponent s'attache seul à la variable correspondante sur Entity
# En pratique, il suffit de drag and drop un component dans l'arborescence d'une entité et de
# set _owner pour qu'il vienne s'attacher à Entity

class_name EntityComponent
extends Node

enum Type {
	MOVEMENT = 0,
	TARGET = 1,
	ALTERATIONS = 2,
	DAMAGE = 3,
	HEAL = 4,
	PROJECTILE = 5,
	SPELL = 6,
	SUMMON = 7,
	AUTO_ATTACK = 8,
	MANA = 9,
	LABEL_POPUP = 10,
	ANIMATION = 11,
	SPAWN_ANIMATION = 12,
	CLICKABLE = 13,
	DESPAWN_ANIMATION = 14,
	DISPLAY_MODE = 15,
	DECK_HOLDER = 16,
	FAMILY = 17,
	DRAGGABLE = 18,
	CONTROLLER = 19,
	PROGRESSION = 20,
	SKILL = 21,
	AURA = 22,
	HIT_MARKER = 23,
}

# Chemins (String) volontairement dans un const, et non des load() dans un static var :
# un initialiseur de static var s'exécute au chargement de la classe, y compris dans
# l'éditeur, et déclenchait un load() cyclique (chaque scène porte un script qui
# extends EntityComponent) qui faisait crasher l'éditeur lors des hot-reloads.
# Les scènes sont chargées paresseusement et mises en cache via _scene_for().
const _SCENE_PATHS := {
	Type.MOVEMENT:             "res://02_Entities/_Shared/Components/Movement/movement_component.tscn",
	Type.TARGET:               "res://02_Entities/_Shared/Components/Target/target_component.tscn",
	Type.ALTERATIONS:          "res://02_Entities/_Shared/Components/Alterations/alterations_component.tscn",
	Type.DAMAGE:               "res://02_Entities/_Shared/Components/Damage/damage_component.tscn",
	Type.HEAL:                 "res://02_Entities/_Shared/Components/Heal/heal_component.tscn",
	Type.PROJECTILE:           "res://02_Entities/_Shared/Components/Projectile/projectile_component.tscn",
	Type.SPELL:                "res://02_Entities/_Shared/Components/Spell/spell_component.tscn",
	Type.SUMMON:               "res://02_Entities/_Shared/Components/Summon/summon_component.tscn",
	Type.AUTO_ATTACK:          "res://02_Entities/_Shared/Components/AutoAttack/auto_attack_component.tscn",
	Type.LABEL_POPUP:          "res://02_Entities/_Shared/Components/Popup/label_popup_component.tscn",
	Type.ANIMATION:            "res://02_Entities/_Shared/Components/Animation/animation_component.tscn",
	Type.SPAWN_ANIMATION:      "res://02_Entities/_Shared/Components/SpawnAnimation/spawn_animation_component.tscn",
	Type.CLICKABLE:            "res://02_Entities/_Shared/Components/Clickable/clickable_component.tscn",
	Type.DESPAWN_ANIMATION:    "res://02_Entities/_Shared/Components/DespawnAnimation/despawn_animation_component.tscn",
	Type.DISPLAY_MODE:         "res://02_Entities/_Shared/Components/DisplayMode/display_mode_module.tscn",
	Type.DECK_HOLDER:          "res://02_Entities/_Shared/Components/DeckHolder/deck_holder_component.tscn",
	Type.FAMILY:               "res://02_Entities/_Shared/Components/Family/family_module.tscn",
	Type.DRAGGABLE:            "res://02_Entities/_Shared/Components/Draggable/draggable_component.tscn",
	Type.CONTROLLER:           "res://02_Entities/_Shared/Components/Controller/entity_controller.tscn",
	Type.MANA:                 "res://02_Entities/_Shared/Components/Mana/mana_component.tscn",
	Type.PROGRESSION:          "res://02_Entities/_Shared/Components/Progression/progression_component.tscn",
	Type.SKILL:                "res://02_Entities/_Shared/Components/Skill/skill_component.tscn",
	Type.AURA:                 "res://02_Entities/_Shared/Components/Aura/aura_component.tscn",
	Type.HIT_MARKER:           "res://02_Entities/_Shared/Components/HitMarker/hit_marker_component.tscn",
}

static var _scene_cache: Dictionary[Type, PackedScene] = {}


static func _scene_for(component_type: Type) -> PackedScene:
	if not _scene_cache.has(component_type):
		_scene_cache[component_type] = load(_SCENE_PATHS[component_type])
	return _scene_cache[component_type]

static var _global_dodge_number: int = 0
static var _crit_check_number: int = -1

@export var _owner: Entity # Owner of the module

var _dodge_number: int = -1

static func add(component_type: Type, entity_owner: Entity) -> void:
	# Type.find_key() résout par valeur enum (robuste aux trous dans la séquence).
	# Type.keys()[i] indexerait par position dans l'array, ce qui casse dès qu'on retire un membre.
	var type_name: String = str(Type.find_key(component_type))
	Verbose.trace("Instantiating '" + type_name + "' on '" + entity_owner.name + "'", Verbose.Category.ENTITY_MODULE)
	var component: EntityComponent = _scene_for(component_type).instantiate()
	if component == null:
		Verbose.error("Can't instantiate '" + type_name + "'", Verbose.Category.ENTITY_MODULE)
		return
	component.init(entity_owner)
	entity_owner.add_child(component)

func init(entity_owner: Entity) -> EntityComponent:
	_owner = entity_owner
	return self

func _ready() -> void:
	if _owner == null:
		Verbose.error("Module: undef source [" + str(get_path()) + "]", Verbose.Category.ENTITY_MODULE)
		queue_free()
		return


#region ============================== Private API ==============================
func _get_crit_multiplier(action_type: Utils.ActionType) -> Dictionary:
	var is_critical: bool = false
	var crit_chance: float = _owner.stats.get_effective_stat(EntityStats.StatType.CRIT_CHANCE, action_type)
	var crit_multiplier_percent: float = 0.0

	_crit_check_number += 1
	if Utils.is_randomize_modifier_active(crit_chance, _owner.battle_id, "crit_check_" + str(_crit_check_number)):
		is_critical = true
		crit_multiplier_percent = _owner.stats.get_effective_stat(EntityStats.StatType.CRIT_MULT, action_type)

	return {"multiplier": remap(crit_multiplier_percent, 0, 100, 1, 2), "is_critical": is_critical}


func _get_power_fragility_multiplier(action_type: Utils.ActionType) -> float:
	var power: float = _owner.stats.get_effective_stat(EntityStats.StatType.M_POWER, action_type)
	var fragility: float = _owner.stats.get_effective_stat(EntityStats.StatType.M_FRAGILITY, action_type)
	return (100.0 + power) / (100.0 + fragility)


func _consume_before_action_modifiers(action_type: Utils.ActionCategory, modifiers_dict: Dictionary) -> Dictionary:
	if _owner.action_modifiers_registry != null:
		for modifier: ActionModifier in _owner.action_modifiers_registry.consume_all_modifiers(action_type):
			if modifier.before_action_logic_callback.is_valid():
				modifier.before_action_logic_callback.call(modifiers_dict)
	return modifiers_dict


func _consume_after_action_modifiers(action_type: Utils.ActionCategory, modifiers_dict: Dictionary) -> Dictionary:
	if _owner.action_modifiers_registry != null:
		for modifier: ActionModifier in _owner.action_modifiers_registry.consume_all_modifiers(action_type):
			if modifier.after_action_logic_callback.is_valid():
				modifier.after_action_logic_callback.call(modifiers_dict)
	return modifiers_dict


func _is_dodged(action_type: Utils.ActionType, source: Entity) -> bool:
	var dodge_chance: float = _owner.stats.get_effective_stat(EntityStats.StatType.DODGE, action_type)
	_dodge_number += 1
	if Utils.is_randomize_modifier_active(dodge_chance, _owner.battle_id, "dodge_check_" + str(_global_dodge_number)):
		_global_dodge_number += 1
		for dodge_modifier: ActionModifier in _owner.action_modifiers_registry.consume_all_modifiers(Utils.ActionCategory.DODGE):
			if dodge_modifier.after_action_logic_callback.is_valid():
				dodge_modifier.after_action_logic_callback.call({
					ActionModifier.VarType.DODGE_NUMBER: _dodge_number, 
					ActionModifier.VarType.TARGET: source
				})
		return true
	return false


func _get_resistance_exposure_multiplier(action_type: Utils.ActionType) -> float:
	var res: float = _owner.stats.get_effective_stat(EntityStats.StatType.M_RESISTANCE, action_type)
	var exposure: float = _owner.stats.get_effective_stat(EntityStats.StatType.M_EXPOSURE, action_type)
	return (100 + exposure) / (100 + res)


func _get_crit_resistance_multiplier(_action_type: Utils.ActionType) -> float:
	var res: float = _owner.stats.get_stat(EntityStats.StatType.CRIT_RESISTANCE)
	return 100.0 / (100.0 + res)


# ============================== Callbacks ==============================

func _on_game_manager_game_state_changed(game_state: GameManager.GameState) -> void:
	match game_state:
		GameManager.GameState.FIGHTING: _dodge_number = 0
#endregion
