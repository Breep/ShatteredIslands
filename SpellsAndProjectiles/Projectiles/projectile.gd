class_name Projectile
extends Area3D

# ============================== Enums ==============================

enum ProjectileEffect {
	POISON,       # Add poison stacks
	INSTABILITY,  # Add instability stacks
	CRITIC,       # Do more physical damage
	BOUNCE,       # Will bounce to an other target keeping all current stats
	IGNITE        # Do more damage bases on target current hp
}

enum ProjectileType {
	AUTO_ATTACK,
	VENOMOUS_DART,
	SNAKE,
	COSMIC_BOLT,
	SHIELD_THROW
}

enum TrajectoryType {
	STRAIGHT,
	ARC,           # Sinusoidal height over straight interpolation
	BEZIER,        # Quadratic Bezier curve with control point height
	ZIGZAG,        # Lateral sine wobble while advancing
	HOMING_SMOOTH, # Smooth-turn homing (rate-limited steering)
}

const PROJECTILE_CONF_REF: Dictionary[ProjectileType, ProjectileConf] = {
	ProjectileType.AUTO_ATTACK: preload("res://SpellsAndProjectiles/Projectiles/AutoAttack/default_auto_attack_conf.tres"),
	ProjectileType.VENOMOUS_DART: preload("res://SpellsAndProjectiles/Projectiles/VenomousDart/venomous_dart_conf.tres"),
	ProjectileType.SNAKE: preload("res://SpellsAndProjectiles/Projectiles/Snake/snake_proj_conf.tres"),
	ProjectileType.COSMIC_BOLT: preload("res://SpellsAndProjectiles/Projectiles/CosmicBolt/cosmic_bolt_conf.tres"),
	ProjectileType.SHIELD_THROW: preload("res://SpellsAndProjectiles/Projectiles/ShieldThrow/shield_throw_conf.tres")
}

# ============================== Constants / Exports ==============================

const _DAMAGE_MIN: int = 1

@export var id: int
@export var battle_id: int
@export var stats: ProjectileStats

var _trajectory_type: TrajectoryType = TrajectoryType.STRAIGHT
var _speed: float = 20.0                         # Base forward speed (units/s)
var _lifetime_max: float = 6.0                   # Safety fuse
var _arc_height: float = 2.0                     # Peak height (world units)
var _bezier_control_height: float = 5.0          # Control point height for BEZIER
var _randomize_arc_by: float = 0.5               # ± randomness on height
var _zigzag_amplitude: float = 0.5              # Lateral offset amplitude
var _zigzag_frequency: float = 5.0               # Cycles per second along the path
var _turn_rate_deg_per_s: float = 360.0          # Max turn speed
var _homing_retarget_each_frame: bool = true     # If false, homes to snapshot

# ============================== Private ==============================

var source: Entity
var target: Entity
var projectile_type: ProjectileType = ProjectileType.AUTO_ATTACK

var _projectile_conf: ProjectileConf

var _vertical_offset: float
var _vertical_spread: float = 0.5

# Travel bookkeeping (for parametric paths)
var _start_pos: Vector3
var _start_target_snapshot: Vector3
var _dir_snapshot: Vector3
var _travel_time: float = 0.001
var _t: float = 0.0
var _life: float = 0.0

# For HOMING_SMOOTH velocity
var _velocity: Vector3 = Vector3.ZERO

var _hit_history: Array[Entity] = []

@onready var _visual_node: Node3D = %VisualNode

# ============================== Node base functions ==============================

func _ready() -> void:
	if target:
		target.died.connect(_on_target_died)
	_start_pos = global_position
	_vertical_offset = 1.0 + Utils.rng.randf_range(-_vertical_spread, _vertical_spread)
	_projectile_conf = PROJECTILE_CONF_REF[projectile_type]
	_update_conf()
	_update_visual()
	_snapshot_target_and_prepare_path()

func _process(delta: float) -> void:
	_life += delta
	if _life > _lifetime_max:
		queue_free()
		return
	_move_toward_target(delta)

