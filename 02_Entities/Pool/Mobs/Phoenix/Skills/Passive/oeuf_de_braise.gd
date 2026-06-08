class_name SE_OeufDeBraise
extends SkillEffect

# Passif "Œuf de braise": à sa mort, le Phoenix crée un Œuf Phoenix au même endroit
# (l'œuf peut ensuite le ressusciter via son ultimate "Éclosion solaire").

@export var _egg_scene_path: String = "res://02_Entities/Pool/Mobs/PhoenixEgg/phoenix_egg.tscn"


func apply(ctx: SkillContext) -> void:
	var phoenix: Entity = ctx.entity
	var modifier := DeathModifier.new()
	modifier.id = &"OeufDeBraise"
	modifier.after_action_logic_callback = func(_cb_vars: Dictionary) -> void:
		_spawn_egg(phoenix)
	phoenix.death_modifiers_registry.register_modifier(modifier)


func _spawn_egg(phoenix: Entity) -> void:
	var scene: PackedScene = load(_egg_scene_path)
	if scene == null:
		Verbose.warn("SE_OeufDeBraise: scène œuf introuvable: " + _egg_scene_path, Verbose.Category.ENTITY_MODULE)
		return
	var context: EntityContext = phoenix.get_context()
	if context.spawn_manager == null:
		return
	var egg := scene.instantiate() as Entity
	if egg == null:
		return
	# Niveau réglé AVANT le spawn (la progression lit _owner.level à son _ready) pour que les
	# skills de l'œuf s'appliquent au bon niveau.
	if phoenix.progression != null:
		egg.level = phoenix.progression.level
	# Transmet le compteur de résurrections à l'œuf (l'éclosion l'incrémentera).
	egg.set_meta(SE_RenaissanceSolaire.RESURRECTION_COUNT_META, phoenix.get_meta(SE_RenaissanceSolaire.RESURRECTION_COUNT_META, 0))
	context.spawn_manager.spawn_entity(egg, Transform3D(Basis(), phoenix.global_position), context)
