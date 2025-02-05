class_name ShadowManager
extends Node

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _source: Character # Ref to character owner
var _shadow_stats: CharacterShadowStats # Ref to the owner shadow stats

var _previous_global_position: Vector3
var _total_distance: float = 0 # Total distance moved by the character

var _optional_timers: Array[Timer]
var _optional_distance_callbacks: Array[Callable]

# ============================== Spells scenes ==============================

# ============================== Public functions ==============================

func start(source: Character, shadow_stats: CharacterShadowStats) -> void:
	print("ShadowManager: Starting")
	if source == null:
		printerr("ShadowManager: source undef")
		return
	if shadow_stats == null:
		printerr("ShadowManager: fire_stats undef")
		return
	
	_source = source
	_shadow_stats = shadow_stats
	_attach_optional_distance_callbacks()
	_previous_global_position = _source.global_position


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()

# ============================== Private functions ==============================

func _attach_optional_distance_callbacks() -> void:
	if _shadow_stats.shadow_bolt_damage > 0:
		_optional_distance_callbacks.append(_try_cast_shadow_bolt)


func _call_optional_distance_callbacks() -> void:
	for callback in _optional_distance_callbacks:
		callback.call()

# ============================== Timer function ==============================


func _on_check_distance_timer_timeout() -> void:
	if _previous_global_position == _source.global_position:
		return
	
	var distance = _source.global_position.distance_to(_previous_global_position)
	_total_distance += distance
	__distance_since_last_shadow_bolt += distance
	_previous_global_position = _source.global_position
	_call_optional_distance_callbacks()

# ============================== Callbacks functions ==============================

var __distance_since_last_shadow_bolt: float = 0
func _try_cast_shadow_bolt() -> void:
	if __distance_since_last_shadow_bolt > _shadow_stats.shadow_bolt_distance:
		__distance_since_last_shadow_bolt -= _shadow_stats.shadow_bolt_distance
		var target: Character = _source.target_manager.get_target(TargetManager.TargettingStrategy.CLOSEST_ENEMY)
		if target == null:
			return
		print("CASTING SHADOW BOLT ", __distance_since_last_shadow_bolt, " ", _shadow_stats.shadow_bolt_distance)
		target.take_damage_flat(_source, _shadow_stats.shadow_bolt_damage, Utils.DamageType.MAGIC)
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
