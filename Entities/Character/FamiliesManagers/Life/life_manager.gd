class_name LifeManager
extends FamilyManager

# ============================== Signals ==============================

signal revived(life_after_revive: int)

# ============================== Private variables ==============================

var _life_stats: FamilyLifeStats # Ref to the owner life stats

# [ANCIENT GROWTH] Accumulateur
var _ancient_growth_total_bonus: float = 0.0

var _revive_timer: Timer

# ============================== Spells scenes ==============================

# ============================== Public functions ==============================

func _ready() -> void:
	_life_stats = _owner.families_stats.life


func start() -> void:
	_create_optional_timers()
	for timer in _optional_timers:
		timer.start()
	_add_stat_modifiers()
	_add_action_modifiers()
	# [ANCIENT GROWTH] Reset du compteur au début du combat
	_ancient_growth_total_bonus = 0.0


func stop() -> void:
	_clear_optional_timers()


func get_increased_damage_taken_from_lost_hp(damage: float, _damage_type: Utils.DamageType) -> float:
	return damage

# [Revive]
func source_is_dead() -> void:
	if not _life_stats.revive_after_death_activated or _life_stats.revive_after_death_triggered:
		return
	
	_life_stats.revive_after_death_triggered = true
	_revive_timer.start()

# ============================== Private functions ==============================
#region optional timer
func _create_optional_timers() -> void:
	# [TAINTED BLOOD]
	if _life_stats.tainted_blood_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _life_stats.tainted_blood_period, _on_tainted_blood_timer_timeout, true))
	
	# [VITAL PULSE]
	if _life_stats.vital_pulse_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _life_stats.vital_pulse_period, _vital_pulse_timer_timeout, true))
	
	# [TITAN'S PROTECTION]
	if _life_stats.titans_protection_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _life_stats.titans_protection_period, _on_titans_protection_timer_timeout, true))
	
	# [ANCIENT GROWTH]
	if _life_stats.ancient_growth_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _life_stats.ancient_growth_period, _on_ancient_growth_timer_timeout, true))


func _clear_optional_timers() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()
#endregion

#region aa modifier
#endregion

#region stats modifier

func _add_stat_modifiers() -> void:
	
	# [EVASIVE GROWTH]
	if _life_stats.evasive_growth_activated:
		var mod := StatModifier.new()
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = _life_stats.evasive_growth_increase_dodge
		mod.stat_type = EntityStats.StatType.DODGE
		mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
		mod.id = "Evasive Growth"
		_owner.stats_manager.register_modifier(mod)
		
	# [PROTEINS]
	if _life_stats.proteins_activated:
		var mod := StatModifier.new()
		mod.id = "Proteins"
		mod.stat_type = EntityStats.StatType.HEALTH_MAX
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = _life_stats.proteins_max_hp_increase
		mod.tags = [StatModifier.TagType.CARD]

		_owner.stats_manager.register_modifier(mod)
		_owner.stats.health += _life_stats.proteins_max_hp_increase
		
	# [BEAR STRENGTH]
	if _life_stats.bear_strength_activated:
		var as_mod := StatModifier.new()
		as_mod.id = "Bear Strength AS"
		as_mod.stat_type = EntityStats.StatType.AA_SPEED
		as_mod.calc_type = StatModifier.CalcType.MULT
		as_mod.value = -(_life_stats.bear_strength_as_reduction / 100.0)
		as_mod.tags = [StatModifier.TagType.CARD]
		_owner.stats_manager.register_modifier(as_mod)
		
		var ad_mod := StatModifier.new()
		ad_mod.id = "Bear Strength AD"
		ad_mod.stat_type = EntityStats.StatType.AD
		ad_mod.calc_type = StatModifier.CalcType.ADD
		
		var max_hp: float = float(_owner.stats.health_max)
		var percent: float = _life_stats.bear_strength_hp_to_ad_percent
		ad_mod.value = max_hp * (percent / 100.0)
		
		ad_mod.tags = [StatModifier.TagType.CARD]
		_owner.stats_manager.register_modifier(ad_mod)
		
	# [CRYSTAL MOUNTAIN]
	if _life_stats.crystal_mountain_activated:
		var defense_val: float = _life_stats.crystal_mountain_defense_increase
		
		# 1. Résistance PHYSIQUE
		var phys_mod := StatModifier.new()
		phys_mod.id = "Crystal Mountain (Phys)"
		phys_mod.stat_type = EntityStats.StatType.RESISTANCE
		phys_mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
		phys_mod.calc_type = StatModifier.CalcType.ADD
		phys_mod.value = defense_val
		phys_mod.tags = [StatModifier.TagType.CARD]
		_owner.stats_manager.register_modifier(phys_mod)
		
		# 2. Résistance MAGIQUE
		var magic_mod := StatModifier.new()
		magic_mod.id = "Crystal Mountain (Magic)"
		magic_mod.stat_type = EntityStats.StatType.RESISTANCE
		# Vérifie que c'est bien le bon ActionType pour la magie
		magic_mod.action_type = Utils.ActionType.DAMAGE_MAGICAL 
		magic_mod.calc_type = StatModifier.CalcType.ADD
		magic_mod.value = defense_val
		magic_mod.tags = [StatModifier.TagType.CARD]
		_owner.stats_manager.register_modifier(magic_mod)
		
		# 3. Résistance POISON
		var poison_mod := StatModifier.new()
		poison_mod.id = "Crystal Mountain (Poison)"
		poison_mod.stat_type = EntityStats.StatType.RESISTANCE
		poison_mod.action_type = Utils.ActionType.DAMAGE_POISON
		poison_mod.calc_type = StatModifier.CalcType.ADD
		poison_mod.value = defense_val
		poison_mod.tags = [StatModifier.TagType.CARD]
		_owner.stats_manager.register_modifier(poison_mod)
		
	# [ANCIENT COLLECTOR]
	if _life_stats.ancient_collector_activated:
		var mod := StatModifier.new()
		mod.id = "The Ancient Collector"
		mod.stat_type = EntityStats.StatType.HEALTH_MAX
		mod.calc_type = StatModifier.CalcType.ADD
		
		# Get unique colossus card count
		# FamilyManager has _player reference which has the deck
		if _player and _player.deck:
			var colossus_count: int = _player.deck.get_unique_card_count(Family.FamilyType.LIFE)
			mod.value = colossus_count * _life_stats.ancient_collector_amount_per_card
		else:
			push_warning("LifeManager: _player or deck is null for Ancient Collector")
		
		mod.tags = [StatModifier.TagType.CARD]
		_owner.stats_manager.register_modifier(mod)
		
