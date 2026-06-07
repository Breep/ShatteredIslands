class_name ProjectileModifier
extends Modifier

enum VarType { # Variable types of the callbacks dictionary
	SOURCE,
	TARGET,
	POSITION,
	DAMAGE,
	PROJECTILE
}

var types: Array[Projectile.Type]
var categories: Array[Projectile.Category]
var sizes: Array[Projectile.Size]

var on_spawn_callback: Callable # var: Dictionary
var on_hit_callback: Callable # var: Dictionary

func filter(projectile: Projectile) -> bool:
	if projectile == null: return false
	return (types.is_empty() or types.has(projectile.type)) \
		and (categories.is_empty() or categories.has(projectile.category)) \
		and (sizes.is_empty() or sizes.has(projectile.size))
