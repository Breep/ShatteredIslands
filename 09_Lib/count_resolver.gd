# Helper statique pour résoudre un compteur (ex: nombre de projectiles à
# spawner, nombre de summons à invoquer) à partir d'une liste de callbacks
# qui peuvent muter ce compteur.
#
# Convention : chaque callback reçoit un Dictionary contenant la clé COUNT
# et peut la modifier (ex: cb_vars[CountResolver.COUNT] += 2, ou conditionnel
# sur randf()).
#
# Le résultat est borné à >= 1 : un count_modifier ne peut pas annuler le tir
# de base. Pour empêcher un spawn, c'est une autre mécanique (stun, silence...).
class_name CountResolver

const COUNT := &"count"


static func resolve(callbacks: Array[Callable], base: int = 1) -> int:
	var cb_vars := { COUNT: base }
	for cb: Callable in callbacks:
		if cb.is_valid():
			cb.call(cb_vars)
	return maxi(1, cb_vars[COUNT])
