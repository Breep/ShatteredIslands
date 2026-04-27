class_name DarkKnight
extends Hero

#region ============================== Signals ==============================
signal super_strike_charges_changed(current: int, max: int)
#endregion

#region ============================== Export - Skills constants ==============================
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
#endregion

#region ============================== Private variables ==============================
var _super_strike_charges: int = 0
var _corruption_charges: int = 0
#endregion

#region ============================== Constants ==============================
const SUPER_STRIKE_ON_ATTACK_SCENE: PackedScene = preload("res://02_Entities/Heroes/DarkKnight/VFX/super_strike.tscn")
#endregion

const ON_HIT_EFFECT_SCENE: PackedScene = preload("res://22_VFX/VFX_3D/VFX/Scenes/VFX_Hit_dark.tscn")

# ============================== Node base functions ==============================

func _ready() -> void:
	auto_attack_completed.connect(_on_auto_attack_completed)

	var mod:= AutoAttackModifier.new()
	mod.is_one_time_effect = false
	mod.additional_effect_callback = func(cb_vars: Dictionary) -> void:
		var on_hit_vfx := ON_HIT_EFFECT_SCENE.instantiate() as Node3D
		var target_position: Vector3 = cb_vars.get(AutoAttackModifier.VarType.POSITION, Vector3.ZERO)
		get_tree().root.add_child(on_hit_vfx) 
		on_hit_vfx.global_position = target_position

		var tween := create_tween()
		tween.tween_interval(1.5) 
		tween.tween_callback(on_hit_vfx.queue_free)
		
	auto_attack_modifier_registry.register_modifier(mod)
	if _cataclysm_activated:
		_on_cataclysm_activation()
	
	if _skill_manager != null:
		_skill_manager.skill_picked.connect(_on_skill_manager_skill_picked)
	
	# Initial emit
	var max_charge: int = _mega_strike_max_charge if _mega_strike_activated else _super_strike_max_charge
	super_strike_charges_changed.emit(_super_strike_charges, max_charge)
	
	# Connect to visual
	#if visual.has_method("update_resource_points"):
		#super_strike_charges_changed.connect(visual.update_resource_points)
	
	super._ready()

# ============================== Public function ==============================

func cast_ultimate() -> void:
	_cast_ultimate()
	if _cataclysm_activated:
		for i in _cataclysm_number:
			_cast_ultimate()

# ============================== Private function ==============================

func _cast_ultimate() -> void:
	var target = target.get_target(TargetComponent.TargettingStrategy.CLOSEST_ENEMY)
	if target == null:
		return
	var spell_modifier: Dictionary = {
		Spell.DarkStormModifier.DAMAGE: stats.attack_damage * _dark_storm_damage_percent,
		Spell.DarkStormModifier.PERIOD: _dark_storm_period,
		Spell.DarkStormModifier.LIFESPAN: _dark_storm_duration,
		Spell.DarkStormModifier.PAIN_STACK_PERCENT: _pain_percent_per_stack if _pain_activated else 0.0
	}
	spell.cast_spell(target, Spell.Type.DARK_STORM, spell_modifier)


func _is_next_attack_super_strike() -> bool:
	var max_charge: int = _mega_strike_max_charge if _mega_strike_activated else _super_strike_max_charge
	return _super_strike_charges == max_charge


func _register_super_strike() -> void:
	return
	#var aa_modifier := AutoAttackModifier.new()
	#aa_modifier.id = "Super Strike"
	#aa_modifier.damage_mult = _mega_strike_damage_percent / 100.0 if _mega_strike_activated else _super_strike_damage_percent / 100.0
	#aa_modifier.tags = [AutoAttackModifier.TagType.HERO]
	#aa_modifier.on_attack_logic_callback = _on_attack_super_strike_logic_callback
	#aa_modifier.on_attack_visual_callback = _on_attack_super_strike_visual_callback
	#aa_modifier.on_hit_logic_callback = _on_hit_super_strike_logic_callback
	#aa_modifier.on_hit_visual_callback = _on_hit_super_strike_visual_callback
	#auto_attack_modifier_registry.register_modifier(aa_modifier)


func _register_corruption() -> void:
	return
	#_corruption_charges += 1
	#var stat_modifier := StatModifier.new()
	#stat_modifier.id = "Corruption"
	#stat_modifier.stat_type = EntityStats.StatType.AD
	#stat_modifier.calc_type = StatModifier.CalcType.ADD
	#stat_modifier.value = _corruption_charges * _corruption_ad_gain
	#stat_modifier.tags = [StatModifier.TagType.HERO]
	#stat_modifiers_registry.register_modifier(stat_modifier)


