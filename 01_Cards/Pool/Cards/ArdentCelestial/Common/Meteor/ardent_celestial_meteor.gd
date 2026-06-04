class_name ArdentCelestialMeteor
extends CardEffect

## Ardent Celestial — invoque périodiquement un météore sur un ennemi aléatoire :
## dégâts magiques en % des PV max de la cible, et applique des stacks d'ignite
## aux ennemis touchés.

@export var _damage_percent: Array[float]
@export var _ignite_stacks: Array[float]
@export var _period: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var damage_percent: float = _damage_percent[card_lvl - 1]
	var ignite: float = _ignite_stacks[card_lvl - 1]
	var period: float = _period[card_lvl - 1]

	var on_hit := func(cb_vars: Dictionary) -> void:
		var entities: Array = cb_vars.get(Meteor.VarType.ENTITIES_INSIDE, [])
		for e in entities:
			if e == null or not is_instance_valid(e): continue
			if e.team == owner.team: continue
			owner.alterations.inflict_condition_stacks(e, ignite, Alteration.Type.IGNITE, card_name)

	owner.battle_callback_registry.register_periodic(card_name, period, func() -> void:
		var target: Entity = owner.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ENEMY)
		if target == null or not is_instance_valid(target):
			return
		owner.spell.cast_spell(target, Spell.Type.METEOR, {
			Meteor.Modifier.DAMAGE_PERCENT: damage_percent,
			Meteor.Modifier.ON_HIT_CALLBACKS: [on_hit],
		})
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "Toutes les " + str(_period[card_lvl - 1]) + "s, invoque un météore infligeant " \
		+ str(_damage_percent[card_lvl - 1]) + "% des PV max en [[MAGICAL_DAMAGE]] et " \
		+ str(_ignite_stacks[card_lvl - 1]) + " [[IGNITE]] aux ennemis touchés."
