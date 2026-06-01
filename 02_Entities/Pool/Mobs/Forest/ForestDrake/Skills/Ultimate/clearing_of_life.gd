class_name SE_ClearingOfLife
extends SkillEffect

@export var _period: float = 1.0
@export var _ap_ratio: float = 50.0
@export var _ad_ratio: float = 50.0
@export var _cleanse_value: float = 15.0
@export var _radius: float = 5.0
@export var _duration: float = 4.0


func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity
	_owner.spell.cast_spell(_owner, Spell.Type.CLEARING_OF_LIFE, {
		ClearingOfLife.Modifier.PERIOD: _period,
		ClearingOfLife.Modifier.AP_RATIO: _ap_ratio,
		ClearingOfLife.Modifier.AD_RATIO: _ad_ratio,
		ClearingOfLife.Modifier.CLEANSE_VALUE: _cleanse_value,
		ClearingOfLife.Modifier.RADIUS: _radius,
		ClearingOfLife.Modifier.DURATION: _duration
	})
