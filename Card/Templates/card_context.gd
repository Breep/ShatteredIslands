class_name CardContext
extends RefCounted

## Context object passed to HeroUpgrade.apply_card() — gives cards access to
## all registries they need without coupling directly to Hero internals.

var hero: Hero
var stat_modifiers: EntityStatModifiersRegistry
var action_modifiers: ActionModifiersRegistry
var auto_attack_modifiers: AutoAttackModifierRegistry
var periodic_timers: PeriodicTimerRegistry
var battle_callbacks: BattleCallbackRegistry


static func create(
		p_hero: Hero,
		p_stat_modifiers: EntityStatModifiersRegistry,
		p_action_modifiers: ActionModifiersRegistry,
		p_auto_attack_modifiers: AutoAttackModifierRegistry,
		p_periodic_timers: PeriodicTimerRegistry,
		p_battle_callbacks: BattleCallbackRegistry,
) -> CardContext:
	var ctx := CardContext.new()
	ctx.hero = p_hero
	ctx.stat_modifiers = p_stat_modifiers
	ctx.action_modifiers = p_action_modifiers
	ctx.auto_attack_modifiers = p_auto_attack_modifiers
	ctx.periodic_timers = p_periodic_timers
	ctx.battle_callbacks = p_battle_callbacks
	return ctx