#endregion

#region action modifier


func _add_action_modifiers() -> void:
	# [EVASIVE GROWTH]
	if _life_stats.evasive_growth_activated:
		var action_modifier := ActionModifier.new()
		action_modifier.action_type = ActionModifier.ActionType.DODGE
		action_modifier.id = "Evasive Growth"
		action_modifier.is_one_time_effect = false
		action_modifier.after_action_logic_callback = _on_dodge_evasive_growth
		_owner.action_modifiers_manager.register_modifier(action_modifier)

#endregion
		
#region other card

#endregion
# ============================== Callbacks functions ==============================

func _on_revive_timer_timeout() -> void:
	var life_after_revive: int = ((_life_stats.revive_after_death_percentage_life * _owner.stats.health_max) / 100.0) as int
	revived.emit(life_after_revive)

func _on_dodge_evasive_growth(_cb_vars: Dictionary) -> void:
	# [EVASIVE GROWTH]
	if _owner == null or not is_instance_valid(_owner):
		printerr("Evasive Growth callback: _owner est invalide.")
		return
	_owner.stats.health_max += _life_stats.evasive_growth_increase_max_hp

func _vital_pulse_timer_timeout() -> void:
	# [VITAL PULSE]
	var targets: Array[Entity] = _owner.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ENEMIES)
	if targets.is_empty():
		return
	var max_hp: float = _owner.stats.health_max
	var percent: float = _life_stats.vital_pulse_damage_percent
	var damage: float = max_hp * (percent / 100.0)
	if damage <= 0:
		return
	for target in targets:
		if target != null and is_instance_valid(target):
			_owner.direct_attack(target, damage, Utils.DamageType.PHYSICAL, "Vital Pulse")


# [TAINTED BLOOD]
func _on_tainted_blood_timer_timeout() -> void:
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if target == null or not is_instance_valid(target):
		return
	
	var max_hp: float = _owner.stats.health_max
	var current_hp: float = _owner.stats.health
	var lost_hp: float = max_hp - current_hp
	if lost_hp <= 0: return 
	
	var percent: float = _life_stats.tainted_blood_lost_hp_percent
	var stacks: float = lost_hp * (percent / 100.0)
	if stacks <= 0: return
	var stack_type: Utils.StackType
	if Utils.rng.randi() % 2 == 0:
		stack_type = Utils.StackType.POISON
	else:
		stack_type = Utils.StackType.IGNITE
		stacks *= 5 # TODO Magic number spotted !
	
	_owner.inflict_condition_stacks(target, stacks, stack_type, "Tainted Blood")


# [TITAN'S PROTECTION]
func _on_titans_protection_timer_timeout() -> void:
	var max_hp: float = _owner.stats.health_max
	var current_hp: float = _owner.stats.health
	var lost_hp: float = max_hp - current_hp
	if lost_hp <= 0: return
	var percent: float = _life_stats.titans_protection_lost_hp_percent
	var heal_amount: float = lost_hp * (percent / 100.0)
	if heal_amount > 0:
		_owner.heal(_owner, heal_amount, "Titan Protection")

func _on_ancient_growth_timer_timeout() -> void:
	# [ANCIENT GROWTH]
	_ancient_growth_total_bonus += _life_stats.ancient_growth_amount

	var mod := StatModifier.new()
	mod.id = "Ancient Growth"
	mod.stat_type = EntityStats.StatType.HEALTH_MAX
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = _ancient_growth_total_bonus
	mod.tags = [StatModifier.TagType.CARD]
	_owner.stats_manager.update_modifier(mod)

