class_name DarkKnight
extends Hero3D

# ============================== Export - Skills constants ==============================

@export_group("Passive - Ultimate")
@export_subgroup("Passive - Super Strike")
@export var _super_strike_factor: float = 1.0
@export var _super_strike_max_charge: int = 5
@export var _super_strike_damage_percent: float = 150.0

@export_subgroup("Ultimate - Black Storm")
@export var _dark_storm_duration: float = 2.4
@export var _dark_storm_period: float = 0.2
@export var _dark_storm_damage_percent: float = 0.5

@export_group("Level 3 Skills")
@export_subgroup("Skill Bronze 1 - Spark Of Light")
@export var _spark_of_light_activated: bool = false
@export var _spark_of_light_percent: float = 100.0

@export_subgroup("Skill Bronze 2 - Corruption")
@export var _corruption_activated: bool = false
@export var _corruption_ad_gain: float = 1.0

@export_group("Level 5 Skills")
@export_subgroup("Skill Silver 1 - Pain")
@export var _pain_activated: bool = false
@export var _pain_percent_per_stack: float = 2.5

@export_subgroup("Skill Silver 2 - Cataclysm")
@export var _cataclysm_activated: bool = false
@export var _cataclysm_number: int = 2
@export var _cataclysm_mana_cost: int = 50

@export_group("Level 7 Skills")
@export_subgroup("Skill Gold 1 - Mana Strike")
@export var _mana_strike_activated: bool = false
@export var _mana_strike_percent: float = 5.0

@export_subgroup("Skill Gold 2 - Mega Strike")
@export var _mega_strike_activated: bool = false
@export var _mega_strike_max_charge: int = 10
@export var _mega_strike_damage_percent: float = 500.0

signal super_strike_charges_changed(current: int, max: int)

# ============================== Private variables ==============================

var _super_strike_charges: int = 0
var _corruption_charges: int = 0
var _skill_manager: SkillManager

# ============================== Constants ==============================

const SUPER_STRIKE_ON_ATTACK_SCENE: PackedScene = preload("res://Entities/Heroes/DarkKnight/VFX/super_strike.tscn")

# ============================== Node base functions ==============================

func _ready() -> void:
	if _character_owner == null: return
	_character_owner.aa_done.connect(_on_character_owner_aa_done)
	
	if _cataclysm_activated:
		_on_cataclysm_activation()
	
	_skill_manager = _character_owner.player.skill_manager
	_skill_manager.skill_picked.connect(_on_skill_manager_skill_picked)
	
	# Initial emit
	var max_charge: int = _mega_strike_max_charge if _mega_strike_activated else _super_strike_max_charge
	super_strike_charges_changed.emit(_super_strike_charges, max_charge)
	
	# Connect to visual
	if _character_owner.visual.has_method("update_resource_points"):
		super_strike_charges_changed.connect(_character_owner.visual.update_resource_points)

# ============================== Public function ==============================

func cast_ultimate() -> void:
	_cast_ultimate()
	if _cataclysm_activated:
		for i in _cataclysm_number:
			_cast_ultimate()

# ============================== Private function ==============================

func _cast_ultimate() -> void:
	var target = _character_owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if target == null:
		return
	var spell_modifier: Dictionary = {
		Spell.DarkStormModifier.DAMAGE: _character_owner.stats.attack_damage * _dark_storm_damage_percent,
		Spell.DarkStormModifier.PERIOD: _dark_storm_period,
		Spell.DarkStormModifier.LIFESPAN: _dark_storm_duration,
		Spell.DarkStormModifier.PAIN_STACK_PERCENT: _pain_percent_per_stack if _pain_activated else 0.0
	}
	_character_owner.cast_spell(target, Spell.Type.DARK_STORM, spell_modifier)


func _is_next_attack_super_strike() -> bool:
	var max_charge: int = _mega_strike_max_charge if _mega_strike_activated else _super_strike_max_charge
	return _super_strike_charges == max_charge


func _register_super_strike() -> void:
	var aa_modifier := AutoAttackModifier.new()
	aa_modifier.id = "Super Strike"
	aa_modifier.damage_mult = _mega_strike_damage_percent / 100.0 if _mega_strike_activated else _super_strike_damage_percent / 100.0
	aa_modifier.tags = [AutoAttackModifier.TagType.HERO]
	aa_modifier.on_attack_logic_callback = _on_attack_super_strike_logic_callback
	aa_modifier.on_attack_visual_callback = _on_attack_super_strike_visual_callback
	aa_modifier.on_hit_logic_callback = _on_hit_super_strike_logic_callback
	aa_modifier.on_hit_visual_callback = _on_hit_super_strike_visual_callback
	_character_owner.auto_attack_modifier_registry.register_modifier(aa_modifier)


func _register_corruption() -> void:
	_corruption_charges += 1
	var stat_modifier := StatModifier.new()
	stat_modifier.id = "Corruption"
	stat_modifier.stat_type = EntityStats.StatType.AD
	stat_modifier.calc_type = StatModifier.CalcType.ADD
	stat_modifier.value = _corruption_charges * _corruption_ad_gain
	stat_modifier.tags = [StatModifier.TagType.HERO]
	_character_owner.stats_manager.update_modifier(stat_modifier)


