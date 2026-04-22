class_name TRex
extends Summon

enum Modifier {
	PRIMAL_SHAKE_PERIOD,
	PRIMAL_SHAKE_NUMBER,
	HP_BONUS
}

signal primal_shaked

var _primal_shake_period: float
var _primal_shake_number: int
var _hp_bonus: float

func init(primal_shake_period: float, primal_shake_number: int, hp_bonus: float) -> TRex:
	_primal_shake_period = primal_shake_period
	_primal_shake_number = primal_shake_number
	_hp_bonus = hp_bonus
	return self


func _ready() -> void:
	var mod := StatModifier.new()
	mod.value = _hp_bonus
	mod.stat_type = EntityStats.StatType.HEALTH_MAX
	mod.calc_type = StatModifier.CalcType.ADD
	mod.id = "Ancestral Gauge"
	stat_modifiers_registry.register_modifier(mod)

	if alterations_module != null:
		alterations_module.add_stack(Alteration.Type.DEFENSE, 15.0)

	if _primal_shake_period > 0:
		periodic_timer_registry.register("Primal Shake", _primal_shake_period, func() -> void:
			primal_shaked.emit()
			for i in _primal_shake_number:
				summoner.summon_entity(EntityType.CHICKEN, SpawnLocationConfig.create_entity_relative(self, 5.0), {})
			)
	super._ready()


func _on_died() -> void:
	super._on_died()
	periodic_timer_registry.unregister("Primal Shake")














 
