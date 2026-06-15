# Helper statique pour résoudre le nombre de rebonds d'un projectile à partir
# d'une liste de callbacks qui peuvent muter ce nombre. Convention : chaque
# callback reçoit un Dictionary contenant la clé BOUNCE et peut la modifier
# (ex: cb_vars[BounceResolver.BOUNCE] += 1, ou conditionnel sur randf()).
#
# Le nombre de rebonds est un flottant (cf. ProjectileStats.bounces_remaining) :
# partie entière = rebonds garantis, décimale = probabilité d'un rebond en plus.
# La base est le bounce déjà configuré sur le projectile (pas une constante comme
# pour count/level), pour que les modifiers s'ajoutent par-dessus. Le résultat
# est borné à >= 0 : un modifier ne peut pas rendre le nombre de rebonds négatif.
class_name BounceResolver

const BOUNCE := &"bounce"


static func resolve(callbacks: Array[Callable], base: float = 0.0) -> float:
	var cb_vars := { BOUNCE: base }
	for cb: Callable in callbacks:
		if cb.is_valid():
			cb.call(cb_vars)
	return maxf(0.0, cb_vars[BOUNCE])
