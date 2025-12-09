class_name AttackManager
extends FamilyManager

# ============================== Signals ==============================

# ============================== Constants ==============================

const GATLING_TIME: float = 1

# ============================== Export ==============================

#@export_group("External Nodes")
#@export var _auto_attack_module: AutoAttackModule

# ============================== Private variables ==============================

var _attack_stats: FamilyAttackStats # Ref to the owner attack stats
var _aa_counter: int

var _on_gatling_gun_timer_start: float = 0

# [FIGHT BACK]
var _dodge_number: int

# ============================== Public functions ==============================

func _ready() -> void:
	_attack_stats = _owner.families_stats.auto_attack


func start() -> void:
	_aa_counter = 0
	_create_optional_timers()
	for timer in _optional_timers:
		timer.start()
	_add_stat_modifiers()
	_add_action_modifiers()
	_add_attack_modifiers()
	_dodge_number = 0
	
	# [BLADE RUSH]
	if _attack_stats.blade_rush_activated:
		_apply_blade_rush()


func stop() -> void:
	_clear_attack_modifiers()

# ============================== Private functions ==============================

#region optinal timer

func _create_optional_timers() -> void:
	# [GATLING GUN]
	if _attack_stats.gatling_gun_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, GATLING_TIME, _on_gatling_gun_timer_timeout, true))
		_on_gatling_gun_timer_start = Time.get_ticks_msec()

func _clear_optional_timers() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()
#endregion

#region aa modifier

func _add_attack_modifiers() -> void:
	# [PROTECTO'SPEAR]
	if _attack_stats.protectospear_activated:
		var aa_modifier := AutoAttackModifier.new()
		aa_modifier.id = "Protecto'Spear"
		aa_modifier.tags = [AutoAttackModifier.TagType.CARD]
		aa_modifier.on_attack_logic_callback = _on_auto_attack_protectospear
		aa_modifier.is_one_time_effect = false
		_owner.auto_attack_modifier_registry.register_modifier(aa_modifier)
		
	# [RUSTY DAGGER]
	if _attack_stats.rusty_dagger_activated:
		var aa_modifier := AutoAttackModifier.new()
		aa_modifier.id = "Rusty Dagger"
		aa_modifier.tags = [AutoAttackModifier.TagType.CARD]
		aa_modifier.on_attack_logic_callback = _on_auto_attack_rusty_dagger
		aa_modifier.is_one_time_effect = false
		_owner.auto_attack_modifier_registry.register_modifier(aa_modifier)
		
	# [SCORCHING BLADE]
	if _attack_stats.scorching_blade_activated:
		var aa_modifier := AutoAttackModifier.new()
		aa_modifier.id = "Scorching Blade"
		aa_modifier.tags = [AutoAttackModifier.TagType.CARD]
		aa_modifier.on_hit_logic_callback = _on_hit_scorching_blade
		aa_modifier.is_one_time_effect = false
		_owner.auto_attack_modifier_registry.register_modifier(aa_modifier)
		
	# [SURGICAL KNIFE]
	if _attack_stats.surgical_knife_activated:
		var aa_modifier := AutoAttackModifier.new()
		aa_modifier.id = "Surgical Knife"
		aa_modifier.tags = [AutoAttackModifier.TagType.CARD]
		aa_modifier.on_attack_logic_callback = _on_auto_attack_surgical_knife
		aa_modifier.is_one_time_effect = false
		_owner.auto_attack_modifier_registry.register_modifier(aa_modifier)
		
	# [HEALING CROSSBOW]
	if _attack_stats.healing_crossbow_activated:
		var aa_modifier := AutoAttackModifier.new()
		aa_modifier.id = "Healing Crossbow"
		aa_modifier.tags = [AutoAttackModifier.TagType.CARD]
		aa_modifier.on_attack_logic_callback = _on_auto_attack_healing_crossbow
		aa_modifier.is_one_time_effect = false
		_owner.auto_attack_modifier_registry.register_modifier(aa_modifier)
		
	# [STORM HAMMER]
	if _attack_stats.storm_hammer_activated:
		var aa_modifier := AutoAttackModifier.new()
		aa_modifier.id = "Storm Hammer"
		aa_modifier.tags = [AutoAttackModifier.TagType.CARD]
		aa_modifier.on_attack_logic_callback = _on_attack_storm_hammer
		aa_modifier.is_one_time_effect = false
		_owner.auto_attack_modifier_registry.register_modifier(aa_modifier)
		
	# [ARCANE STAFF]
	if _attack_stats.arcane_staff_activated:
		var aa_modifier := AutoAttackModifier.new()
		aa_modifier.id = "Arcane Staff"
		aa_modifier.tags = [AutoAttackModifier.TagType.CARD]
		aa_modifier.on_hit_logic_callback = _on_hit_arcane_staff
		aa_modifier.is_one_time_effect = false
		
	# [RUSSIAN ROULETTE]
	if _attack_stats.attack_russian_roulette_activated:
		var aa_modifier := AutoAttackModifier.new()
		aa_modifier.id = "Russian Roulette"
		aa_modifier.tags = [AutoAttackModifier.TagType.CARD]
		aa_modifier.on_attack_logic_callback = _on_russian_roulette_attack
		aa_modifier.is_one_time_effect = false
		_owner.auto_attack_modifier_registry.register_modifier(aa_modifier)
		
		
	# [NECROTIC BULLET]
	if _attack_stats.necrotic_bullet_activated:
		var aa_modifier := AutoAttackModifier.new()
		aa_modifier.id = "Necrotic Bullet"
		aa_modifier.tags = [AutoAttackModifier.TagType.CARD]
		aa_modifier.on_attack_logic_callback = _on_auto_attack_necrotic_bullet
		aa_modifier.is_one_time_effect = false
		_owner.auto_attack_modifier_registry.register_modifier(aa_modifier)
		
