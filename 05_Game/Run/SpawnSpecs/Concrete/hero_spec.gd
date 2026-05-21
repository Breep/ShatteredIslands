# Spec d'un héros joueur placé dans une formation (combat ou taverne).
# Porte les données hero-level qui doivent survivre à la destruction de l'instance
# Hero entre chaque phase : deck (cartes achetées), level/xp (progression),
# data_memory (mémoire persistante). C'est la source canonique : la formation
# reste auto-suffisante (portable, sérialisable, envoyable à un copain).
@tool
class_name HeroSpec
extends EntitySpec

@export var level: int = 1
@export var xp: int = 0
@export var deck: PlayerDeck
@export var data_memory: NestedRegistry


# Override : injecte les données portables du spec + runtime du ctx sur l'instance
# Hero avant son ajout au tree (pour que _ready les voie), puis applique le
# display_mode après _ready (anim + healthbar).
# deck et data_memory passés par RÉFÉRENCE : les mutations live (ex: achat carte
# pendant la tavern) propagent vers le spec, donc persistent entre les phases.
func spawn_into(parent: Node, ctx: EntityContext = null) -> Node:
	if scene == null:
		return null

	var node: Node = scene.instantiate()
	if display_label != "":
		node.name = display_label

	var hero: Entity = node as Entity
	if hero == null:
		Verbose.error("HeroSpec.spawn_into: scene n'est pas une Entity, abort", Verbose.Category.ENCOUNTER_RUNNER)
		node.queue_free()
		return null

	# Injection données portables (spec) AVANT add_child
	hero.level = level
	if deck != null:
		hero.deck = deck
	if data_memory != null:
		hero.data_memory = data_memory
	if stats_override != null:
		hero.custom_base_stats = stats_override.duplicate(true)

	# Injection données runtime (ctx) AVANT add_child
	if ctx != null and ctx.runtime_owner_player != null:
		hero.player = ctx.runtime_owner_player

	# Add to tree -> déclenche _enter_tree + _ready qui lisent les valeurs ci-dessus
	if ctx != null and ctx.spawn_manager != null:
		ctx.spawn_manager.spawn_entity(hero, transform, ctx)
	else:
		parent.add_child(hero)
		hero.transform = transform

	# Display mode APRÈS _ready (l'anim + la healthbar doivent être initialisées)
	if ctx != null:
		hero.set_display_mode(ctx.display_mode)

	return hero
