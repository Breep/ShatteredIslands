class_name HeroAnimationModule
extends AnimationModule

# Hero-specific exports
@export var _weapons_node: Node3D

# Hero-specific constants
const VALUE_TRANSITION_GLOBAL_SITTING: String = "Sitting"
const PARAM_SCALE_ATTACK_LEFT: String = "parameters/scale_attack_left/scale"
const PARAM_SCALE_ATTACK_RIGHT: String = "parameters/scale_attack_right/scale"
const PARAM_BLEND_ATTACK: String = "parameters/blend_attack/blend_amount"

# Hero-specific state
var _is_fighting: bool = false

func _ready() -> void:
	super._ready() # Initialize parent first
	
	# Hero-specific connections
	var hero := _entity_owner as Hero
	if hero:
		hero.fighting_state_changed.connect(_on_hero_fighting_state_changed)


# Override auto attack to add blend logic (left/right hand)
func _on_entity_owner_auto_attack_started() -> void:
	Verbose.debug("Auto attack started", Verbose.Category.ENTITY_ANIMATION)
	var use_right_hand: bool = _rng.randf_range(0.0, 1.0) < 0.5
	if use_right_hand:
		_animation_tree.set(PARAM_BLEND_ATTACK, 1.0)
	else:
		_animation_tree.set(PARAM_BLEND_ATTACK, 0.0)
	
	_animation_tree.set(PARAM_SCALE_ATTACK_LEFT, 1.0 + _entity_owner.stats.attack_speed)
	_animation_tree.set(PARAM_SCALE_ATTACK_RIGHT, 1.0 + _entity_owner.stats.attack_speed)
	_animation_tree.set(PARAM_ONE_SHOT_ATTACK, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


# Hero-specific display mode handling
func apply_display_mode(display_mode: Hero.DisplayMode) -> void:
	match display_mode:
		Hero.DisplayMode.BUYING_PHASE:
			_animation_tree.set(PARAM_TRANSITION_GLOBAL, VALUE_TRANSITION_GLOBAL_SITTING)
			_start_buying_area_animation()
			_weapons_node.hide()
		Hero.DisplayMode.FIGHTING_PHASE:
			_animation_tree.set(PARAM_TRANSITION_GLOBAL, VALUE_TRANSITION_GLOBAL_FIGHTING)
			_animation_tree.set(PARAM_TRANSITION_FIGHTING, VALUE_TRANSITION_FIGHTING_IDLE)
			_weapons_node.show()
		Hero.DisplayMode.PREVIEW:
			_animation_tree.set(PARAM_TRANSITION_GLOBAL, VALUE_TRANSITION_GLOBAL_TPOSE)
			_weapons_node.hide()


func _on_hero_fighting_state_changed(new_state: Hero.FightingState) -> void:
	match new_state:
		Hero.FightingState.FIGHTING:
			_is_fighting = true
		Hero.FightingState.CELEBRATING:
			_is_fighting = false


func _start_buying_area_animation() -> void:
	_idle_variation_timer.wait_time = _rng.randf_range(IDLE_VAR_TIMER_MIN_WAIT_TIME, IDLE_VAR_TIMER_MAX_WAIT_TIME)
	_idle_variation_timer.start()
