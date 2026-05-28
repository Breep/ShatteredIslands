# Spec décrivant une Entity (héros, acolyte, mob, antagonist, ...) à instancier.
# Porte le placement (transform) + un override de level/stats + éventuellement
# une référence vers une RoasterEntry (côté joueur, lien vers l'inventaire).
#
# Source de la scene : `desc.scene` (préférence) ou `scene` (legacy/fallback).
# Quand `entry` est non-null (cas joueur), level/deck/data_memory de l'entry
# écrasent ceux de la scene au spawn — ils sont la source canonique.
@tool
class_name EntitySpec
extends SpawnSpec

@export var desc: EntityDesc
@export_range(1, 20) var level: int = 1
@export var stats_override: EntityStats = null

# Référence vers l'entrée roaster correspondante. Nullable :
# - rempli côté joueur (les specs sont générées depuis le roaster ou liées
#   manuellement à une entry)
# - null côté ennemi (mob/antagoniste préconstruit en .tres)
@export var entry: RoasterEntry


func spawn_into(parent: Node, ctx: EntityContext = null) -> Node:
	var packed: PackedScene = scene
	if packed == null and desc != null:
		packed = desc.scene
	if packed == null:
		return null

	var node: Node = packed.instantiate()
	if display_label != "":
		node.name = display_label

	var entity: Entity = node as Entity
	if entity == null:
		# Scene non-Entity : fallback comportement de base
		parent.add_child(node)
		if node is Node3D:
			(node as Node3D).transform = transform
		return node

	entity.category = get_entity_category()

	# Méta-data canoniques depuis l'entry (joueur) ou la scene (ennemi).
	if entry != null:
		entity.level = entry.level
		if entry.deck != null and "deck" in entity:
			entity.deck = entry.deck
		if entry.data_memory != null and "data_memory" in entity:
			entity.data_memory = entry.data_memory

	# Runtime owner (Player) injecté si le ctx en fournit un et l'entité
	# expose le field (cas hero).
	if ctx != null and ctx.runtime_owner_player != null and "player" in entity:
		entity.player = ctx.runtime_owner_player

	if ctx != null and ctx.spawn_manager != null:
		ctx.spawn_manager.spawn_entity(entity, transform, ctx)
	else:
		parent.add_child(entity)
		entity.transform = transform

	if ctx != null and entity.has_method("set_display_mode"):
		entity.set_display_mode(ctx.display_mode)

	return entity


# Catégorie posée sur l'entité au spawn. Override par les specs concrètes typées
# (AcolyteSpec, AntagonistSpec, BuildingSpec). Si une `desc` est fournie, on
# utilise sa default_category ; sinon MOB par défaut.
func get_entity_category() -> Entity.Category:
	if desc != null:
		return desc.default_category
	return Entity.Category.MOB
