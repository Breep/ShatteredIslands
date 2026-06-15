# Helper statique pour résoudre le level d'un projectile (ou de tout autre
# élément à level) à partir d'une liste de callbacks qui peuvent muter ce
# level. Convention : chaque callback reçoit un Dictionary contenant la clé
# LEVEL et peut la modifier (ex: cb_vars[LevelResolver.LEVEL] += 1, ou
# conditionnel sur randf()).
#
# Le résultat est borné à >= 1 : le level de base est 1, un modifier ne peut
# pas le faire tomber en dessous.
class_name LevelResolver

const LEVEL := &"level"


static func resolve(callbacks: Array[Callable], base: int = 1) -> int:
	var cb_vars := { LEVEL: base }
	for cb: Callable in callbacks:
		if cb.is_valid():
			cb.call(cb_vars)
	return maxi(1, cb_vars[LEVEL])