func _clear_attack_modifiers() -> void:
	# [PROTECTO'SPEAR]
	if _attack_stats.protectospear_activated:
		_owner.auto_attack_modifier_registry.unregister_modifier("Protecto'Spear")
		
	# [RUSTY DAGGER]
	if _attack_stats.rusty_dagger_activated:
		_owner.auto_attack_modifier_registry.unregister_modifier("Rusty Dagger")
		
	# [SCORCHING BLADE]
	if _attack_stats.scorching_blade_activated:
		_owner.auto_attack_modifier_registry.unregister_modifier("Scorching Blade")
		
	# [SURGICAL KNIFE]
	if _attack_stats.surgical_knife_activated:
		_owner.auto_attack_modifier_registry.unregister_modifier("Surgical Knife")
		
	# [HEALING CROSSBOW]
	if _attack_stats.healing_crossbow_activated:
		_owner.auto_attack_modifier_registry.unregister_modifier("Healing Crossbow")
		
	# [STORM HAMMER]
	if _attack_stats.storm_hammer_activated:
		_owner.auto_attack_modifier_registry.unregister_modifier("Storm Hammer")
		
	# [ARCANE STAFF]
	if _attack_stats.arcane_staff_activated:
		_owner.auto_attack_modifier_registry.unregister_modifier("Arcane Staff")

	# [RUSSIAN ROULETTE]
	if _attack_stats.attack_russian_roulette_activated:
		_owner.auto_attack_modifier_registry.unregister_modifier("Russian Roulette")

	# [NECROTIC BULLET]
	if _attack_stats.necrotic_bullet_activated:
		_owner.auto_attack_modifier_registry.unregister_modifier("Necrotic Bullet")
		
#endregion

#region stat modifier
func _add_stat_modifiers() -> void:
	# [FIGHT BACK]
	if _attack_stats.fight_back_activated:
		var mod := StatModifier.new()
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = _attack_stats.fight_back_increase_dodge
		mod.stat_type = EntityStats.StatType.DODGE
		mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
		mod.id = "Fight Back"
		_owner.stats_manager.register_modifier(mod)
	
	# [DIAMOND SWORD]
	if _attack_stats.diamond_sword_activated:
		var stat_modifier := StatModifier.new()
		stat_modifier.id = "Diamond Sword"
		stat_modifier.stat_type = EntityStats.StatType.AD
		stat_modifier.calc_type = StatModifier.CalcType.ADD
		stat_modifier.value = _attack_stats.diamond_sword_attack
		stat_modifier.tags = [StatModifier.TagType.CARD]
		_owner.stats_manager.register_modifier(stat_modifier)
	
	# [TWIN BLADE]
	if _attack_stats.twin_blade_activated:
		var stat_modifier := StatModifier.new()
		stat_modifier.id = "Twin Blade"
		stat_modifier.stat_type = EntityStats.StatType.AA_SPEED
		stat_modifier.calc_type = StatModifier.CalcType.MULT
		stat_modifier.value = _attack_stats.twin_blade_speed / 100.0
		stat_modifier.tags = [StatModifier.TagType.CARD]
		_owner.stats_manager.register_modifier(stat_modifier)
	
	# [AIM ASSIST]
	if _attack_stats.attack_aim_assist_activated:
		var stat_modifier := StatModifier.new()
		stat_modifier.id = "Aim Assist"
		stat_modifier.stat_type = EntityStats.StatType.AD
		stat_modifier.calc_type = StatModifier.CalcType.ADD
		
		# FamilyManager has _player reference which has the deck
		var count: int = 0
		if _player and _player.deck:
			count = _player.deck.get_unique_card_count(Family.FamilyType.ATTACK)
		else:
			push_warning("AttackManager: _player or deck is null for Aim Assist")
			
		stat_modifier.value = count * _attack_stats.attack_aim_assist_bonus_per_card
		stat_modifier.tags = [StatModifier.TagType.CARD]
		_owner.stats_manager.register_modifier(stat_modifier)
