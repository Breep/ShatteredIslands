class_name DarkKnight
extends Hero3D

# Passive
@export_group("Passive - Ultimate")
@export_subgroup("Passive - Super Strike")
@export var _super_strike_factor: float = 1.0
@export var _super_strike_max_charge: int = 5
@export var _super_strike_damage_percent: float = 150.0

@export_subgroup("Ultimate - Black Storm")
@export var _black_storm_duration: float = 2.4
@export var _black_storm_period: float = 0.2
@export var _black_storm_damage_percent: float = 0.5

@export_group("Level 3 Skills")
@export_subgroup("Skill1A - Spark Of Light")
@export var _spark_of_light_activated: bool = false
@export var _spark_of_light_percent: float = 100.0

@export_subgroup("Skill1B - Corruption")
@export var _corruption_activated: bool = false
@export var _corruption_ad_gain: float = 1.0

@export_group("Level 5 Skills")
@export_subgroup("Skill2A - Pain")
@export var _pain_activated: bool = false
@export var _pain_percent_per_stack: float = 1.0

@export_subgroup("Skill 2B - Cataclysm")
@export var _cataclysm_activated: bool = false
@export var _cataclysm_number: int = 2
@export var _cataclysm_mana_cost: int = 150

@export_group("Level 7 Skills")
@export_subgroup("Skill 3A - Mana Strike")
@export var _mana_strike_activated: bool = false
@export var _mana_strike_percent: float = 5.0

@export_subgroup("Skill 3B - Mega Strike")
@export var _mega_strike_activated: bool = false
@export var _mega_strike_max_charge: int = 10
@export var _mega_strike_damage_percent: float = 500.0


func _ready() -> void:
	_character_owner.aa_done.connect(_on_character_owner_aa_done)

func cast_ultimate() -> void:
	var target = _character_owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if target == null:
		return
	var spell_modifier: Dictionary = {
		Spell.DarkStormModifier.DAMAGE: _character_owner.stats.attack_damage * _black_storm_damage_percent,
		Spell.DarkStormModifier.PERIOD: _black_storm_period,
		Spell.DarkStormModifier.LIFESPAN: _black_storm_duration
	}
	_character_owner.cast_spell(target, Spell.Type.DARK_STORM, spell_modifier)


var __aa_counter: int = 0
func _on_character_owner_aa_done() -> void:
	var stat_modifier := StatModifier.new()
	stat_modifier.id = "Super Strike"
	stat_modifier.stat_type = EntityStats.StatType.AD
	stat_modifier.calc_type = StatModifier.CalcType.ADD
	stat_modifier.value = _super_strike_factor * __aa_counter * _character_owner.player.lvl
	stat_modifier.tags = [StatModifier.TagType.HERO]
	_character_owner.stats_manager.update_modifier(stat_modifier)
