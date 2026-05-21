class_name HeroAnimationModule
extends AnimationComponent

# Hero-specific exports
@export var _weapons_node: Node3D

# Hero-specific constants
const VALUE_TRANSITION_GLOBAL_SITTING: String = "Sitting"
const DEFAULT_AA_ANIM_MAX_SPEED_SCALE: float = 4.0


# Hero-specific state
var _is_fighting: bool = false

func _ready() -> void:
	super._ready() # Initialize parent first
	
	# Hero-specific connections
	if _entity_owner != null:
		_entity_owner.fighting_state_changed.connect(_on_hero_fighting_state_changed)
		_entity_owner.fight_is_won.connect(_on_hero_fight_is_won)
		_entity_owner.fight_is_lost.connect(_on_hero_fight_is_lost)


# Hero-specific display mode handling
func apply_display_mode(display_mode: Entity.DisplayMode) -> void:
	match display_mode:
		Entity.DisplayMode.BUYING_PHASE:
			_animation_tree.set(PARAM_TRANSITION_GLOBAL, VALUE_TRANSITION_GLOBAL_SITTING)
			_start_buying_area_animation()
			_weapons_node.hide()
		Entity.DisplayMode.FIGHTING_PHASE:
			_animation_tree.set(PARAM_TRANSITION_GLOBAL, VALUE_TRANSITION_GLOBAL_FIGHTING)
			_animation_tree.set(PARAM_TRANSITION_FIGHTING, VALUE_TRANSITION_FIGHTING_IDLE)
			_weapons_node.show()
		Entity.DisplayMode.PREVIEW:
			_animation_tree.set(PARAM_TRANSITION_GLOBAL, VALUE_TRANSITION_GLOBAL_TPOSE)
			_weapons_node.hide()


func _on_hero_fighting_state_changed(new_state: Entity.FightingState) -> void:
	match new_state:
		Entity.FightingState.FIGHTING:
			_is_fighting = true
		Entity.FightingState.CELEBRATING:
			_is_fighting = false


func _start_buying_area_animation() -> void:
	_idle_variation_timer.wait_time = _rng.randf_range(IDLE_VAR_TIMER_MIN_WAIT_TIME, IDLE_VAR_TIMER_MAX_WAIT_TIME)
	_idle_variation_timer.start()


func _resolve_aa_anim_max_speed_scale() -> float:
	if _entity_owner != null and _entity_owner.entity_desc != null:
		return _entity_owner.entity_desc.aa_anim_max_speed_scale
	return DEFAULT_AA_ANIM_MAX_SPEED_SCALE


func _on_hero_fight_is_won() -> void:
	if _lock_animation: return
	_animation_tree.set(PARAM_TRANSITION_FIGHTING, VALUE_TRANSITION_FIGHTING_DANCE)


func _on_hero_fight_is_lost() -> void:
	if _lock_animation: return
	_animation_tree.set(PARAM_TRANSITION_FIGHTING, VALUE_TRANSITION_FIGHTING_DIE)
