extends HeroAnimationModule

const PARAM_SCALE_ATTACK_LEFT: String = "parameters/scale_attack_left/scale"
const PARAM_SCALE_ATTACK_RIGHT: String = "parameters/scale_attack_right/scale"
const PARAM_BLEND_ATTACK: String = "parameters/blend_attack/blend_amount"


func _ready() -> void:
	super._ready() # Initialize parent first
	
	# Hero-specific connections
	if _entity_owner != null:
		_entity_owner.fighting_state_changed.connect(_on_hero_fighting_state_changed)
		_entity_owner.fight_is_won.connect(_on_hero_fight_is_won)
		_entity_owner.fight_is_lost.connect(_on_hero_fight_is_lost)


# Override auto attack to add blend logic (left/right hand)
func _on_entity_owner_auto_attack_started(lock_seconds: float) -> void:
	Verbose.debug("Auto attack started (lock_seconds=" + str(lock_seconds).pad_decimals(2) + ")", Verbose.Category.ENTITY_ANIMATION)
	if _lock_animation: return
	var use_right_hand: bool = _rng.randf_range(0.0, 1.0) < 0.5
	if use_right_hand:
		_animation_tree.set(PARAM_BLEND_ATTACK, 1.0)
	else:
		_animation_tree.set(PARAM_BLEND_ATTACK, 0.0)
	
	# Calculate speed_scale so animation fits within lock_seconds, capped to keep visuals readable.
	var speed_scale: float = _attack_anim_base_duration / lock_seconds if lock_seconds > 0.0 else 1.0
	speed_scale = minf(speed_scale, _resolve_aa_anim_max_speed_scale())
	Verbose.debug("Auto attack started (speed_scale=" + str(speed_scale).pad_decimals(2) + ")", Verbose.Category.ENTITY_ANIMATION)
	_animation_tree.set(PARAM_SCALE_ATTACK_LEFT, speed_scale)
	_animation_tree.set(PARAM_SCALE_ATTACK_RIGHT, speed_scale)
	_animation_tree.set(PARAM_ONE_SHOT_ATTACK, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


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
