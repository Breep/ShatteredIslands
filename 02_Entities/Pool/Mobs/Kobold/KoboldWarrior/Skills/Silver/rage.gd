class_name SE_Rage
extends SkillEffect

@export var _force_flat: float = 25
@export var _hp_threshold_percent: float = 50.0

var _rage_triggered: bool = false

func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity
	_owner.stats.health_changed.connect(_on_stats_health_changed.bind(_owner))


func get_description() -> String:
	return "Lorsqu'il passe sous " + _value(_hp_threshold_percent) + "% de ses PV, " \
		+ "entre en rage et gagne " + _value(_force_flat) + " [[STRENGTH]] (une seule fois)."


func _on_stats_health_changed(_new_health: float, entity_owner: Entity) -> void:
	if _rage_triggered: return
	if entity_owner.stats.health < entity_owner.stats.health_max * _hp_threshold_percent / 100.0:
		entity_owner._visual_3d.scale = Vector3(2, 2, 2) # TODO à changer
		entity_owner.alterations.direct_stack(entity_owner, _force_flat, Alteration.Type.STRENGTH, &"Rage")
		_rage_triggered = true
		entity_owner.stats.health_changed.disconnect(_on_stats_health_changed)
