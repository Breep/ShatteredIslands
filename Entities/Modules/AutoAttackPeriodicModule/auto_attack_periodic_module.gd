class_name AutoAttackPeriodicModule
extends Module

# ============================== Signals ==============================

signal target_changed(new_target: Entity)

# ============================== Constants ==============================

const TICKS_PER_SECOND: int = 60

# ============================== Private variables ==============================

var _attack_speed: float = 1.0
var attack_speed: float:
	get: return _attack_speed
	set(value):
		if _attack_speed == value: return
		_attack_speed = value
		_recalculate_interval()

var _attack_strategy: TargetModule.TargettingStrategy = TargetModule.TargettingStrategy.RANDOM_ENEMY

var _current_target: Entity
var current_target: Entity:
	get: return _current_target
	set(value):
		if current_target != value:
			target_changed.emit(value)
			_current_target = value

# Tick-based timing (deterministic)
var _attack_interval_ticks: int = 60 # Number of ticks between attacks
var _ticks_remaining: int = 60 # Countdown to next attack
var _is_active: bool = false

# Module references
var _auto_attack_module: ActionSenderAutoAttackModule = null

# ============================== Node base function ==============================

func _ready() -> void:
	if _owner == null:
		Verbose.error("AutoAttackPeriodicManager needs an owner (Entity)", Verbose.Category.ENTITY_MODULE)
		return
	
	# Connect signals
	_owner.stats.attack_speed_changed.connect(_on_owner_stats_attack_speed_changed)
	_owner.died.connect(_on_owner_died)
	
	if _owner.status_module != null:
		_owner.status_module.stunned_changed.connect(_on_owner_stunned_changed)


func connect_modules(auto_attack_module: ActionSenderAutoAttackModule) -> void:
	_auto_attack_module = auto_attack_module
	# Listen for attack completion to restart cooldown
	if _auto_attack_module != null:
		_auto_attack_module.attack_completed.connect(_on_auto_attack_completed)


# ============================== Public functions ==============================

func start() -> void:
	Verbose.debug("AutoAttackPeriodicManager started for " + _owner.entity_name, Verbose.Category.ENTITY_MODULE)
	attack_speed = _owner.stats.attack_speed
	_is_active = true
	_ticks_remaining = _attack_interval_ticks


func stop() -> void:
	Verbose.debug("AutoAttackPeriodicManager stopped for " + _owner.entity_name, Verbose.Category.ENTITY_MODULE)
	_is_active = false
	if _auto_attack_module != null:
		_auto_attack_module.stop_approaching()


## Called every physics tick by Entity.process_tick() (deterministic, fixed 1/60s step).
func process_tick() -> void:
	if not _is_active:
		return
	
	if _auto_attack_module == null:
		return
	
	# Advance the attack module tick counter if an attack is in progress
	_auto_attack_module.process_tick()
	
	# If attacking, don't countdown to next attack
	if _auto_attack_module.is_attacking():
		return
	
	# Check distance during approach
	if _auto_attack_module.is_approaching() and _auto_attack_module.get_approach_target() != null:
		var approach_target: Entity = _auto_attack_module.get_approach_target()
		
		# Check if target still valid
		if not is_instance_valid(approach_target) or approach_target.is_dead():
			_auto_attack_module.stop_approaching()
			_ticks_remaining = _attack_interval_ticks
			return
		
		# Check if now in range (or infinite range)
		var distance: float = _owner.global_position.distance_to(approach_target.global_position)
		if _owner.stats.attack_range <= 0 or distance <= _owner.stats.attack_range:
			# In range! Stop approach and attack
			var target_to_attack: Entity = approach_target
			_auto_attack_module.stop_approaching()
			_auto_attack_module.execute_auto_attack(target_to_attack)
			_ticks_remaining = _attack_interval_ticks
		return
	
	# Countdown to next attack
	_ticks_remaining -= 1
	if _ticks_remaining <= 0:
		_try_auto_attack()


# ============================== Private functions ==============================

func _recalculate_interval() -> void:
	if _attack_speed <= 0:
		Verbose.error("Attack speed is <= 0", Verbose.Category.ENTITY_MODULE)
		_attack_interval_ticks = TICKS_PER_SECOND
	else:
		_attack_interval_ticks = int(TICKS_PER_SECOND / _attack_speed)


func _try_auto_attack() -> void:
	if not is_instance_valid(_owner):
		return
	
	if _auto_attack_module == null:
		return
	
	var target: Entity = _owner.target_module.get_target(_attack_strategy)
	if target == null:
		# No target found, retry next tick
		_ticks_remaining = 1
		return
	
	current_target = target
	_auto_attack_module.execute_auto_attack(target)
	_ticks_remaining = _attack_interval_ticks


# ============================== Callbacks ==============================

func _on_owner_stats_attack_speed_changed(new_attack_speed: float) -> void:
	attack_speed = new_attack_speed


func _on_owner_died() -> void:
	stop()


func _on_auto_attack_completed() -> void:
	_ticks_remaining = _attack_interval_ticks


func _on_owner_stunned_changed(is_active: bool, _duration: float, _infinite: bool) -> void:
	if is_active:
		_is_active = false
	else:
		_is_active = true
		_ticks_remaining = _attack_interval_ticks
