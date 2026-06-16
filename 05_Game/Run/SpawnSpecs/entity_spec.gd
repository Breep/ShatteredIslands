# Spec décrivant une Entity à instancier dans une formation : une RoasterEntry
# (l'identité — desc, level, hand, mémoire) + un placement (transform) + la
# logique de spawn. La RoasterEntry est la source unique des méta-données ;
# joueur comme ennemi en portent une (côté ennemi, l'entry est autonome et non
# rattachée à un roaster). La scène est résolue via EntityDesc.resolve_scene(entry.desc),
# avec repli sur le champ `scene` hérité (markers / specs legacy sans entry).
@tool
class_name EntitySpec
extends SpawnSpec

# RoasterEntry portant l'identité de l'entité (desc, level, hand, data_memory).
# Côté joueur : référence l'entry du roaster (cf. Party). Côté ennemi : entry
# autonome, distinguée du joueur par Party.find_slot_of(entry) == NONE.
@export var entry: RoasterEntry


func spawn_into(parent: Node, ctx: EntityContext = null) -> Node:
	var packed: PackedScene = _resolve_scene()
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
	entity.entry = entry

	# Roaster posé pour les héros uniquement : ce sont eux qui jouent des
	# cartes pouvant muter le roaster. Acolytes/summons/buildings restent à null.
	if entity.category == Entity.Category.HERO and ctx != null:
		entity.roaster = ctx.roaster

	# Méta-data canoniques depuis l'entry (toujours présente dans le modèle unifié).
	if entry != null:
		entity.level = entry.level
		if entry.data_memory != null:
			entity.data_memory = entry.data_memory

	if ctx != null and ctx.spawn_manager != null:
		ctx.spawn_manager.spawn_entity(entity, transform, ctx, Entity.EntityType.HERO, true)
	else:
		parent.add_child(entity)
		entity.transform = transform

	# Bind du deck après add_child : le deck_holder est auto-loadé pendant
	# l'entrée dans l'arbre, donc disponible seulement maintenant. bind_hand
	# applique les upgrades des cartes dans la foulée.
	if entry != null and entry.hand != null and entity.deck_holder != null:
		entity.deck_holder.bind_hand(entry.hand)

	if ctx != null and entity.has_method("set_display_mode"):
		entity.set_display_mode(ctx.display_mode)

	return entity


# Catégorie posée sur l'entité au spawn. Override par les specs concrètes typées
# (AcolyteSpec, AntagonistSpec, BuildingSpec). Sinon dérivée de la desc de
# l'entry, MOB par défaut.
func get_entity_category() -> Entity.Category:
	if entry != null and entry.desc != null:
		return entry.desc.default_category
	return Entity.Category.MOB


# Source de la scène : priorité à la desc de l'entry (source canonique), repli
# sur le champ `scene` hérité (markers / specs legacy sans entry).
func _resolve_scene() -> PackedScene:
	if entry != null and entry.desc != null:
		return EntityDesc.resolve_scene(entry.desc)
	return scene