func _register_mana_strike() -> void:
	var aa_modifier := AutoAttackModifier.new()
	aa_modifier.id = "Mana Strike"
	aa_modifier.tags = [AutoAttackModifier.TagType.HERO]
	aa_modifier.on_hit_logic_callback = _on_hit_mana_strike_logic_callback
	_character_owner.auto_attack_modifier_registry.register_modifier(aa_modifier)


func _register_spark_of_light() -> void:
	var aa_modifier := AutoAttackModifier.new()
	aa_modifier.id = "Spark Of Light"
	aa_modifier.tags = [AutoAttackModifier.TagType.HERO]
	aa_modifier.on_hit_logic_callback = _on_hit_spark_of_light_logic_callback
	_character_owner.auto_attack_modifier_registry.register_modifier(aa_modifier)


# ============================== Callback ==============================

func _on_character_owner_aa_done() -> void:
	var max_charge: int = _mega_strike_max_charge if _mega_strike_activated else _super_strike_max_charge
	_super_strike_charges = (_super_strike_charges + 1) % (max_charge + 1)
	super_strike_charges_changed.emit(_super_strike_charges, max_charge)
	
	var stat_modifier := StatModifier.new()
	stat_modifier.id = "Super Strike"
	stat_modifier.stat_type = EntityStats.StatType.AD
	stat_modifier.calc_type = StatModifier.CalcType.ADD
	stat_modifier.value = _super_strike_factor * _super_strike_charges * _character_owner.player.lvl
	stat_modifier.tags = [StatModifier.TagType.HERO]
	_character_owner.stats_manager.update_modifier(stat_modifier)
	if _is_next_attack_super_strike():
		_register_super_strike()
		if _mana_strike_activated:
			_register_mana_strike()
		if _spark_of_light_activated:
			_register_spark_of_light()

# ============================== HeroDesc specific callbacks ==============================

# ===== SUPER STRIKE

func _on_attack_super_strike_logic_callback(_cb_vars: Dictionary) -> void:
	if _corruption_activated:
		_register_corruption()


func _on_attack_super_strike_visual_callback(cb_vars: Dictionary) -> void:
	if not cb_vars.has(AutoAttackModifier.VarType.VISUAL_POS): return
	var gpos: Vector3 = cb_vars[AutoAttackModifier.VarType.VISUAL_POS]
	var explosion = SUPER_STRIKE_ON_ATTACK_SCENE.instantiate()
	add_child(explosion)
	explosion.global_position = gpos


func _on_hit_super_strike_logic_callback(_cb_vars: Dictionary) -> void:
	pass


func _on_hit_super_strike_visual_callback(cb_vars: Dictionary) -> void:
	if not cb_vars.has(AutoAttackModifier.VarType.VISUAL_POS): return
	var gpos: Vector3 = cb_vars[AutoAttackModifier.VarType.VISUAL_POS]
	var explosion = SUPER_STRIKE_ON_ATTACK_SCENE.instantiate()
	add_child(explosion)
	explosion.global_position = gpos

# ===== MANA STRIKE

func _on_hit_mana_strike_logic_callback(cb_vars: Dictionary) -> void:
	if not cb_vars.has(AutoAttackModifier.VarType.PHYSICAL_DAMAGE): return
	var damage: int = cb_vars[AutoAttackModifier.VarType.PHYSICAL_DAMAGE]
	var mana_inc: float = float(damage) * (_mana_strike_percent / 100.0)
	character_owner.stats.mana += mana_inc

# ===== SPARK OF LIGHT

func _on_hit_spark_of_light_logic_callback(cb_vars: Dictionary) -> void:
	if not cb_vars.has(AutoAttackModifier.VarType.PHYSICAL_DAMAGE): return
	var damage: int = cb_vars[AutoAttackModifier.VarType.PHYSICAL_DAMAGE]
	var health_inc: float = float(damage) * (_spark_of_light_percent / 100.0)
	character_owner.heal(character_owner, health_inc, "Spark of Light")

# ===== CATACLYSM

func _on_cataclysm_activation() -> void:
	var stat_modifier := StatModifier.new()
	stat_modifier.id = "Cataclysm"
	stat_modifier.stat_type = EntityStats.StatType.MANA_MAX
	stat_modifier.calc_type = StatModifier.CalcType.ADD
	stat_modifier.value = _cataclysm_mana_cost
	stat_modifier.tags = [StatModifier.TagType.HERO]
	_character_owner.stats_manager.update_modifier(stat_modifier)

# ============================== Skill Manager Callbacks ==============================

func _on_skill_manager_skill_picked(skill_id: Skill.SkillID) -> void:
	match skill_id:
		Skill.SkillID.BRONZE1:
			_spark_of_light_activated = true
		Skill.SkillID.BRONZE2:
			_corruption_activated = true
		Skill.SkillID.SILVER1:
			_pain_activated = true
		Skill.SkillID.SILVER2:
			_cataclysm_activated = true
			_on_cataclysm_activation()
		Skill.SkillID.GOLD1:
			_mana_strike_activated = true
		Skill.SkillID.GOLD2:
			_mega_strike_activated = true
