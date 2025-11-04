class_name ActionModule
extends Module

@export var _storm_manager: StormManager
@export var _defense_manager: DefenseManager
@export var _life_manager: LifeManager
@export var _fire_manager: FireManager
@export var _serenity_manager: SerenityManager
@export var _poison_manager: PoisonManager

var _spawn_manager: SpawnManager

const METEOR_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/Meteor/meteor.tscn")
const DARK_STORM_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/DarkStorm/dark_storm.tscn")
const CONTAGION_SPELL_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/Poison/Contagion/contagion_spell_area.tscn")

# ============================== Public functions ==============================

func connect_to_spawn_manager(spawn_manager: SpawnManager) -> void:
	if spawn_manager == null:
		printerr("ActionModule: Trying to connect to a <null> SpawnManager")
		return
	
	_spawn_manager = spawn_manager

# ============================== Attack ==============================

# Instantly attack the target - Apply cards damages multiplier if there are some
func direct_attack(target: Character, damage: int, damage_type: Utils.DamageType) -> void:
	if not multiplayer.is_server(): return
	if target == null: return
	var multiplier = _get_damage_multipliers()
	if damage_type == Utils.DamageType.PHYSICAL:
		damage *= multiplier["physical"]
	elif damage_type == Utils.DamageType.MAGICAL:
		damage *= multiplier["magical"]
	
	target.take_damage(damage, damage_type, multiplier["is_critical"], _owner)


# Instantly attack the target - Apply cards damages multiplier if there are some
func direct_attack_percent(target: Character, damage_percent: float, damage_type: Utils.DamageType, percent_modifier: Utils.PercentModifier) -> void:
	if not multiplayer.is_server(): return
	if target == null: return
	var hp: int
	match percent_modifier:
		Utils.PercentModifier.MAX_HP:
			hp = target.stats.health_max
		Utils.PercentModifier.CURRENT_HP:
			hp = target.stats.health
		Utils.PercentModifier.LOST_HP:
			hp = target.stats.health_max - _owner.stats.health
	var damage = hp * damage_percent  / 100.0
	direct_attack(target, damage, damage_type)


