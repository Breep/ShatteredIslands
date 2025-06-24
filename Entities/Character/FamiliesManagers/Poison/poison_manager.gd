class_name PoisonManager
extends FamilyManager

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _poison_stats: FamilyPoisonStats # Ref to the owner poison stats

# ============================== Spells scenes ==============================

# ============================== Local scenes ==============================

@onready var _poison_tick_timer:Timer = %PoisonTickTimer

# ============================== Node base functions ==============================

func _ready() -> void:
	_poison_stats = _owner.families_stats.poison

# ============================== Public functions ==============================

func start() -> void:
	_lanch_optional_spells()
	_create_optional_timers()
	_poison_tick_timer.start()


func stop() -> void:
	for spell in _optional_spells:
		spell.queue_free()
	_owner.stats.poison_stacks = 0
	_poison_tick_timer.stop()
	_clear_optional_timers()


func get_reduced_damage(damage: int) -> int:
	return damage

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# [PERIODICA AGARICUS]
	if _poison_stats.periodica_agaricus_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _poison_stats.periodica_agaricus_period, _on_periodica_agaricus_timer_timeout, true))


func _clear_optional_timers() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()


func _lanch_optional_spells() -> void:
	pass

# ============================== Callbacks functions ==============================

# Handle poison stacks and damage on _owner
func _on_poison_tick_timer_timeout() -> void:
	if _owner.stats.poison_stacks > 0:
		_owner.take_damage(_owner.stats.poison_stacks, Utils.DamageType.POISON, false)


func _on_periodica_agaricus_timer_timeout() -> void:
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
	if target == null: return
	var poison_stacks = _poison_stats.periodica_agaricus_stacks
	_action_module.inflict_condition_stacks(target, poison_stacks, Utils.StackType.POISON)
