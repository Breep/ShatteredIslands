class_name CardContext
extends RefCounted

## Context object passed to CardEffect.apply_card() — gives cards access to
## all registries they need without coupling directly to Hero internals.

var hero: Entity
var stat_modifiers: EntityStatModifiersRegistry
var action_modifiers: ActionModifiersRegistry
var auto_attack_modifiers: AutoAttackModifierRegistry
var battle_callbacks: BattleCallbackRegistry

## Id de design de la carte en cours d'apply/revert. Positionné par le DeckHolder
## avant chaque appel ; utilisé par les cartes pour retirer leurs ajouts keyés
## dans les FamilyStats au revert.
var card_id: StringName


static func create(
		p_hero: Entity,
		p_stat_modifiers: EntityStatModifiersRegistry,
		p_action_modifiers: ActionModifiersRegistry,
		p_auto_attack_modifiers: AutoAttackModifierRegistry,
		p_battle_callbacks: BattleCallbackRegistry,
) -> CardContext:
	var ctx := CardContext.new()
	ctx.hero = p_hero
	ctx.stat_modifiers = p_stat_modifiers
	ctx.action_modifiers = p_action_modifiers
	ctx.auto_attack_modifiers = p_auto_attack_modifiers
	ctx.battle_callbacks = p_battle_callbacks
	return ctx
