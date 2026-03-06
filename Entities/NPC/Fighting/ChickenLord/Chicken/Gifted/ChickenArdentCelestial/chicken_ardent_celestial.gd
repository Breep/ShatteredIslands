class_name ChickenArdentCelestial
extends ChickenGifted

var _bonus_ms_ratio: float
var _ignite_stacks: int
var _explosion_aoe: float
var _hp_threshold_ratio: float

func init(ignite_stacks: int) -> Summon:
	_bonus_ms_ratio = 0.25
	_explosion_aoe = 250
	_hp_threshold_ratio = 0.5
	_ignite_stacks = ignite_stacks
	return self
	
func _ready() -> void:
	
	stats.heatlh_changed.connect(_on_health_changed)
	
	super._ready()

func _on_health_changed(current_health: float) -> void:
	if current_health < _hp_threshold_ratio * stats.health_max:
		pass
	# CHICKEN BOOM BOOM