# Create a projectile to attack the target - Apply cards damages multiplier if there are some
func build_projectile_attack(target: Character, projectile_type: Projectile.ProjectileType, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> AttackCommand:
	if not multiplayer.is_server(): return
	if target == null: return
	var multiplier = _get_damage_multipliers()
	projectile_stats.is_critic = multiplier["is_critical"]
	projectile_stats.physical_damage_flat *= multiplier["physical"]
	projectile_stats.physical_damage_percent *= multiplier["physical"]
	projectile_stats.magical_damage_flat *= multiplier["magical"]
	projectile_stats.magical_damage_percent *= multiplier["magical"]
	return AttackCommand.new().setup(target, projectile_type, projectile_spawn, projectile_stats)


func projectile_attack(target: Character, projectile_type: Projectile.ProjectileType, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
	_spawn_manager.spawn_projectile(_owner, target, projectile_type, projectile_spawn, projectile_stats)


func _get_damage_multipliers() -> Dictionary:
	var is_critical: bool = false
	var physical_multiplier: float = 1.0
	var magical_multiplier: float = 1.0
	
	var crit_chance = _owner.stats.physical_critical_chance
	if _storm_manager != null:
		crit_chance = _storm_manager.get_critical_chance()
	
	if Utils.is_randomize_modifier_active(crit_chance):
		is_critical = true
		var crit_multiplier = _owner.stats.physical_critical_multiplier
		if _storm_manager != null:
			crit_multiplier = _storm_manager.get_critical_multiplier(Utils.DamageType.PHYSICAL)
		physical_multiplier *= crit_multiplier
	
	if _life_manager != null:
		physical_multiplier = _life_manager.get_increased_damage_taken_from_lost_hp(physical_multiplier, Utils.DamageType.PHYSICAL) # Increase % of PHYSICAL damage
	
	if _fire_manager != null:
		magical_multiplier = _fire_manager.get_increased_damage(magical_multiplier, Utils.DamageType.MAGICAL) # Increase % of MAGICAL damage
	
	if _defense_manager != null:
		physical_multiplier = _defense_manager.get_increased_damage_done_from_power_wrist(physical_multiplier)
		magical_multiplier = _defense_manager.get_increased_damage_done_from_power_wrist(magical_multiplier)
	
	if _serenity_manager != null:
		physical_multiplier = _serenity_manager.get_reduced_damage_dealed_from_pacify(physical_multiplier) # Reduce % of ALL damage
		magical_multiplier = _serenity_manager.get_reduced_damage_dealed_from_pacify(magical_multiplier) # Reduce % of ALL damage
	
	return { "physical": physical_multiplier, "magical": magical_multiplier, "is_critical": is_critical }


func _spawn_projectile(target: Character, projectile_type: Projectile.ProjectileType, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
	if target == null: return
	_spawn_manager.spawn_projectile(_owner, target, projectile_type, projectile_spawn, projectile_stats)

# ============================== Heal ==============================

# [Server only]
func heal(target: Character, heal_amount: int) -> void:
	if not multiplayer.is_server(): return
	if target == null: return
	target.take_heal(heal_amount, _owner)


func heal_percent(target: Character, percent: float, percent_modifier: Utils.PercentModifier) -> void:
	if not multiplayer.is_server(): return
	if target == null: return
	var hp: int
	match percent_modifier:
		Utils.PercentModifier.MAX_HP:
			hp = target.stats.health_max
		Utils.PercentModifier.CURRENT_HP:
			hp = target.stats.health
		Utils.PercentModifier.LOST_HP:
			hp = target.stats.health_max - _owner.stats.health
	var heal_amount: int = floor((percent * hp as float) / 100.0)
	heal(target, heal_amount)

# ============================== Condition stacks ==============================

# [Server only]
func inflict_condition_stacks(target: Character, stacks_number: int, stack_type: Utils.StackType) -> void:
	if not multiplayer.is_server(): return
	if target == null: return
	_check_on_inflict_condition_stacks_modifier(target, stacks_number, stack_type)
	target.take_condition_stacks(stacks_number, stack_type, _owner)


#TODO Use a StackModifier like the AutoAttackModifier to remove dependancies between action module and family managers
func _check_on_inflict_condition_stacks_modifier(target: Entity, stacks_number: int, stack_type: Utils.StackType) -> void:
	if _poison_manager != null:
		_poison_manager.check_on_apply_poison_stack(target, stacks_number, stack_type)

# ============================== Spells ==============================

func cast_spell(target: Entity, spell_type: Spell.Type, spell_modifier: Dictionary = {}) -> void:
	match spell_type:
		Spell.Type.METEOR: _cast_meteor(target, spell_modifier)
		Spell.Type.DARK_STORM: _cast_dark_storm(target, spell_modifier)
		Spell.Type.CONTAGION: _cast_contagion(spell_modifier)


func _cast_meteor(target: Entity, spell_modifier: Dictionary) -> void:
	if target == null: return
	_owner.signal_spell_casted(target, Spell.Type.METEOR)
	var meteor: Meteor = METEOR_SCENE.instantiate()
	if multiplayer.is_server():
		var ignite_stacks: int = spell_modifier[Spell.MeteorModifier.IGNITE_STACKS]
		var damage_per_stack: int = spell_modifier[Spell.MeteorModifier.DAMAGE_PER_STACK]
		meteor.init(target, ignite_stacks, damage_per_stack, _owner)
	else:
		meteor.init(target, 0, 0, _owner)
	_spawn_manager.spawn_spell(meteor)


func _cast_dark_storm(target: Entity, spell_modifier: Dictionary) -> void:
	if target == null: return
	_owner.signal_spell_casted(target, Spell.Type.DARK_STORM)
	var dark_storm: DarkStorm = DARK_STORM_SCENE.instantiate()
	if multiplayer.is_server():
		var damage: int = spell_modifier[Spell.DarkStormModifier.DAMAGE]
		var period: float = spell_modifier[Spell.DarkStormModifier.PERIOD]
		var lifespan: float = spell_modifier[Spell.DarkStormModifier.LIFESPAN]
		var pain_stack_percent: float = spell_modifier[Spell.DarkStormModifier.PAIN_STACK_PERCENT]
		dark_storm.init(target, damage, period, lifespan, _owner, pain_stack_percent)
	else:
		dark_storm.init(target, 0, 0, 0, _owner)
	_spawn_manager.spawn_spell(dark_storm)

func _cast_contagion(spell_modifier: Dictionary) -> void:
	_owner.signal_spell_casted(_owner, Spell.Type.CONTAGION)
	var contagion: ContagionSpellArea = CONTAGION_SPELL_SCENE.instantiate()
	if multiplayer.is_server():
		var radius: float = spell_modifier[Spell.ContagionModifier.RADIUS]
		var spread_percent: float = spell_modifier[Spell.ContagionModifier.SPREAD_PERCENT]
		contagion.init(_owner, radius, spread_percent)
	_spawn_manager.spawn_spell(contagion)














 