func _on_body_entered(body: Node3D) -> void:
	if target == null:
		return
	
	if body is Entity and body == target:
		# 1. On ajoute la cible actuelle à l'historique
		_hit_history.append(target)
		
		var physical_damage_done_flat: float
		if not multiplayer.is_server():
			queue_free()
			return
	
		var physical_damage: float = stats.physical_damage_flat
		if physical_damage > 0:
			physical_damage_done_flat = target.take_damage(
				physical_damage,
				Utils.DamageType.PHYSICAL,
				stats.physical_is_critical,
				source,
				Utils.AttackType.AUTO_ATTACK
			)
		source.signal_action_done(target, Utils.ActionType.DAMAGE_PHYSICAL, stats.physical_base_damage, physical_damage_done_flat, stats.physical_is_critical)
		if stats.physical_is_critical:
			source.signal_critical_action_done(target, Utils.ActionType.DAMAGE_PHYSICAL, stats.physical_base_damage, physical_damage_done_flat)
	
		var magical_damage: float = stats.magical_damage_flat
		if magical_damage > 0:
			target.take_damage(
				magical_damage,
				Utils.DamageType.MAGICAL,
				stats.magical_is_critical,
				source)
	
		if stats.poison_stacks > 0:
			if source != null: source.inflict_condition_stacks(target, stats.poison_stacks, Utils.StackType.POISON)
			else: target.take_condition_stacks(stats.poison_stacks, Utils.StackType.POISON, stats.poison_stacks_is_critical)
		
		# --- CALLBACKS ---
		for cb: Callable in stats.on_hit_logic_callbacks:
			if cb.is_valid():
				cb.call({
					AutoAttackModifier.VarType.PHYSICAL_DAMAGE: physical_damage_done_flat,
					AutoAttackModifier.VarType.TARGET: target
					})
		for cb: Callable in stats.on_hit_visual_callbacks:
			if cb.is_valid():
				cb.call({
					AutoAttackModifier.VarType.VISUAL_POS: global_position
					})
		
		# --- BOUNCING ---
		if stats.is_bouncing and stats.bounces_remaining > 0:
			stats.bounces_remaining -= 1
			var new_target: Entity = source.target_module.get_target_from(
				target.global_position,
				TargetModule.TargettingFromStrategy.CLOSEST_ENEMY,
				_hit_history)
			
			if new_target != null:
				_set_target(new_target) 
				return
		
		queue_free()

# ============================== Private functions ==============================

func _update_conf() -> void:
	_trajectory_type = _projectile_conf.trajectory_type
	_speed = _projectile_conf.speed
	_lifetime_max = _projectile_conf.lifetime_max
	_arc_height = _projectile_conf.arc_height
	_bezier_control_height = _projectile_conf.bezier_control_height
	_randomize_arc_by = _projectile_conf.randomize_arc_by
	_zigzag_amplitude = _projectile_conf.zigzag_amplitude
	_zigzag_frequency = _projectile_conf.zigzag_frequency
	_turn_rate_deg_per_s = _projectile_conf.turn_rate_deg_per_s
	_homing_retarget_each_frame = _projectile_conf.homing_retarget_each_frame

func _update_visual() -> void:
	for child: Node3D in _visual_node.get_children():
		child.queue_free()
	var visual: Node3D = _projectile_conf.visual_scene.instantiate()
	_visual_node.add_child(visual)

func _set_target(new_target: Entity) -> void:
	if target:
		if target.died.is_connected(_on_target_died):
			target.died.disconnect(_on_target_died)
	target = new_target
	if target:
		target.died.connect(_on_target_died)
	# Reset path from *current* position toward new target
	_start_pos = global_position
	_snapshot_target_and_prepare_path()
	_t = 0.0
	# Keep current speed direction for smooth homing handoff
	if _velocity == Vector3.ZERO:
		_velocity = (target.global_position - global_position).normalized() * _speed

func _snapshot_target_and_prepare_path() -> void:
	if target == null:
		return
	_start_target_snapshot = target.global_position + _vertical_offset * Vector3.UP
	var dist := _start_pos.distance_to(_start_target_snapshot)
	_travel_time = max(0.001, dist / max(0.001, _speed))
	_dir_snapshot = ( _start_target_snapshot - _start_pos ).normalized()