#endregion

#region action modifier
func _add_action_modifiers() -> void:
	# [FIGHT BACK]
	if _attack_stats.fight_back_activated:
		var action_modifier := ActionModifier.new()
		action_modifier.action_type = ActionModifier.ActionType.DODGE
		action_modifier.id = "Fight Back"
		action_modifier.is_one_time_effect = false
		action_modifier.after_action_logic_callback = _on_dodge_fight_back
		_owner.action_modifiers_manager.register_modifier(action_modifier)
#endregion


#region other card
# [BLADE RUSH]
func _apply_blade_rush() -> void:
	var stat_modifier := StatModifier.new()
	stat_modifier.id = "Blade Rush"
	stat_modifier.stat_type = EntityStats.StatType.AD
	stat_modifier.calc_type = StatModifier.CalcType.ADD
	stat_modifier.value = _attack_stats.blade_rush_damage
	stat_modifier.tags = [StatModifier.TagType.CARD]
	_owner.stats_manager.register_modifier(stat_modifier)
	
	var duration = _attack_stats.blade_rush_duration
	var timer := Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(_on_blade_rush_timeout)
	_optional_timers.append(timer)
	timer.start()
#endregion

# ============================== Callbacks functions ==============================

# [GATLING GUN]
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


# [FIGHT BACK]
func _on_dodge_fight_back(_cb_vars: Dictionary) -> void:
	if _owner == null or not is_instance_valid(_owner):
		printerr("Fight back callback: _owner est invalide.")
		return
	_dodge_number += 1
	var stat_modifier := StatModifier.new()
	stat_modifier.id = "Fight Back"
	stat_modifier.stat_type = EntityStats.StatType.AD
	stat_modifier.calc_type = StatModifier.CalcType.ADD
	stat_modifier.value = _dodge_number * _attack_stats.fight_back_increase_attack_damage
	stat_modifier.tags = [StatModifier.TagType.CARD]
	_owner.stats_manager.update_modifier(stat_modifier)


# [SCORCHING BLADE]
func _on_auto_attack_scorching_blade(cb_vars: Dictionary) -> void:
	if not cb_vars.has(ActionModifier.VarType.TARGET):
		printerr("Scorching Blade: cb_vars n'a pas de TARGET")
		return
	var target: Entity = cb_vars[ActionModifier.VarType.TARGET]
	if target == null or not is_instance_valid(target):
		return
	
	if not cb_vars.has(ActionModifier.VarType.PHYSICAL_DAMAGE):
		printerr("Scorching Blade: cb_vars n'a pas de DAMAGE")
		return
	var damage_dealt: int = cb_vars[ActionModifier.VarType.PHYSICAL_DAMAGE]
	var percent: float = _attack_stats.scorching_blade_damage_percent
	var ignite_stacks: float = (damage_dealt as float) * (percent / 100.0)
	
	if ignite_stacks > 0:
		_owner.inflict_condition_stacks(target, ignite_stacks, Utils.StackType.IGNITE, "Scorching Blade")


# [RUSTY DAGGER]
func _on_auto_attack_rusty_dagger(cb_vars: Dictionary) -> void:
	if not cb_vars.has(AutoAttackModifier.VarType.PROJECTILE_STATS):
		printerr("Rusty Dagger: cb_vars n'a pas de PROJECTILE_STATS")
		return
	var proj_stats: ProjectileStats = cb_vars[AutoAttackModifier.VarType.PROJECTILE_STATS]
	var chance: float = _attack_stats.rusty_dagger_chance
	if Utils.is_randomize_modifier_active(chance):
		proj_stats.poison_stacks += _attack_stats.rusty_dagger_poison_stacks

	if Utils.is_randomize_modifier_active(chance):
		proj_stats.poison_stacks += _attack_stats.rusty_dagger_poison_stacks


