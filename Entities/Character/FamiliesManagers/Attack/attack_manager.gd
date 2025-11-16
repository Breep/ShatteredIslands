class_name AttackManager
extends FamilyManager

# ============================== Signals ==============================

# ============================== Constants ==============================

const GATLING_TIME: float = 1

# ============================== Export ==============================

#@export_group("External Nodes")
#@export var _auto_attack_module: AutoAttackModule

# ============================== Public variables ==============================

# [Reflecto Belt]
var reflecto_belt_number_of_attacks: int = 0
var reflecto_belt_damage_percent: float

# ============================== Private variables ==============================

var _attack_stats: FamilyAttackStats # Ref to the owner attack stats
var _aa_counter: int

var _on_gatling_gun_timer_start: float = 0

# ============================== Public functions ==============================

func _ready() -> void:
	_attack_stats = _owner.families_stats.auto_attack


func start() -> void:
	_aa_counter = 0
	_create_optional_timers()
	for timer in _optional_timers:
		timer.start()


func stop() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()


func apply_stats_modifiers() -> void:
	if _attack_stats.diamond_sword_activated:
		var stat_modifier := StatModifier.new()
		stat_modifier.id = "Diamond Sword"
		stat_modifier.stat_type = EntityStats.StatType.AD
		stat_modifier.calc_type = StatModifier.CalcType.ADD
		stat_modifier.value = _attack_stats.diamond_sword_attack
		stat_modifier.tags = [StatModifier.TagType.CARD]
		_owner.stats_manager.update_modifier(stat_modifier)
	
	if _attack_stats.twin_blade_activated:
		var stat_modifier := StatModifier.new()
		stat_modifier.id = "Twin Blade"
		stat_modifier.stat_type = EntityStats.StatType.AA_SPEED
		stat_modifier.calc_type = StatModifier.CalcType.MULT
		stat_modifier.value = _attack_stats.twin_blade_speed / 100.0
		stat_modifier.tags = [StatModifier.TagType.CARD]
		_owner.stats_manager.update_modifier(stat_modifier)

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# [Gatling Gun]
	if _attack_stats.gatling_gun_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, GATLING_TIME, _on_gatling_gun_timer_timeout, true))
		_on_gatling_gun_timer_start = Time.get_ticks_msec()


func _remove_random_debuff_stack(stack_number: int) -> void:
	var random_stacks_types: Array[Utils.StackType]
	if _owner.stats.poison_stacks > 0: random_stacks_types.append(Utils.StackType.POISON)
	if _owner.stats.ignite_stacks > 0: random_stacks_types.append(Utils.StackType.IGNITE)
	if random_stacks_types.is_empty(): return
	var random_stack_type: Utils.StackType = random_stacks_types.pick_random()
	match random_stack_type:
		Utils.StackType.POISON: _owner.stats.poison_stacks -= stack_number
		Utils.StackType.IGNITE: _owner.stats.ignite_stacks -= stack_number

# ============================== Callbacks functions ==============================

func _on_gatling_gun_timer_timeout() -> void:
	var time_elapsed: float = (Time.get_ticks_msec() - _on_gatling_gun_timer_start) / 1000.0
	var attack_speed_boost: float = remap(time_elapsed, 0, _attack_stats.gatling_gun_duration, \
			_attack_stats.gatling_gun_min, _attack_stats.gatling_gun_max)
	var gatling_speed_boost: float = clampf(attack_speed_boost, _attack_stats.gatling_gun_min, _attack_stats.gatling_gun_max)
	var stat_modifier := StatModifier.new()
	stat_modifier.id = "Gatling Gun"
	stat_modifier.stat_type = EntityStats.StatType.AA_SPEED
	stat_modifier.calc_type = StatModifier.CalcType.MULT
	stat_modifier.value = gatling_speed_boost / 100.0
	stat_modifier.tags = [StatModifier.TagType.CARD]
	_owner.stats_manager.update_modifier(stat_modifier)
