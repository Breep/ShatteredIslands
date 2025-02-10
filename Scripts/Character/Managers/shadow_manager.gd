class_name ShadowManager
extends Node

# ============================== Signals ==============================

signal gain_max_hp_triggered(hp: int)

const UNTARGETABLE_CHECK_PERIOD: float = 0.1 # Check if the player is still untargetable

# ============================== Private variables ==============================

var _source: Character # Ref to character owner
var _shadow_stats: CharacterShadowStats # Ref to the owner shadow stats

var _previous_global_position: Vector3
var _total_distance: float = 0 # Total distance moved by the character

var _optional_distance_callbacks: Array[Callable]
var _optional_timers: Array[Timer]

# ============================== Local scenes ==============================

@onready var _check_distance_timer: Timer = %CheckDistanceTimer

# ============================== Public functions ==============================

func init(source: Character, shadow_stats: CharacterShadowStats) -> void:
	if source == null:
		printerr("ShadowManager: source undef")
		return
	if shadow_stats == null:
		printerr("ShadowManager: fire_stats undef")
		return
	
	_source = source
	_shadow_stats = shadow_stats


func start() -> void:
	_attach_optional_distance_callbacks()
	_previous_global_position = _source.global_position
	_check_distance_timer.start()
	_create_optional_timers()


func stop() -> void:
	for callback in _optional_distance_callbacks:
		_optional_distance_callbacks.erase(callback)
	
	for timer in _optional_timers:
		timer.stop()

# ============================== Private functions ==============================

func _attach_optional_distance_callbacks() -> void:
	if _shadow_stats.shadow_bolt_activated:
		_optional_distance_callbacks.append(_try_cast_shadow_bolt)
	
	if _shadow_stats.increase_aa_damage_activated:
		_optional_distance_callbacks.append(_try_increase_aa_damage)
	
	if _shadow_stats.gain_armor_stacks_activated:
		_optional_distance_callbacks.append(_try_gain_armor_stacks)
	
	if _shadow_stats.heal_ally_activated:
		_optional_distance_callbacks.append(_try_heal)
	
	if _shadow_stats.gain_max_hp_activated:
		_optional_distance_callbacks.append(_try_gain_max_hp)
	
	if _shadow_stats.inflict_poison_stacks_activated:
		_optional_distance_callbacks.append(_try_inflict_poison_stacks)
	
	if _shadow_stats.untargetable_activated:
		_optional_distance_callbacks.append(_try_untargetable)


func _create_optional_timers() -> void:
	# In the Shadow
	if _shadow_stats.untargetable_activated:
		_optional_timers.append(Utils.create_optional_timer(self, UNTARGETABLE_CHECK_PERIOD, _on_untargetable_timer_timeout))
	
	# SHadow step
	if _shadow_stats.shadow_step_activated:
		_optional_timers.append(Utils.create_optional_timer(self, _shadow_stats.shadow_step_period, _on_shadow_step_timer_timeout))


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
	__distance_since_last_increase_aa_damage += distance
	__distance_since_last_gain_armor_stacks += distance
	__distance_since_last_heal += distance
	__distance_since_last_gain_max_hp += distance
	__distance_since_last_inflict_poison_stacks += distance
	__distance_since_last_untargetable += distance
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
		_source.attack(target, _shadow_stats.shadow_bolt_damage, Utils.DamageType.MAGIC)


var __distance_since_last_increase_aa_damage: float = 0
func _try_increase_aa_damage() -> void:
	if __distance_since_last_increase_aa_damage > _shadow_stats.increase_aa_damage_distance:
		__distance_since_last_increase_aa_damage -= _shadow_stats.increase_aa_damage_distance
		_source.stats.attack_damage += _shadow_stats.increase_aa_damage_value


var __distance_since_last_gain_armor_stacks: float = 0
func _try_gain_armor_stacks() -> void:
	if __distance_since_last_gain_armor_stacks > _shadow_stats.gain_armor_stacks_distance:
		__distance_since_last_gain_armor_stacks -= _shadow_stats.gain_armor_stacks_distance
		_source.stats.defense.armor_stacks += _shadow_stats.gain_armor_stacks_value


var __distance_since_last_heal: float = 0
func _try_heal() -> void:
	if __distance_since_last_heal > _shadow_stats.heal_ally_distance:
		__distance_since_last_heal -= _shadow_stats.heal_ally_distance
		var target = _source.target_manager.get_target(TargetManager.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
		_source.heal(target, _shadow_stats.heal_ally_value)


var __distance_since_last_gain_max_hp: float = 0
func _try_gain_max_hp() -> void:
	if __distance_since_last_gain_max_hp > _shadow_stats.gain_max_hp_distance:
		__distance_since_last_gain_max_hp -= _shadow_stats.gain_max_hp_distance
		gain_max_hp_triggered.emit(_shadow_stats.gain_max_hp_value)


var __distance_since_last_inflict_poison_stacks: float = 0
func _try_inflict_poison_stacks() -> void:
	if __distance_since_last_inflict_poison_stacks > _shadow_stats.inflict_poison_stacks_distance:
		__distance_since_last_inflict_poison_stacks -= _shadow_stats.inflict_poison_stacks_distance
		var target = _source.target_manager.get_target(TargetManager.TargettingStrategy.RANDOM_ENEMY)
		if target == null:
			return
		target.take_poison_stacks(_source, _shadow_stats.inflict_poison_stacks_value, 5) # TODO need a duration value in poison stats


var __distance_since_last_untargetable: float = 0
func _try_untargetable() -> void:
	if __distance_since_last_untargetable > _shadow_stats.untargetable_distance:
		__distance_since_last_untargetable -= _shadow_stats.untargetable_distance
		__timer_untargetable += _shadow_stats.untargetable_time
		_shadow_stats.untargetable = true


# Put back the character targetable after a period of time
var __timer_untargetable: float = 0
func _on_untargetable_timer_timeout() -> void:
	if __timer_untargetable > 0:
		__timer_untargetable -= UNTARGETABLE_CHECK_PERIOD
	
	if __timer_untargetable <= 0 && _shadow_stats.untargetable:
		_shadow_stats.untargetable = false
		__timer_untargetable = 0


func _on_shadow_step_timer_timeout() -> void:
	var target = _source.target_manager.get_target(TargetManager.TargettingStrategy.FARTHEST)
	if target == null:
		return
	
	_source.global_position = target.global_position




		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
