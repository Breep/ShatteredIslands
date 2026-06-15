# ProjectileModifier — altère un projectile à tirer : filtrage par
# type/category/size, mutation pré-spawn (count, level, bounce) et callbacks
# per-projectile (spawn/hit).
#
# /!\ DETTE STRUCTURELLE — À REFACTORISER /!\
# Chaque propriété ajustable au pré-spawn (count, level, et maintenant bounce)
# duplique le même tryptique : un champ `*_modifier_callback: Callable` ici + un
# Resolver dédié dans 09_Lib + une méthode `_resolve_spawn_*` dans
# ProjectileComponent. Ça ne passe pas à l'échelle : la prochaine propriété
# (speed, pierce, size...) rejouera ce copier-coller. À généraliser en un seul
# mécanisme keyed (un registre de resolvers indexés par propriété) au lieu d'un
# Callable nommé par propriété. Dette partagée par tout le dossier Modifiers
# (cf. la note de SummonModifiersRegistry).
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

# Pré-spawn : mute le compteur de projectiles à tirer (cf. CountResolver).
# Reçoit un Dictionary { CountResolver.COUNT: int } à muter.
var count_modifier_callback: Callable
# Pré-spawn : mute le level du projectile à tirer (cf. LevelResolver).
# Reçoit un Dictionary { LevelResolver.LEVEL: int } à muter. Le level
# détermine ensuite quel index dans les Array @export du projectile est lu
# (damage, hit_radius, etc. selon la sous-classe).
var level_modifier_callback: Callable
# Pré-spawn : mute le nombre de rebonds du projectile à tirer (cf.
# BounceResolver). Reçoit un Dictionary { BounceResolver.BOUNCE: float } à
# muter. Flottant : partie entière = rebonds garantis, décimale = proba d'un
# rebond supplémentaire (cf. ProjectileStats.bounces_remaining).
var bounce_modifier_callback: Callable
# Per-projectile : appelés à l'apparition / au hit du projectile spawné.
var on_spawn_callback: Callable # var: Dictionary
var on_hit_callback: Callable # var: Dictionary


func filter(projectile: Projectile) -> bool:
	if projectile == null: return false
	return filter_meta(projectile.type, projectile.category, projectile.size)


# Filtre sans instance de Projectile — utilisé en phase pré-spawn (count
# modifiers, baking des callbacks) quand le projectile n'a pas encore été
# instancié. p_size peut être -1 pour ignorer le filtre de taille (côté
# composant on ne connaît pas toujours la size sans instancier la scène).
func filter_meta(p_type: int, p_category: int, p_size: int = -1) -> bool:
	var size_ok: bool = sizes.is_empty() or p_size < 0 or sizes.has(p_size)
	return (types.is_empty() or types.has(p_type)) \
		and (categories.is_empty() or categories.has(p_category)) \
		and size_ok
