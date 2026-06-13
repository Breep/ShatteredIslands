class_name PredatorArrow
extends Spell

# Ultimate de Latika "Flèche du Prédateur" : trait perçant en ligne droite. Au cast,
# joue une anticipation sur le lanceur, puis un projectile (cube) voyage le long de la
# HitZone (boîte allongée orientée vers la cible). Chaque ennemi est frappé quand le
# projectile atteint sa position (dégâts physiques + VFX d'impact), ce qui rend le sort
# télégraphié et esquivable. Sort autonome : aucun lien avec l'auto-attaque ni l'AD.

enum Modifier { DAMAGE }

const _DEFAULT_DAMAGE: float = 50.0
## Délai entre le début de l'anticipation et le départ du projectile.
const _ANTICIPATION_WINDUP: float = 0.35
## Vitesse de déplacement du projectile le long du trait, en unités/seconde.
const _PROJECTILE_SPEED: float = 15.0
## Délai après l'arrivée du projectile avant despawn, laisse jouer cube et impacts.
const _DESPAWN_DELAY: float = 1.0

const _ANTICIPATION_VFX: PackedScene = preload("res://03_SpellsAndProjectiles/Spells/PredatorArrow/VFX/Scenes/VFX_Anticipation_wave_digital.tscn")
const _CUBE_VFX: PackedScene = preload("res://03_SpellsAndProjectiles/Spells/PredatorArrow/VFX/Scenes/VFX_Cube_projectile.tscn")
const _HIT_VFX: PackedScene = preload("res://03_SpellsAndProjectiles/Spells/PredatorArrow/VFX/Scenes/VFX_Hit_cyber.tscn")

@onready var _hit_zone: Area3D = %HitZone

var _owner: Entity
var _target: Entity
var _damage: float

var _range: float = 0.0
var _traveled: float = 0.0
var _is_travelling: bool = false
var _cube: Node3D
var _hit_entities: Array[Entity] = []


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
	_range = _resolve_range()

	# Anticipation jouée à l'origine du trait (sur le lanceur), orientée vers la cible.
	_spawn_vfx(_ANTICIPATION_VFX, Vector3.ZERO)

	await get_tree().create_timer(_ANTICIPATION_WINDUP).timeout
	if not is_inside_tree():
		return

	_cube = _spawn_vfx(_CUBE_VFX, Vector3.ZERO)
	_is_travelling = true


func _physics_process(delta: float) -> void:
	if not _is_travelling:
		return

	_traveled = minf(_traveled + _PROJECTILE_SPEED * delta, _range)
	if is_instance_valid(_cube):
		_cube.position.z = -_traveled

	_hit_reached_entities()

	if _traveled >= _range:
		_is_travelling = false
		_despawn_after_delay()


# Frappe les ennemis de la HitZone que le projectile vient de dépasser (une seule fois).
func _hit_reached_entities() -> void:
	for body in _hit_zone.get_overlapping_bodies():
		if not body is Entity:
			continue
		var entity: Entity = body
		if entity.team == _owner.team or entity in _hit_entities:
			continue
		var distance_along: float = -to_local(entity.get_collision_center()).z
		if distance_along < 0.0 or distance_along > _traveled:
			continue
		_hit_entities.append(entity)
		_hit_entity(entity)


func _hit_entity(entity: Entity) -> void:
	var damage_done: float = _owner.damage.direct(
		entity, _damage, Utils.ActionType.DAMAGE_PHYSICAL, &"predator_arrow")
	# Applique les effets on-hit de l'AA du lanceur (riders de cartes), sans dégâts AA.
	# La marque (passif) n'en fait pas partie : elle vit hors du bucket on-hit.
	if _owner.auto_attack != null:
		_owner.auto_attack.apply_on_hit_effects(_owner, entity, damage_done)
	_spawn_hit_vfx(entity)


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


# Portée du trait = longueur de la boîte de la HitZone (axe Z), pour rester synchro.
func _resolve_range() -> float:
	var collision: CollisionShape3D = _hit_zone.get_node_or_null("CollisionShape3D")
	if collision != null and collision.shape is BoxShape3D:
		return (collision.shape as BoxShape3D).size.z
	return 30.0


func _spawn_vfx(scene: PackedScene, local_position: Vector3) -> Node3D:
	var vfx: Node3D = scene.instantiate()
	add_child(vfx)
	vfx.position = local_position
	return vfx


func _spawn_hit_vfx(entity: Entity) -> void:
	var hit: Node3D = _HIT_VFX.instantiate()
	add_child(hit)
	hit.global_position = entity.get_collision_center()


func _despawn_after_delay() -> void:
	await get_tree().create_timer(_DESPAWN_DELAY).timeout
	queue_free()
