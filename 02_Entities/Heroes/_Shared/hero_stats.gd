# HeroStats — Bloc de stats d'un héros à un niveau donné. Suit la distinction Mono / Multi
# de EntityStats : Mono = champs single, Multi (m_*) = dicts par Utils.ActionType.
class_name HeroStats
extends Resource

# --- Mono ---
@export var health_max: int = 2000
@export var mana_max: int = 100
@export var mana_regen: float = 2.0
@export var attack_damage: int = 20
@export var attack_power: int = 0
@export var attack_speed: float = 0.5
@export var attack_range: float = -1.0
@export var movement_speed: float = 4.0
@export var auto_attack_type: EntityStats.AutoAttackType = EntityStats.AutoAttackType.RANGED

@export var crit_chance: float = 10.0
@export var crit_mult: float = 100.0
@export var dodge: float = 0.0
@export var lifesteal: float = 0.0
@export var crit_resistance: float = 0.0

# --- Multi (per ActionType) ---
@export var m_crit_chances: Dictionary[Utils.ActionType, float] = {}
@export var m_crit_mults: Dictionary[Utils.ActionType, float] = {}
@export var m_dodges: Dictionary[Utils.ActionType, float] = {}
@export var m_lifesteals: Dictionary[Utils.ActionType, float] = {}
@export var m_powers: Dictionary[Utils.ActionType, float] = {}
@export var m_fragilities: Dictionary[Utils.ActionType, float] = {}
@export var m_resistances: Dictionary[Utils.ActionType, float] = {}
@export var m_exposures: Dictionary[Utils.ActionType, float] = {}


func apply_json_data(data: Dictionary) -> void:
	for key in data:
		if not key in self:
			continue
		var value = data[key]
		if typeof(value) != TYPE_DICTIONARY:
			set(key, value)
		else:
			var target_dict: Dictionary = get(key)
			var source_dict: Dictionary = value
			for action_name in source_dict:
				if action_name in Utils.ActionType:
					var enum_index = Utils.ActionType[action_name]
					target_dict[enum_index] = source_dict[action_name]
				else:
					push_warning("ActionType inconnu : " + action_name)
