class_name SE_EclosionSolaire
extends SkillEffect

# Ultimate "Éclosion solaire": quand le mana de l'œuf est plein (incubation terminée), s'il
# est encore vivant, il ressuscite un Phoenix au même endroit avec _hp_ratio de ses PV
# (porté à 100% si le talent "Renaissance solaire" a posé FULL_HP_META), puis l'œuf meurt.

const FULL_HP_META := &"phoenix_egg_full_hatch"

@export var _phoenix_scene_path: String = "res://02_Entities/Pool/Mobs/Phoenix/phoenix.tscn"
@export var _hp_ratio: float = 0.5


func apply(ctx: SkillContext) -> void:
	var egg: Entity = ctx.entity
	if egg.is_dead():
		return
	var scene: PackedScene = load(_phoenix_scene_path)
	if scene == null:
		Verbose.warn("SE_EclosionSolaire: scène phoenix introuvable: " + _phoenix_scene_path, Verbose.Category.ENTITY_MODULE)
		return
	var context: EntityContext = egg.get_context()
	if context.spawn_manager == null:
		return

	var phoenix := scene.instantiate() as Entity
	if phoenix == null:
		return
	# Niveau réglé AVANT le spawn : la progression lit _owner.level à son _ready, donc les
	# skills (dont le Gold "Renaissance solaire" +30 AP) s'appliquent au bon niveau.
	if egg.progression != null:
		phoenix.level = egg.progression.level
	# Incrémente le compteur de résurrections → le Gold "Renaissance solaire" applique +30 de plus.
	phoenix.set_meta(SE_RenaissanceSolaire.RESURRECTION_COUNT_META, egg.get_meta(SE_RenaissanceSolaire.RESURRECTION_COUNT_META, 0) + 1)
	context.spawn_manager.spawn_entity(phoenix, Transform3D(Basis(), egg.global_position), context)

	var ratio: float = 1.0 if egg.get_meta(FULL_HP_META, false) else _hp_ratio
	phoenix.stats.health = phoenix.stats.health_max * ratio

	# L'œuf est consommé par l'éclosion → despawn propre (comme le ChickenEgg).
	if egg.despawn != null:
		egg.despawn.play_despawn_animation()
	else:
		egg.queue_free()
