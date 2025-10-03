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

const _SPEED_MIN: float = 20
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
	if body is Character and body == target:
		var physical_damage_done_flat: int
		if not multiplayer.is_server():
			queue_free()
			return
		var physical_damage: int = stats.physical_damage_flat
		physical_damage += _get_damage_percent(stats.physical_damage_percent, stats.physical_damage_percent_type)
		if physical_damage > 0:
			physical_damage_done_flat = target.take_damage(physical_damage, Utils.DamageType.PHYSICAL, stats.is_critic, source, Utils.AttackType.AUTO_ATTACK)
		var magical_damage: int = stats.magical_damage_flat
		magical_damage += _get_damage_percent(stats.magical_damage_percent, stats.magical_damage_percent_type)
		if magical_damage > 0:
			target.take_damage(magical_damage, Utils.DamageType.MAGICAL, stats.is_critic, source)
		if stats.is_bouncing:
			target = source.target_module.get_closest_enemy_from(target) # Set new target to the closest character enemy to the source
			if target == null:
				queue_free()
			stats.is_bouncing = false
			return
		
		if stats.on_hit_logic_callback.is_valid():
			stats.on_hit_logic_callback.call({AutoAttackModifier.VarType.PHYSICAL_DAMAGE:physical_damage_done_flat})
		if stats.on_hit_visual_callback.is_valid():
			stats.on_hit_visual_callback.call({AutoAttackModifier.VarType.VISUAL_POS:global_position})
		queue_free()

# ============================== Private functions ==============================

func _move_toward_target(delta: float):
	if target == null:
		printerr("AutoAttackProjectile [", name, "] is alive but with no target")
		queue_free()
		return
	
	var target_position: Vector3 = target.global_position + _vertical_offset * Vector3.UP
	var direction: Vector3 = (target_position - global_position).normalized()
	global_position += direction * _SPEED_MIN * delta
	look_at(target.global_position + _vertical_offset * Vector3.UP)


func _get_damage_percent(damage_percent: float, percent_modifier: Utils.PercentModifier) -> int:
	var hp: int
	match percent_modifier:
		Utils.PercentModifier.MAX_HP:
			hp = target.stats.health_max
		Utils.PercentModifier.CURRENT_HP:
			hp = target.stats.health
		Utils.PercentModifier.LOST_HP:
			hp = target.stats.health_max - source.stats.health
	return (hp * damage_percent  / 100.0) as int

# ============================== Callbacks ==============================

func _on_target_dead(_who) -> void:
	queue_free()
