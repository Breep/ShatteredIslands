# Spec décrivant une Entity (héros, acolyte, mob, antagonist, ...) à instancier.
# Override de spawn_into pour appliquer stats_override et router via le
# SpawnManager du contexte si fourni (chemin combat) — sinon parent.add_child
# direct (chemin taverne / éditeur).
@tool
class_name EntitySpec
extends SpawnSpec

@export var stats_override: EntityStats = null


func spawn_into(parent: Node, ctx: EntityContext = null) -> Node:
	if scene == null:
		return null
	var node: Node = scene.instantiate()
	if display_label != "":
		node.name = display_label

	var entity: Entity = node as Entity
	if entity == null:
		# Scene non-Entity : fallback comportement de base
		parent.add_child(node)
		if node is Node3D:
			(node as Node3D).transform = transform
		return node

	if stats_override != null:
		entity.custom_base_stats = stats_override.duplicate(true)

	if ctx != null and ctx.spawn_manager != null:
		ctx.spawn_manager.spawn_entity(entity, transform, ctx)
	else:
		parent.add_child(entity)
		entity.transform = transform

	return entity
