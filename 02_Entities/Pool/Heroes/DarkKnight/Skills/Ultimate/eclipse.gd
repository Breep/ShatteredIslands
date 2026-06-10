class_name SE_Eclipse
extends SkillEffect

# Ultimate Eclipse: triggers the Shadow Blade passive in a burst (5 by default,
# +META_ULT_EXTRA via the Eclipse Storm talent). Forced triggers: no chance roll,
# each burst goes through SE_ShadowBlade.perform_trigger and thus benefits from the
# talents (shield, weakness, vuln). The triggers are spread over time (_salvo_delay
# between each) so the projectiles read as a salvo instead of overlapping on one tick.
# Each shot re-targets the closest enemy at fire time, so a target dying mid-salvo
# doesn't waste the remaining triggers.

@export var _base_triggers: int = 5
## Delay (seconds) between each trigger of the ultimate salvo.
@export var _salvo_delay: float = 0.15


func apply(ctx: SkillContext) -> void:
	var dk: Entity = ctx.entity
	if dk == null:
		Verbose.error("SE_Eclipse: null owner", Verbose.Category.ENTITY_MODULE)
		return

	var triggers: int = _base_triggers + int(dk.get_meta(SE_ShadowBlade.META_ULT_EXTRA, 0))
	for i: int in triggers:
		dk.battle_callback_registry.register_oneshot(i * _salvo_delay, func() -> void:
			var target: Entity = dk.target.get_target(TargetComponent.TargettingStrategy.CLOSEST_ENEMY)
			if not is_instance_valid(target):
				return
			SE_ShadowBlade.perform_trigger(dk, target))