func _register_mana_strike() -> void:
	return
	#var aa_modifier := AutoAttackModifier.new()
	#aa_modifier.id = "Mana Strike"
	#aa_modifier.tags = [AutoAttackModifier.TagType.HERO]
	#aa_modifier.on_hit_logic_callback = _on_hit_mana_strike_logic_callback
	#auto_attack_modifier_registry.register_modifier(aa_modifier)


func _register_spark_of_light() -> void:
	return
	#var aa_modifier := AutoAttackModifier.new()
	#aa_modifier.id = "Spark Of Light"
	#aa_modifier.tags = [AutoAttackModifier.TagType.HERO]
	#aa_modifier.on_hit_logic_callback = _on_hit_spark_of_light_logic_callback
	#auto_attack_modifier_registry.register_modifier(aa_modifier)


# ============================== Callback ==============================

func _on_auto_attack_completed(_entity: Entity) -> void:
	return
	#var max_charge: int = _mega_strike_max_charge if _mega_strike_activated else _super_strike_max_charge
	#_super_strike_charges = (_super_strike_charges + 1) % (max_charge + 1)
	#super_strike_charges_changed.emit(_super_strike_charges, max_charge)
	#
	#var stat_modifier := StatModifier.new()
	#stat_modifier.id = "Super Strike"
	#stat_modifier.stat_type = EntityStats.StatType.AD
	#stat_modifier.calc_type = StatModifier.CalcType.ADD
	#stat_modifier.value = _super_strike_factor * _super_strike_charges # TODO -> * player_owner.lvl
	#stat_modifier.tags = [StatModifier.TagType.HERO]
	#stat_modifiers_registry.register_modifier(stat_modifier)
	#if _is_next_attack_super_strike():
		#_register_super_strike()
		#if _mana_strike_activated:
			#_register_mana_strike()
		#if _spark_of_light_activated:
			#_register_spark_of_light()

# ============================== HeroDesc specific callbacks ==============================

# ===== SUPER STRIKE

func _on_attack_super_strike_logic_callback(_cb_vars: Dictionary) -> void:
	if _corruption_activated:
		_register_corruption()


func _on_attack_super_strike_visual_callback(cb_vars: Dictionary) -> void:
	if not cb_vars.has(AutoAttackModifier.VarType.POSITION): return
	var gpos: Vector3 = cb_vars[AutoAttackModifier.VarType.POSITION]
	var explosion = SUPER_STRIKE_ON_ATTACK_SCENE.instantiate()
	add_child(explosion)
	explosion.global_position = gpos


func _on_hit_super_strike_logic_callback(_cb_vars: Dictionary) -> void:
	pass


func _on_hit_super_strike_visual_callback(cb_vars: Dictionary) -> void:
	if not cb_vars.has(AutoAttackModifier.VarType.POSITION): return
	var gpos: Vector3 = cb_vars[AutoAttackModifier.VarType.POSITION]
	var explosion = SUPER_STRIKE_ON_ATTACK_SCENE.instantiate()
	add_child(explosion)
	explosion.global_position = gpos

# ===== MANA STRIKE

func _on_hit_mana_strike_logic_callback(cb_vars: Dictionary) -> void:
	pass # TODO rework this
	#if not cb_vars.has(AutoAttackModifier.VarType.PHYSICAL_DAMAGE): return
	#var damage: int = cb_vars[AutoAttackModifier.VarType.PHYSICAL_DAMAGE]
	#var mana_inc: float = float(damage) * (_mana_strike_percent / 100.0)
	#stats.mana += mana_inc

# ===== SPARK OF LIGHT

func _on_hit_spark_of_light_logic_callback(cb_vars: Dictionary) -> void:
	pass # TODO rework this
	#if not cb_vars.has(AutoAttackModifier.VarType.PHYSICAL_DAMAGE): return
	#var damage: int = cb_vars[AutoAttackModifier.VarType.PHYSICAL_DAMAGE]
	#var health_inc: float = float(damage) * (_spark_of_light_percent / 100.0)
	#heal(self, health_inc, "Spark of Light")

# ===== CATACLYSM

func _on_cataclysm_activation() -> void:
	var stat_modifier := StatModifier.new()
	stat_modifier.id = "Cataclysm"
	stat_modifier.stat_type = EntityStats.StatType.MANA_MAX
	stat_modifier.calc_type = StatModifier.CalcType.ADD
	stat_modifier.value = _cataclysm_mana_cost
	stat_modifier.tags = [StatModifier.TagType.HERO]
	stat_modifiers_registry.register_modifier(stat_modifier)

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
