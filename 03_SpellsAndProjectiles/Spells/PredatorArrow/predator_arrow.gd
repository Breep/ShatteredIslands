class_name PredatorArrow
extends Spell

# Ultimate de Latika "Flèche du Prédateur" : trait perçant en ligne droite. Frappe
# instantanément tous les ennemis présents dans la HitZone (boîte allongée orientée
# vers la cible visée) pour _damage dégâts physiques. Sort autonome : aucun lien avec
# l'auto-attaque ni l'AD de Latika.

enum Modifier { DAMAGE }

const _DEFAULT_DAMAGE: float = 50.0
## Délai avant despawn, laisse le VFX du trait se jouer.
const _VFX_LIFETIME: float = 1.0

@onready var _hit_zone: Area3D = %HitZone

var _owner: Entity
var _target: Entity
var _damage: float


func init(source: Entity, target: Entity, modifiers: Dictionary) -> void:
	_owner = source
	_target = target
	_damage = modifiers.get(Modifier.DAMAGE, _DEFAULT_DAMAGE)


func _ready() -> void:
	if not is_instance_valid(_owner):
		queue_free()
		return

	global_position = _owner.global_position
	_aim_towards_target()

	await get_tree().physics_frame
	if not is_inside_tree():
		return

	for body in _hit_zone.get_overlapping_bodies():
		if not body is Entity:
			continue
		var entity: Entity = body
		if entity.team == _owner.team:
			continue
		var damage_done: float = _owner.damage.direct(
			entity, _damage, Utils.ActionType.DAMAGE_PHYSICAL, &"predator_arrow")
		# Applique les effets on-hit de l'AA du lanceur (riders de cartes), sans dégâts AA.
		# La marque (passif) n'en fait pas partie : elle vit hors du bucket on-hit.
		if _owner.auto_attack != null:
			_owner.auto_attack.apply_on_hit_effects(_owner, entity, damage_done)

	await get_tree().create_timer(_VFX_LIFETIME).timeout
	queue_free()


# Oriente le sort (axe -Z local de la boîte) vers la cible visée, à plat sur le sol.
func _aim_towards_target() -> void:
	if not is_instance_valid(_target):
		global_rotation = _owner.global_rotation
		return
	var aim: Vector3 = _target.get_collision_center()
	aim.y = global_position.y
	if aim.is_equal_approx(global_position):
		global_rotation = _owner.global_rotation
		return
	look_at(aim)
