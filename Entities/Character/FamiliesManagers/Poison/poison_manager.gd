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
	_add_attack_modifiers()
	_poison_tick_timer.start()


func stop() -> void:
	for spell in _optional_spells:
		spell.queue_free()
	_poison_tick_timer.stop()
	_clear_optional_timers()


func get_reduced_damage(damage: int, damage_type: Utils.DamageType) -> int:
	if not damage_type == Utils.DamageType.POISON: return damage
	if not _poison_stats.poison_antidote_activated: return damage
	var damage_reduction: int = int(float(damage) * _poison_stats.poison_antidote_decrease / 100.0)
	return damage - damage_reduction

# ============================== Private functions ==============================

func _add_attack_modifiers() -> void:
	if _poison_stats.poison_rusty_dagger_activated:
		var aa_modifier := AutoAttackModifier.new()
		aa_modifier.id = "Rusty Dagger"
		aa_modifier.tags = [AutoAttackModifier.TagType.CARD]
		aa_modifier.on_attack_logic_callback = _on_rusty_dagger_logic_callback
		aa_modifier.is_one_time_effect = false
		_owner.auto_attack_modifier_registry.register_modifier(aa_modifier)

func _create_optional_timers() -> void:
	# [PERIODICA AGARICUS]
	if _poison_stats.poison_flask_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _poison_stats.poison_flask_period, _on_periodica_agaricus_timer_timeout, true))


func _clear_optional_timers() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()


func _lanch_optional_spells() -> void:
	pass

# ============================== Callbacks functions ==============================

# Handle poison stacks and damage on _owner
func _on_poison_tick_timer_timeout() -> void:
	if not multiplayer.is_server(): return
	if _owner.stats.poison_stacks > 0:
		_owner.take_damage(_owner.stats.poison_stacks, Utils.DamageType.POISON, false)


func _on_periodica_agaricus_timer_timeout() -> void:
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
	if target == null: return
	var poison_stacks = _poison_stats.poison_flask_stacks
	_action_module.inflict_condition_stacks(target, poison_stacks, Utils.StackType.POISON)


func _on_rusty_dagger_logic_callback(cb_vars: Dictionary) -> void:
	if not cb_vars.has(AutoAttackModifier.VarType.PROJECTILE_STATS): return
	var proj_stats: ProjectileStats = cb_vars[AutoAttackModifier.VarType.PROJECTILE_STATS]
	if Utils.is_randomize_modifier_active(_poison_stats.poison_rusty_dagger_chance):
		proj_stats.poison_stacks += _poison_stats.poison_rusty_dagger_stacks

















 
