# Carte de prototypage : tire un projectile d'abilité aléatoire parmi le pool
# du porteur toutes les _period secondes. Valide la chaîne
# ProjectileComponent.fire_random() — pick aléatoire dans
# _ability_projectiles_pool, délégation à projectile_attack().
#
# Cette carte n'ajoute RIEN au pool (volontairement) — elle ne fait que
# consommer ce que d'autres cartes y ont enregistré via
# register_projectile() (cf. règle §7 du CLAUDE.md des cartes). Si le pool
# est vide, fire_random() est un no-op.
class_name CardPrototypingFireRandomProjectile
extends CardEffect

@export var _period: float = 3.0


func apply(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	owner.battle_callback_registry.register_periodic(card_name, _period, func() -> void:
		var target: Entity = owner.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ENEMY)
		if target == null or not is_instance_valid(target):
			return
		owner.projectile.fire_random(target, owner)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(_card_lvl: int) -> String:
	return "Toutes les %.1fs, lance un projectile d'abilité aléatoire parmi le pool du porteur." % _period
