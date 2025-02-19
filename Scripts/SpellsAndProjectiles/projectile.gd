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
			#signal attack_done(source, target, damage, damage_type, is_critical)
			Events.attack_done.emit(_source, _target, _stats.physical_damage_flat, Utils.DamageType.PHYSICAL, _stats.is_critic)
			
			#if _stats.magical_damage_percent > 0:
				#_source.attack_percent(_target, _stats.fire_damage, Utils.DamageType.MAGIC, Utils.PercentModifier.CURRENT_HP)
			
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

# ============================== Callbacks ==============================

func _on_target_dead(_who, _true_death) -> void:
	queue_free()
