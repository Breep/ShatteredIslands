class_name GoblinArcher
extends Entity

@export_group("Passive - Ultimate")
@export_subgroup("Passive - XX")


@export_subgroup("Ultimate - Goblin focus")
@export var _goblin_focus_damage: float = 60.0
@export var _goblin_focus_vulnerability_stacks: float = 10.0

@export_group("Level 3 Skills")
@export_subgroup("Skill Bronze - Serrated Arrow")
@export var _serrated_arrow_activated: bool = false
@export_subgroup("Skill Bronze 1 - Serrated Arrow/Paramètres")
@export var _serrated_arrow_chance: float = 30.0
@export var _serrated_arrow_stack_number: int = 1.0
@export var _serrated_arrow_stack_type: Alteration.Type = Alteration.Type.VULNERABILITY

@export_group("Level 5 Skills")
@export_subgroup("Skill Silver - Goblin Eagerness")
@export var _goblin_eagerness_activated: bool = false
@export_subgroup("Skill Silver 1 - Goblin Eagerness/Paramètres")
@export var _goblin_eagerness_as: float = 50.0
@export var _goblin_eagerness_length: float = 5.0


@export_group("Level 7 Skills")
@export_subgroup("Skill Gold 1 - Coward Cruelty")
@export var _coward_cruelty_activated: bool = false
@export_subgroup("Skill Gold 1 - Coward Cruelty/Paramètres")
@export var _coward_cruelty_bonus_damage_percent: float = 25.0
@export var _coward_cruelty_threshold: float = 25.0

func _ready() -> void:
	auto_attack.attack_completed.connect(_on_auto_attack_completed)
	
	# Passif
	controller._ai._strategy = TargetComponent.TargettingStrategy.LOWEST_HP_PERCENT_ENEMY
	
	_serrated_arrow_application()   # Talent 1
	_goblin_eagerness_application() # Talent 2
	_coward_cruelty_application()   # Talent 3
	
	super._ready()
	
	
func _on_auto_attack_completed() -> void:
	return
	
	
func _goblin_eagerness_application() -> void:
	if not _goblin_eagerness_activated: return
	var mod := StatModifier.new()
	mod.id = &"GoblinEagerness"
	mod.stat_type = EntityStats.StatType.AS
	mod.value = stats.attack_speed * _goblin_eagerness_as/100
	stat_modifiers_registry.register_modifier(mod)
	
	battle_callback_registry.register_oneshot(_goblin_eagerness_length, func() -> void:
		stat_modifiers_registry.unregister_modifier(mod)
		)
	

func _coward_cruelty_application() -> void:
	if not _coward_cruelty_activated: return
	var mod := AutoAttackModifier.new()
	mod.id = &"CowardCruelty"
	mod.is_one_time_effect = false
	mod.damage_modifier_callback = func(cb_vars: Dictionary) -> void:
		var target_: Entity = cb_vars.get(AutoAttackModifier.VarType.TARGET) # TODO changer target component
		if not is_instance_valid(target_): return
		if target_.stats.health > target_.stats.health_max * _coward_cruelty_threshold / 100: return
		var damage_inc: float = stats.attack_damage * _coward_cruelty_bonus_damage_percent / 100.0
		if cb_vars.has(AutoAttackModifier.VarType.DAMAGE_ADD):
			cb_vars[AutoAttackModifier.VarType.DAMAGE_ADD] += damage_inc
		else:
			cb_vars[AutoAttackModifier.VarType.DAMAGE_ADD] = damage_inc
	auto_attack_modifier_registry.register_modifier(mod)
	
	
func _serrated_arrow_application() -> void:
	if not _serrated_arrow_activated: return
	var mod := AutoAttackModifier.new()
	mod.id = &"SerratedArrow"
	mod.is_one_time_effect = false
	mod.additional_effect_callback = func(cb_vars: Dictionary) -> void:
		var target_: Entity = cb_vars.get(AutoAttackModifier.VarType.TARGET)
		if not is_instance_valid(target_):  return
		if not Utils.is_randomize_modifier_active(_serrated_arrow_chance, battle_id): return
		alterations.inflict_condition_stacks(target_, _serrated_arrow_stack_number, _serrated_arrow_stack_type, &"SerratedArrow")
	auto_attack_modifier_registry.register_modifier(mod)
		
		
func cast_ultimate() -> void:
	super.cast_ultimate()
	await get_tree().create_timer(1).timeout
	spell.cast_spell(target.get_target(TargetComponent.TargettingStrategy.LOWEST_HP_PERCENT_ENEMY), Spell.Type.GOBLIN_FOCUS, {
		GoblinFocus.Modifier.DAMAGE: 60.0,
		GoblinFocus.Modifier.STACK_TYPE: Alteration.Type.VULNERABILITY,
		GoblinFocus.Modifier.STACK_NUMBER: 10
	})
