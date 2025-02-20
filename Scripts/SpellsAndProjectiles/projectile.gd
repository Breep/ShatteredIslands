class_name Projectile
extends Area3D

# ============================== Enums ==============================

enum ProjectileEffect {
	POISON,       # Add poison stacks
	VULNERABILTY, # Add vulnerability stacks
	CRITIC,       # Do more physical damage
	BOUNCE,       # Will bounce to an other target keeping all current stats
	FIRE          # Do more damage bases on target current hp
}

#TODO Rajouter un projectile_visual

# ============================== Constants ==============================

const _SPEED_MIN: float = 10
const _DAMMAGE_MIN: int = 1

# ============================== Private ==============================

var _source: Character
var _target: Character
var _stats: ProjectileStats

# ============================== Node base functions ==============================

func _ready() -> void:
	_target.dead.connect(_on_target_dead)


func _process(delta: float) -> void:
	_move_toward_target(delta)


func _on_body_entered(body: Node3D) -> void:
	if body is Character and body == _target:
		if _target != null:
			if _stats.physical_damage_flat > 0:
				Events.damage_done.emit(_source, _target, _stats.physical_damage_flat, Utils.DamageType.PHYSICAL, _stats.is_critic)
			if _stats.magical_damage_flat > 0:
				Events.damage_done.emit(_source, _target, _stats.magical_damage_flat, Utils.DamageType.MAGICAL, _stats.is_critic)
			if _stats.physical_damage_percent > 0:
				_damage_percent(_target, _stats.physical_damage_percent, Utils.DamageType.PHYSICAL, _stats.physical_damage_percent_type, _stats.is_critic)
			if _stats.magical_damage_percent > 0:
				_damage_percent(_target, _stats.magical_damage_percent, Utils.DamageType.MAGICAL, _stats.magical_damage_percent_type, _stats.is_critic)
			if _stats.poison_stacks > 0:
				Events.condition_stacks_done.emit(_source, _target, _stats.poison_stacks, Utils.StackType.POISON, _stats.poison_duration)
			if _stats.vulnerability_stacks > 0:
				Events.condition_stacks_done.emit(_source, _target, _stats.vulnerability_stacks, Utils.StackType.VULNERABILITY, 0)
			if _stats.is_bouncing:
				_target = _source.target_manager.get_closest_enemy_from(_target) # Set new target to the closest character enemy to the source
				if _target == null:
					queue_free()
				_stats.is_bouncing = false
				return
		
		queue_free()

# ============================== Public functions ==============================

func init(source: Character, target: Character, stats: ProjectileStats) -> void:
	_source = source
	_target = target
	_stats = stats
	
	if _stats.is_critic:
		scale *= 2

# ============================== Private functions ==============================

func _move_toward_target(delta: float):
	if _target == null:
		printerr("AutoAttackProjectile [", name, "] is alive but with no target")
		queue_free()
		return
	
	var direction: Vector3 = (_target.global_position - global_position).normalized()
	position += direction * _stats.speed * delta
	#look_at(_target.global_position)


func _damage_percent(target: Character, damage_percent: float, damage_type: Utils.DamageType, percent_modifier: Utils.PercentModifier, is_critical: bool) -> void:
	if not multiplayer.is_server(): return
	var hp: int
	match percent_modifier:
		Utils.PercentModifier.MAX_HP:
			hp = target.stats.health_max
		Utils.PercentModifier.CURRENT_HP:
			hp = target.stats.health
		Utils.PercentModifier.LOST_HP:
			hp = target.stats.health_max - _source.stats.health
	var damage = hp * damage_percent  / 100.0
	Events.damage_done.emit(_source, target, damage, damage_type, is_critical)

# ============================== Callbacks ==============================

func _on_target_dead(_who, _true_death) -> void:
	queue_free()
