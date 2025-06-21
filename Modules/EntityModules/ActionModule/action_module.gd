class_name ActionModule
extends Module

@export var _storm_manager: StormManager
@export var _defense_manager: DefenseManager
@export var _life_manager: LifeManager
@export var _fire_manager: FireManager
@export var _serenity_manager: SerenityManager

var _spawn_manager: SpawnManager

const METEOR_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/Meteor/meteor.tscn")

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
	var multiplier = _get_damage_multipliers()
	if damage_type == Utils.DamageType.PHYSICAL:
		damage *= multiplier["physical"]
	elif damage_type == Utils.DamageType.MAGICAL:
		damage *= multiplier["magical"]
	
	target.take_damage(damage, damage_type, multiplier["is_critical"], _owner)


# Instantly attack the target - Apply cards damages multiplier if there are some
func direct_attack_percent(target: Character, damage_percent: float, damage_type: Utils.DamageType, percent_modifier: Utils.PercentModifier) -> void:
	if not multiplayer.is_server(): return
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
func projectile_attack(target: Character, projectile_type: Projectile.ProjectileType, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
	if not multiplayer.is_server(): return
	var multiplier = _get_damage_multipliers()
	projectile_stats.is_critic = multiplier["is_critical"]
	projectile_stats.physical_damage_flat *= multiplier["physical"]
	projectile_stats.physical_damage_percent *= multiplier["physical"]
	projectile_stats.magical_damage_flat *= multiplier["magical"]
	projectile_stats.magical_damage_percent *= multiplier["magical"]
	_spawn_projectile(target, projectile_type, projectile_spawn, projectile_stats)


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
	_spawn_manager.spawn_projectile(_owner, target, projectile_type, projectile_spawn, projectile_stats)

# ============================== Heal ==============================

# [Server only]
func heal(target: Character, heal_amount: int) -> void:
	if not multiplayer.is_server(): return
	target.take_heal(heal_amount, _owner)


func heal_percent(target: Character, percent: float, percent_modifier: Utils.PercentModifier) -> void:
	if not multiplayer.is_server(): return
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
	target.take_condition_stacks(stacks_number, stack_type, _owner)

# ============================== Condition stacks ==============================

func cast_spell(target: Entity, spell_type: Spell.Type, spell_modifier: Dictionary) -> void:
	match spell_type:
		Spell.Type.METEOR:
			_cast_meteor(target, spell_modifier)


func _cast_meteor(target: Entity, spell_modifier: Dictionary) -> void:
	var meteor: Meteor = METEOR_SCENE.instantiate()
	var ignite_stacks: int = spell_modifier[Spell.MeteorModifier.IGNITE_STACKS]
	var damage_per_stack: int = spell_modifier[Spell.MeteorModifier.DAMAGE_PER_STACK]
	meteor.init(target, ignite_stacks, damage_per_stack, _owner)
	_spawn_manager.spawn_spell(meteor)


















 
