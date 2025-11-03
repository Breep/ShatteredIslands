class_name SerenityManager
extends FamilyManager

# ============================== Constant ==============================

const PACIFY_DAMAGE_REDUCTION_PERCENT: float = 50 # Percentage of damage reduction when pacified

# ============================== Private variables ==============================

var _serenity_stats: FamilySerenityStats # Ref to the owner heal stats

@onready var _regen_tick_timer: Timer = %RegenTickTimer

# ============================== Spells scenes ==============================

# ============================== Public functions ==============================

func _ready() -> void:
	_serenity_stats = _owner.families_stats.serenity


func start() -> void:
	for timer in _optional_timers:
		timer.start()
	_regen_tick_timer.start()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()
	_regen_tick_timer.stop()


func notify_heal() -> void:
	# [Magic heal]
	if _serenity_stats.heal_projectile_activated and Utils.is_randomize_modifier_active(_serenity_stats.heal_projectile_chance):
		var target: Character = _owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
		if target == null:
			return
		_owner.attack(target, _serenity_stats.heal_projectile_damage, Utils.DamageType.MAGICAL)
	
	
	# [Panda-cify]
	if _serenity_stats.pacify_enemy_activated and Utils.is_randomize_modifier_active(_serenity_stats.pacify_enemy_chance):
		var target: Character = _owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
		if target == null:
			return
		target.stats.heal.pacified = true
		if multiplayer.get_unique_id() == 1:
			print("PACIFY MY ENEMY")


func get_reduced_damage_dealed_from_pacify(damage: float) -> float:
	if not _serenity_stats.pacified:
		return damage
	
	_serenity_stats.pacified = false
	var damage_reduction = damage * PACIFY_DAMAGE_REDUCTION_PERCENT / 100.0
	return damage - damage_reduction

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# [Flash heal]
	if _serenity_stats.periodic_heal_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _serenity_stats.periodic_heal_period, _on_periodic_heal_timer_timeout))
	
	# [Survivor]
	if _serenity_stats.lost_hp_regen_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _serenity_stats.lost_hp_regen_period, _on_lost_hp_regen_timer_timeout))

	# [Pacific wave]
	if _serenity_stats.epic_heal_area_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _serenity_stats.epic_heal_area_period, _on_epic_heal_area_timer_timeout))

# ============================== Callbacks functions ==============================

func _on_periodic_heal_timer_timeout() -> void:
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
	_action_module.heal(target, _serenity_stats.periodic_heal_amount)


func _on_lost_hp_regen_timer_timeout() -> void:
	_action_module.heal_percent(_owner, _serenity_stats.lost_hp_regen_percentage, Utils.PercentModifier.LOST_HP)


func _on_epic_heal_area_timer_timeout() -> void:
	var targets = _owner.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
	if targets.is_empty():
		return
	for target in targets:
		_action_module.heal_percent(target, _serenity_stats.epic_heal_area_percentage, Utils.PercentModifier.MAX_HP)


func _on_regen_tick_timer_timeout() -> void:
	var heal_amount: int = _owner.stats.regen_stacks
	_owner.heal(_owner, heal_amount)
