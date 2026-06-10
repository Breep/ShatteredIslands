class_name SE_Shockwave
extends SkillEffect

# Bronze talent: each time the dragon lands (Vol fracassant passive), it sheds half of
# its damaging debuff stacks (poison / burn / necrosis) and grants itself a strong regen.

# Damaging condition stacks that count as debuffs (mirrors AlterationsComponent.get_debuff_stacks).
const _DAMAGE_DEBUFFS: Array[Alteration.Type] = [
	Alteration.Type.POISON,
	Alteration.Type.IGNITE,
	Alteration.Type.NECROSIS,
]

@export_range(0.0, 1.0, 0.05) var _debuff_removal_ratio: float = 0.5
@export var _regen_stacks: float = 100.0
## Seconds each regen batch lasts (clamped to the regen ring buffer by the alteration).
@export var _regen_duration: int = 10

func apply(ctx: SkillContext) -> void:
	var dragon: SkeletonDragon = ctx.entity as SkeletonDragon
	if dragon == null:
		Verbose.error("SE_Shockwave: owner is not a SkeletonDragon", Verbose.Category.ENTITY_MODULE)
		return
	var ability: ShatteringFlightAbility = dragon.get_flight_ability()
	if ability == null:
		Verbose.error("SE_Shockwave: dragon has no flight ability", Verbose.Category.ENTITY_MODULE)
		return

	ability.flight_landing_impact.connect(func() -> void:
		_shed_debuffs(dragon)
		dragon.alterations.add_stack(
			Alteration.Type.REGEN, _regen_stacks, dragon, &"Shockwave",
			{Alteration.ModifierType.DURATION: _regen_duration}
		)
	)


func _shed_debuffs(dragon: SkeletonDragon) -> void:
	for debuff: Alteration.Type in _DAMAGE_DEBUFFS:
		var stacks: float = dragon.alterations.get_stacks(debuff)
		if stacks > 0.0:
			dragon.alterations.remove_stack(debuff, stacks * _debuff_removal_ratio)
