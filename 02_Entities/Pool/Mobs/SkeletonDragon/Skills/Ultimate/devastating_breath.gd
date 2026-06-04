class_name SE_DevastatingBreath
extends SkillEffect

# Ultimate "Souffle dévastateur": while the breath sweeps the arena (driven by the
# roar animation), every enemy that enters the breath gets a fixed Ignite DoT
# (_tick_count applications of _ignite_stacks_per_tick), once per cast — independent
# of how long it stays in the breath. All gameplay lives here; BreathVfxController
# only provides the VFX and the detection signals.

@export var _ignite_stacks_per_tick: float = 10.0
@export var _tick_count: int = 3
@export var _tick_interval: float = 0.5

func apply(ctx: SkillContext) -> void:
	var dragon: SkeletonDragon = ctx.entity as SkeletonDragon
	if dragon == null:
		Verbose.error("SE_DevastatingBreath: owner is not a SkeletonDragon", Verbose.Category.ENTITY_MODULE)
		return
	var breath: BreathVfxController = dragon.get_breath_controller()
	if breath == null:
		Verbose.error("SE_DevastatingBreath: dragon has no breath controller", Verbose.Category.ENTITY_MODULE)
		return

	# Per-cast wiring: connect for this breath, dedup locally so each enemy is hit
	# once, and disconnect when the breath ends so connections never pile up.
	var hit_this_cast: Dictionary = {}
	var on_entered: Callable = func(body: Node3D) -> void:
		var enemy: Entity = body as Entity
		if enemy == null or enemy.team == dragon.team or hit_this_cast.has(enemy):
			return
		hit_this_cast[enemy] = true
		_apply_breath_ignite(dragon, enemy)

	breath.breath_body_entered.connect(on_entered)
	breath.breath_ended.connect(func() -> void:
		if breath.breath_body_entered.is_connected(on_entered):
			breath.breath_body_entered.disconnect(on_entered)
	, CONNECT_ONE_SHOT)


# Entry-triggered Ignite DoT: _tick_count applications of _ignite_stacks_per_tick,
# spaced by _tick_interval on the deterministic clock.
func _apply_breath_ignite(dragon: SkeletonDragon, enemy: Entity) -> void:
	for i in _tick_count:
		dragon.battle_callback_registry.register_oneshot(_tick_interval * i, func() -> void:
			if is_instance_valid(enemy):
				dragon.alterations.inflict_condition_stacks(enemy, _ignite_stacks_per_tick, Alteration.Type.IGNITE, &"DevastatingBreath")
		)