func _move_toward_target(delta: float) -> void:
	if target == null:
		printerr("Projectile [", name, "] is alive but with no target")
		queue_free()
		return

	match _trajectory_type:
		TrajectoryType.STRAIGHT:
			_move_straight(delta)
		TrajectoryType.ARC:
			_move_arc(delta)
		TrajectoryType.BEZIER:
			_move_bezier(delta)
		TrajectoryType.ZIGZAG:
			_move_zigzag(delta)
		TrajectoryType.HOMING_SMOOTH:
			_move_homing_smooth(delta)

func _move_straight(delta: float) -> void:
	var tgt := target.global_position + _vertical_offset * Vector3.UP
	var dir := (tgt - global_position).normalized()
	global_position += dir * _speed * delta
	look_at(tgt)

func _move_arc(delta: float) -> void:
	_t = min(1.0, _t + delta / _travel_time)
	# Lerp along line, then add vertical sinusoid peaking at t=0.5
	var tgt := target.global_position + _vertical_offset * Vector3.UP
	var base := _start_pos.lerp(tgt, _t)
	var h := (_arc_height + Utils.rng.randf_range(-_randomize_arc_by, _randomize_arc_by)) * sin(PI * _t)
	global_position = base + Vector3.UP * h
	# Face movement direction (approximate with next sample)
	var next_t = min(1.0, _t + 0.02)
	var next_base := _start_pos.lerp(tgt, next_t)
	var next_h := (_arc_height) * sin(PI * next_t)
	look_at(next_base + Vector3.UP * next_h)

func _move_bezier(delta: float) -> void:
	_t = min(1.0, _t + delta / _travel_time)
	var tgt := _start_target_snapshot # Bezier uses initial snapshot for cleaner curve
	var p0 := _start_pos
	var mid := (p0 + tgt) * 0.5 + Vector3.UP * (_bezier_control_height + Utils.rng.randf_range(-_randomize_arc_by, _randomize_arc_by))
	# Quadratic Bezier: B(t)=Lerp(Lerp(p0, mid, t), Lerp(mid, tgt, t), t)
	var a := p0.lerp(mid, _t)
	var b := mid.lerp(tgt, _t)
	var pos := a.lerp(b, _t)
	look_at(pos + (b - a).normalized())
	global_position = pos

func _move_zigzag(delta: float) -> void:
	_t = min(1.0, _t + delta / _travel_time)
	var tgt := target.global_position + _vertical_offset * Vector3.UP
	var forward := (tgt - _start_pos).normalized()
	var up := Vector3.UP
	var right := up.cross(forward)
	if right.length_squared() < 0.0001:
		right = Vector3.RIGHT # fallback if forward ~ up
	right = right.normalized()
	var base := _start_pos.lerp(tgt, _t)
	var lateral := right * (_zigzag_amplitude * sin(2.0 * PI * _zigzag_frequency * _t * _travel_time))
	global_position = base + lateral
	look_at(base + forward) # roughly forward along path

func _move_homing_smooth(delta: float) -> void:
	var tgt_pos := target.global_position + _vertical_offset * Vector3.UP
	var desired_dir := (tgt_pos - global_position).normalized()
	if not _homing_retarget_each_frame:
		# Home toward snapshot direction->target position captured at start
		desired_dir = (_start_target_snapshot - global_position).normalized()
	# Rotate current velocity toward desired direction with a max angular speed
	if _velocity == Vector3.ZERO:
		_velocity = desired_dir * _speed
	var cur_dir := _velocity.normalized()
	var max_rad := deg_to_rad(_turn_rate_deg_per_s) * delta
	var new_dir := cur_dir.slerp(desired_dir, clamp(max_rad / (acos(clamp(cur_dir.dot(desired_dir), -1, 1)) + 1e-5), 0.0, 1.0))
	_velocity = new_dir * _speed
	global_position += _velocity * delta
	look_at(global_position + _velocity)

# ============================== Callbacks ==============================

func _on_target_died(_who) -> void:
	queue_free()
