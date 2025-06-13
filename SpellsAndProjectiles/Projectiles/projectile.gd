class_name Projectile
extends Area3D

# ============================== Enums ==============================

enum ProjectileEffect {
	POISON,       # Add poison stacks
	INSTABILITY,  # Add instqbility stacks
	CRITIC,       # Do more physical damage
	BOUNCE,       # Will bounce to an other target keeping all current stats
	IGNITE        # Do more damage bases on target current hp
}

enum ProjectileType {
	AUTO_ATTACK,
}

# ============================== Constants ==============================

const _SPEED_MIN: float = 10
const _DAMMAGE_MIN: int = 1

# ============================== Network Export ==============================

@export var id: int
@export var battle_id: int
@export var stats: ProjectileStats

# ============================== Private ==============================

var source: Character
var target: Character

var _vertical_offset: float # A vertical offset to randomize the target location of the projectile
var _vertical_spread: float = 0.5 # For knowing how much the projectiles spreads

# ============================== Node base functions ==============================

func _ready() -> void:
	target.dead.connect(_on_target_dead)
	_vertical_offset = 1 + Utils.rng.randf_range(- _vertical_spread, _vertical_spread)


func _process(delta: float) -> void:
	_move_toward_target(delta)


func _on_body_entered(body: Node3D) -> void:
	if not multiplayer.is_server(): return
	if body is Character and body == target:
		if target != null:
			if stats.physical_damage_flat > 0:
				Events.damage_done.emit(source, target, stats.physical_damage_flat, Utils.DamageType.PHYSICAL, stats.is_critic)
			if stats.magical_damage_flat > 0:
				Events.damage_done.emit(source, target, stats.magical_damage_flat, Utils.DamageType.MAGICAL, stats.is_critic)
			if stats.physical_damage_percent > 0:
				_damage_percent(target, stats.physical_damage_percent, Utils.DamageType.PHYSICAL, stats.physical_damage_percent_type, stats.is_critic)
			if stats.magical_damage_percent > 0:
				_damage_percent(target, stats.magical_damage_percent, Utils.DamageType.MAGICAL, stats.magical_damage_percent_type, stats.is_critic)
			if stats.poison_stacks > 0:
				Events.condition_stacks_done.emit(source, target, stats.poison_stacks, Utils.StackType.POISON, stats.poison_duration)
			if stats.vulnerability_stacks > 0:
				Events.condition_stacks_done.emit(source, target, stats.vulnerability_stacks, Utils.StackType.VULNERABILITY, 0)
			if stats.is_bouncing:
				target = source.target_module.get_closest_enemy_from(target) # Set new target to the closest character enemy to the source
				if target == null:
					queue_free()
				stats.is_bouncing = false
				return
		
		queue_free()

# ============================== Public functions ==============================

#func init(source: Character, target: Character, stats: ProjectileStats) -> void:
	#source = source
	#target = target
	#stats = stats
	#
	#if stats.is_critic:
		#scale *= 2

# ============================== Private functions ==============================

func _move_toward_target(delta: float):
	if target == null:
		printerr("AutoAttackProjectile [", name, "] is alive but with no target")
		queue_free()
		return
	
	var target_position: Vector3 = target.global_position + _vertical_offset * Vector3.UP
	var direction: Vector3 = (target_position - global_position).normalized()
	global_position += direction * _SPEED_MIN * delta
	look_at(target.global_position)


func _damage_percent(target: Character, damage_percent: float, damage_type: Utils.DamageType, percent_modifier: Utils.PercentModifier, is_critical: bool) -> void:
	if not multiplayer.is_server(): return
	var hp: int
	match percent_modifier:
		Utils.PercentModifier.MAX_HP:
			hp = target.stats.health_max
		Utils.PercentModifier.CURRENT_HP:
			hp = target.stats.health
		Utils.PercentModifier.LOST_HP:
			hp = target.stats.health_max - source.stats.health
	var damage = hp * damage_percent  / 100.0
	Events.damage_done.emit(source, target, damage, damage_type, is_critical)

# ============================== Callbacks ==============================

func _on_target_dead(_who) -> void:
	queue_free()