# [NECROTIC BULLET]
func _on_auto_attack_necrotic_bullet(cb_vars: Dictionary) -> void:
	if not cb_vars.has(AutoAttackModifier.VarType.PROJECTILE_STATS):
		printerr("Necrotic Bullet: cb_vars n'a pas de PROJECTILE_STATS")
		return
	var proj_stats: ProjectileStats = cb_vars[AutoAttackModifier.VarType.PROJECTILE_STATS]
	var chance: float = _attack_stats.necrotic_bullet_chance
	if Utils.is_randomize_modifier_active(chance):
		proj_stats.necrosis_stacks += _attack_stats.necrotic_bullet_necrosis_stacks

# [SCORCHING BLADE]
func _on_hit_scorching_blade(cb_vars: Dictionary) -> void:
	if not cb_vars.has(AutoAttackModifier.VarType.PHYSICAL_DAMAGE):
		printerr("Scorching Blade (on_hit): cb_vars n'a pas de PHYSICAL_DAMAGE")
		return
	var damage_dealt: int = cb_vars[AutoAttackModifier.VarType.PHYSICAL_DAMAGE]
	if not cb_vars.has(AutoAttackModifier.VarType.TARGET):
		printerr("Scorching Blade (on_hit): cb_vars n'a pas de TARGET")
		return
	var target: Entity = cb_vars[AutoAttackModifier.VarType.TARGET]
	if target == null or not is_instance_valid(target):
		return
	var percent: float = _attack_stats.scorching_blade_damage_percent
	var ignite_stacks: float = (damage_dealt as float) * (percent / 100.0)
	if ignite_stacks > 0:
		_owner.inflict_condition_stacks(target, ignite_stacks, Utils.StackType.IGNITE, "Scorching Blade")


# [SURGICAL KNIFE]
func _on_auto_attack_surgical_knife(_cb_vars: Dictionary) -> void:
	var chance: float = _attack_stats.surgical_knife_chance
	if not Utils.is_randomize_modifier_active(chance):
		return
	var amount_to_cleanse: float = _attack_stats.surgical_knife_cleanse_amount
	_owner.cleanse(_owner, amount_to_cleanse, "Surgical Knife")


func _on_auto_attack_healing_crossbow(_cb_vars: Dictionary) -> void:
	# [HEALING CROSSBOW]
	var chance: float = _attack_stats.healing_crossbow_chance
	if not Utils.is_randomize_modifier_active(chance):
		return
	var heal_amount: float = _attack_stats.healing_crossbow_heal_amount
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
	if target == null:
		return
	_owner.heal(target, heal_amount, "Healing Crossbow")


# [BLADE RUSH]
func _on_blade_rush_timeout() -> void:
	var mod := StatModifier.new()
	mod.id = "Blade Rush"
	mod.stat_type = EntityStats.StatType.AD
	_owner.stats_manager.unregister_modifier(mod)


func _on_attack_storm_hammer(cb_vars: Dictionary) -> void:
	# [STORM HAMMER]
	var chance: float = _attack_stats.storm_hammer_chance
	if not Utils.is_randomize_modifier_active(chance):
		return

	if not cb_vars.has(AutoAttackModifier.VarType.PROJECTILE_STATS):
		printerr("Storm Hammer (on_hit): cb_vars n'a pas de TARGET")
		return
		
	var projectile_stat: ProjectileStats = cb_vars[AutoAttackModifier.VarType.PROJECTILE_STATS]
	projectile_stat.is_bouncing = true


func _on_hit_arcane_staff(_cb_vars: Dictionary) -> void:
	# [ARCANE STAFF]
	var chance: float = _attack_stats.arcane_staff_chance
	if not Utils.is_randomize_modifier_active(chance):
		return

	var mana_gain: float = _attack_stats.arcane_staff_mana_gain
	if mana_gain > 0:
		_owner.stats.mana += mana_gain


# [PROTECTO'SPEAR]
func _on_auto_attack_protectospear(_cb_vars: Dictionary) -> void:
	var chance: float = _attack_stats.protectospear_chance
	if Utils.is_randomize_modifier_active(chance):
		_owner.inflict_condition_stacks(_owner, _attack_stats.protectospear_shield_amount, Utils.StackType.ARMOR, "Protecto'Spear")


# [RUSSIAN ROULETTE]
func _on_russian_roulette_attack(cb_vars: Dictionary) -> void:
	if not cb_vars.has(AutoAttackModifier.VarType.PROJECTILE_STATS):
		printerr("Russian Roulette: cb_vars n'a pas de PROJECTILE_STATS")
		return
	var proj_stats: ProjectileStats = cb_vars[AutoAttackModifier.VarType.PROJECTILE_STATS]
	
	var min_p: float = _attack_stats.attack_russian_roulette_min_percent
	var max_p: float = _attack_stats.attack_russian_roulette_max_percent
	
	var multiplier: float = randf_range(min_p, max_p) / 100.0
	
	proj_stats.physical_damage_flat *= multiplier
