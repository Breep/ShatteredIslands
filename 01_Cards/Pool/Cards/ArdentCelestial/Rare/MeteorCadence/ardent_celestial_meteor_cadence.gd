class_name ArdentCelestialMeteorCadence
extends CardEffect

## Ardent Celestial — tous les N projectiles d'abilité lancés, invoque un météore
## sur un ennemi aléatoire. Compteur remis à zéro à chaque combat.

@export var _projectiles_per_meteor: Array[int]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var threshold: int = _projectiles_per_meteor[card_lvl - 1]
	var state := {&"count": 0}

	var mod := ProjectileModifier.new()
	mod.id = card_name
	mod.categories = [Projectile.Category.ABILITY_PROJECTILE]
	mod.on_spawn_callback = func(_cb_vars: Dictionary) -> void:
		if not is_instance_valid(owner) or owner.spell == null: return
		state[&"count"] += 1
		if state[&"count"] < threshold: return
		state[&"count"] = 0
		var target: Entity = owner.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ENEMY)
		if not is_instance_valid(target): return
		owner.projectile.projectile_attack(target, Projectile.Type.METEOR, owner, ProjectileStats.new())
	owner.projectile_modifiers_registry.register_modifier(mod)
	owner.projectile.register_projectile(Projectile.Type.METEOR)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	owner.projectile_modifiers_registry.unregister_modifier(card_name)
	owner.battle_callback_registry.unregister_all(card_name)
	owner.projectile.unregister_projectile(Projectile.Type.METEOR)


func get_description(card_lvl: int) -> String:
	return "Tous les " + str(_projectiles_per_meteor[card_lvl - 1]) \
		+ " projectiles d'abilité lancés, invoque un météore."
