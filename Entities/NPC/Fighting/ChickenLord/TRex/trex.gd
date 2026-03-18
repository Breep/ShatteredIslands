class_name TRex
extends Summon

enum Modifier {
	GIFTED_SPAWN_PERIOD,
	GIFTED_SPAWN_NUMBER,
	HP_BONUS
}

var _gifted_spawn_period: float
var _gifted_spawn_number: int
var _hp_bonus: float

func init(gifted_spawn_period: float, gifted_spawn_number: int, hp_bonus: float) -> TRex:
	_gifted_spawn_period = gifted_spawn_period
	_gifted_spawn_number = gifted_spawn_number
	_hp_bonus = hp_bonus
	return self


func _ready() -> void:
	var mod := StatModifier.new()
	mod.value = _hp_bonus
	mod.stat_type = EntityStats.StatType.HEALTH_MAX
	mod.calc_type = StatModifier.CalcType.ADD
	mod.id = "Ancestral Gauge"
	stat_modifiers_registry.register_modifier(mod)
	
	if _gifted_spawn_period > 0:
		periodic_timer_registry.register("Gifted Spawn", _gifted_spawn_period, func() -> void:
			var tween = create_tween()
			tween.tween_property(_visual_3d, "rotation:y", _visual_3d.rotation.y + TAU, 0.8) \
				.set_trans(Tween.TRANS_QUART) \
				.set_ease(Tween.EASE_OUT)
			for i in _gifted_spawn_number:
				summoner.summon_entity(EntityType.CHICKEN, SpawnLocationConfig.create_entity_relative(self, 5.0), {})
			)
	super._ready()


func _on_died() -> void:
	super._on_died()
	periodic_timer_registry.unregister("Gifted Spawn")














 
