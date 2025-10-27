class_name FireManager
extends FamilyManager

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _fire_stats: FamilyFireStats # Ref to the owner fire stats

# ============================== Local nodes ==============================

@onready var _ignite_timer: Timer = %IgniteTimer

@export_group("Configuration")
@export var _ignite_decay_percent: float = 20.0
@export var _ignite_percent_per_stack: float = 0.05

# ============================== Node base functions ==============================

func _ready() -> void:
	_fire_stats = _owner.families_stats.fire

# ============================== Public functions ==============================

func start() -> void:
	_create_optional_timers()
	_lanch_optional_spells()
	_ignite_timer.start()


func stop() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()
	for spell in _optional_spells:
		spell.queue_free()
	_ignite_timer.stop()


func get_reduced_damage(damage: int, _damage_type: Utils.DamageType) -> int:
	return damage


# Storm of fire
func get_increased_damage(damage: float, _damage_type: Utils.DamageType) -> float:
	return damage

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	if _fire_stats.periodic_ignite_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _fire_stats.periodic_ignite_period, _on_periodic_ignite_timer_timeout, true))
	
	if _fire_stats.meteor_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _fire_stats.meteor_period, _on_meteor_timer_timeout, true))


func _lanch_optional_spells() -> void:
	pass

# ============================== Callbacks functions ==============================

func _on_firebolt_timer_timeout() -> void:
	pass


func _on_periodic_ignite_timer_timeout() -> void:
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if target != null:
		_owner.inflict_condition_stacks(target, _fire_stats.periodic_ignite_stacks, Utils.StackType.IGNITE)


func _on_ignite_timer_timeout() -> void:
	if _owner.stats.ignite_stacks > 0:
		var percent: float = _ignite_percent_per_stack * _owner.stats.ignite_stacks
		_owner.take_damage_percent(percent, Utils.PercentModifier.CURRENT_HP, Utils.DamageType.MAGICAL, false)
	
	var decay: int = (_owner.stats.ignite_stacks * _ignite_decay_percent / 100.0) as int
	decay = clampi(decay, 1, decay)
	_owner.stats.ignite_stacks -= decay


func _on_meteor_timer_timeout() -> void:
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if target != null:
		var spell_modifier: Dictionary = {
			Spell.MeteorModifier.IGNITE_STACKS: _fire_stats.meteor_ignite_stacks,
			Spell.MeteorModifier.DAMAGE_PER_STACK: _fire_stats.meteor_damage_per_stack
		}
		_owner.cast_spell(target, Spell.Type.METEOR, spell_modifier)




 
