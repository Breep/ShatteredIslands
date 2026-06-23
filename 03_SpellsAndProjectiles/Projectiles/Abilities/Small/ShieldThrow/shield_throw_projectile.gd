# Shield Throw — projectile d'abilité à rebonds dont le comportement par défaut
# est, à chaque ennemi touché : infliger des dégâts magiques (part flat + ratio
# de l'AP du lanceur) puis régénérer du shield au lanceur. Le nombre de rebonds
# (sur l'ennemi le plus proche) est lui aussi par-level.
#
# Variables par-level : _damage, _damage_ratio, _shield_return, _bounces sont des
# Array @export indexées par level (résolu par ProjectileComponent + LevelResolver,
# repris depuis _stats.level dans Projectile.init()). L'attribution des actions
# (pipeline damage / alterations) vient de _stats.source_id, posé par l'émetteur
# (typiquement card_name côté carte).
class_name ShieldThrowProjectile
extends Projectile

## Dégâts magiques flat infligés à chaque ennemi touché, par level.
@export var _damage: Array[float] = []
## Ratio de l'AP du lanceur ajouté aux dégâts magiques, par level.
@export var _damage_ratio: Array[float] = []
## Shield régénéré au lanceur à chaque ennemi touché, par level.
@export var _shield_return: Array[float] = []
## Nombre de rebonds (flottant : partie décimale = proba d'un rebond de plus), par level.
@export var _bounces: Array[float] = []


func _ready() -> void:
	# Pose le comportement par défaut AVANT super._ready() : le nombre de rebonds
	# doit être en place avant le 1er tick, et _on_shield_hit avant le 1er hit.
	_stats.source_id = &"ShieldThrow"
	if _stats != null:
		_stats.bounces_remaining = value_at_level(_bounces, level, 0.0)
		_stats.on_hit_callbacks.append(_on_shield_hit)
	super._ready()


func _on_shield_hit(cb_vars: Dictionary) -> void:
	var source: Entity = cb_vars.get(ProjectileStats.VarType.SOURCE)
	if not is_instance_valid(source): return
	var target: Entity = cb_vars.get(ProjectileStats.VarType.TARGET)
	if not is_instance_valid(target): return
	# Le projectile peut traverser/toucher des alliés (retour boomerang, trajectoire) :
	# on ne déclenche l'effet que sur un ennemi, jamais sur le lanceur ou son camp.
	if target.team == source.team: return

	var damage: float = value_at_level(_damage, level, 0.0) \
		+ value_at_level(_damage_ratio, level, 0.0) * source.stats.get_stat(EntityStats.StatType.AP)
	var shield_return: float = value_at_level(_shield_return, level, 0.0)
	var source_id: StringName = _stats.source_id if _stats != null else &""

	if damage > 0.0:
		source.damage.direct(target, damage, Utils.ActionType.DAMAGE_MAGICAL, source_id)
	if shield_return > 0.0:
		source.alterations.direct_stack(source, shield_return, Alteration.Type.SHIELD, source_id)
