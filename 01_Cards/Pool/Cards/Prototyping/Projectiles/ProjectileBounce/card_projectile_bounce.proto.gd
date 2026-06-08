# Carte de prototypage : ajoute (+1.5 × card_lvl) rebonds aux auto-attaques du
# héros. Valide la chaîne ProjectileModifier.bounce_modifier_callback →
# BounceResolver consommée par ProjectileComponent.projectile_attack() en phase
# pré-spawn. Le bonus flottant exerce les deux parties de bounces_remaining :
# rebonds garantis (partie entière) + proba d'un rebond en plus (décimale).
# Filtre sur category = AUTO_ATTACK_PROJECTILE (effet le plus visible : l'AA
# enchaîne sur les ennemis suivants).
class_name CardPrototypingProjectileBounce
extends CardEffect

const BOUNCE_PER_LEVEL: float = 1.5


func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var bonus: float = BOUNCE_PER_LEVEL * card_lvl
	var mod := ProjectileModifier.new()
	mod.id = card_name
	mod.categories = [Projectile.Category.AUTO_ATTACK_PROJECTILE]
	mod.bounce_modifier_callback = func(cb_vars: Dictionary) -> void:
		cb_vars[BounceResolver.BOUNCE] += bonus
	owner.projectile_modifiers_registry.register_modifier(mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	# ProjectileModifiersRegistry.unregister_modifier prend un modifier mais
	# n'utilise que son .id en interne. Stub avec le bon id.
	var stub := ProjectileModifier.new()
	stub.id = card_name
	ctx.entity_owner.projectile_modifiers_registry.unregister_modifier(stub)


func get_description(card_lvl: int) -> String:
	return "Les auto-attaques gagnent +%.1f rebond(s)." % (BOUNCE_PER_LEVEL * card_lvl)
