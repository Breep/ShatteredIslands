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
	_create_optional_timers()
	

func stop() -> void:
	for timer in _optional_timers:
		timer.stop()
	_clear_optional_timers()
	_regen_tick_timer.stop()
	
	
# ============================== Private functions ==============================
func _clear_optional_timers() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()
	
func _create_optional_timers() -> void:
	# [holy touch]
	if _serenity_stats.holy_touch_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self,_serenity_stats.holy_touch_period,_holy_touch_timer_timeout,true))
		

# ============================== Callbacks functions ==============================

func _holy_touch_timer_timeout() -> void: 
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
	if target == null: return
	_owner.heal(target, _serenity_stats.holy_touch_amount)

func _on_regen_tick_timer_timeout() -> void:
	var heal_amount: int = _owner.stats.regen_stacks
	if heal_amount > 0:
		_owner.heal(_owner, heal_amount)
