class_name SE_GolemBrood
extends SkillEffect

# Talent "Couvée": à sa mort, le golem invoque _count petits golems (scène _golem_scene_path)
# de niveau _spawn_level et d'échelle _scale, qui combattent jusqu'à leur propre mort.
# Spawn direct via le spawn_manager (pas de passage par summon_component). Les petits golems
# étant niveau 5, ils n'ont pas le Gold (Couvée) → pas de récursion infinie.

@export var _golem_scene_path: String = ""
@export var _count: int = 3
@export var _spawn_level: int = 5
@export var _scale: float = 0.5
@export var _spawn_radius: float = 1.5


func apply(ctx: SkillContext) -> void:
	var golem: Entity = ctx.entity
	if golem == null:
		return
	var modifier := DeathModifier.new()
	modifier.id = &"GolemBrood"
	modifier.after_action_logic_callback = func(_cb_vars: Dictionary) -> void:
		_spawn_brood(golem)
	golem.death_modifiers_registry.register_modifier(modifier)


func get_description() -> String:
	return "À sa mort, invoque " + _value(_count) + " petits golems de niveau " \
		+ _value(_spawn_level) + " qui combattent jusqu'à leur propre mort."


func _spawn_brood(golem: Entity) -> void:
	if _golem_scene_path.is_empty():
		return
	var scene: PackedScene = load(_golem_scene_path)
	if scene == null:
		Verbose.warn("SE_GolemBrood: scène introuvable: " + _golem_scene_path, Verbose.Category.ENTITY_MODULE)
		return

	var context: EntityContext = golem.get_context()
	var spawn_manager: SpawnManager = context.spawn_manager
	if spawn_manager == null:
		return

	for i: int in _count:
		var small := scene.instantiate() as Entity
		if small == null:
			continue
		var angle: float = TAU * float(i) / float(_count)
		var offset := Vector3(cos(angle), 0.0, sin(angle)) * _spawn_radius
		spawn_manager.spawn_entity(small, Transform3D(Basis(), golem.global_position + offset), context)
		small.scale = Vector3.ONE * _scale
		if small.progression != null:
			small.progression.level = _spawn_level
