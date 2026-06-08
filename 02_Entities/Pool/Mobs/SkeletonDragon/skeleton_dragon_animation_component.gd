class_name SkeletonDragonAnimationComponent
extends DefaultAnimationComponent

# Dragon-specific animation translation: adds the "Fly" stance on top of the
# generic DefaultAnimationComponent. Pure AnimationTree-param setters — all the
# sequencing/timing is owned by ShatteringFlightAbility (deterministic ticks);
# this class only flips parameters on command and reports clip lengths.

#region AnimationTree parameters
const VALUE_SWITCH_MAIN_FLYING: String = "Flying"

const PARAM_SWITCH_FLY: String = "parameters/switch_fly/transition_request"
const VALUE_SWITCH_FLY_START: String = "FlyStart"
const VALUE_SWITCH_FLY_LOOP: String = "FlyLoop"
const VALUE_SWITCH_FLY_STOP: String = "FlyStop"

const PARAM_ONE_SHOT_FLY_ATTACK: String = "parameters/one_shot_fly_attack/request"

const VALUE_SWITCH_MAIN_SPELL: String = "Spell"
const PARAM_SWITCH_SPELL: String = "parameters/switch_spell/transition_request"
const VALUE_SWITCH_SPELL_START: String = "SpellStart"
const VALUE_SWITCH_SPELL_LOOP: String = "SpellLoop"
const VALUE_SWITCH_SPELL_END: String = "SpellEnd"
#endregion

#region Private vars
const _ANIM_TAKEOFF: String = "Transiton_ToFly"
const _ANIM_LANDING: String = "Transition_ToGround"
const _ANIM_SPELL_START: String = "Combat_Ground_Spell_Start"
const _ANIM_SPELL_END: String = "Combat_Ground_Spell_End"
#endregion

#region Public functions
func begin_takeoff() -> void:
	_lock_animation = true
	_animation_tree.set(PARAM_SWITCH_FLY, VALUE_SWITCH_FLY_START)
	_animation_tree.set(PARAM_SWITCH_MAIN, VALUE_SWITCH_MAIN_FLYING)


func enter_fly_loop() -> void:
	_animation_tree.set(PARAM_SWITCH_FLY, VALUE_SWITCH_FLY_LOOP)


func begin_landing() -> void:
	_animation_tree.set(PARAM_SWITCH_FLY, VALUE_SWITCH_FLY_STOP)


## Fires the in-air attack overlay (the ground attack one-shot is locked while flying).
func play_fly_attack() -> void:
	_animation_tree.set(PARAM_ONE_SHOT_FLY_ATTACK, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func end_fly() -> void:
	_animation_tree.set(PARAM_SWITCH_MAIN, VALUE_SWITCH_MAIN_IDLE)
	_lock_animation = false


func takeoff_length() -> float:
	return _clip_length(_ANIM_TAKEOFF)


func landing_length() -> float:
	return _clip_length(_ANIM_LANDING)


func begin_spell() -> void:
	_lock_animation = true
	_animation_tree.set(PARAM_SWITCH_SPELL, VALUE_SWITCH_SPELL_START)
	_animation_tree.set(PARAM_SWITCH_MAIN, VALUE_SWITCH_MAIN_SPELL)


func channel_spell() -> void:
	_animation_tree.set(PARAM_SWITCH_SPELL, VALUE_SWITCH_SPELL_LOOP)


func end_spell() -> void:
	_animation_tree.set(PARAM_SWITCH_SPELL, VALUE_SWITCH_SPELL_END)


func finish_spell() -> void:
	_animation_tree.set(PARAM_SWITCH_MAIN, VALUE_SWITCH_MAIN_IDLE)
	_lock_animation = false


func spell_start_length() -> float:
	return _clip_length(_ANIM_SPELL_START)


func spell_end_length() -> float:
	return _clip_length(_ANIM_SPELL_END)
#endregion

#region Private functions
func _clip_length(anim_name: String) -> float:
	var player: AnimationPlayer = _player()
	if player == null or not player.has_animation(anim_name):
		Verbose.warn("Fly clip not found: " + anim_name, Verbose.Category.ENTITY_ANIMATION)
		return 0.0
	return player.get_animation(anim_name).length


func _player() -> AnimationPlayer:
	if _animation_tree == null:
		return null
	return _animation_tree.get_node_or_null(_animation_tree.anim_player) as AnimationPlayer
#endregion

#region Callbacks
# The dragon drives its ultimate through begin_spell/channel_spell/end_spell
# (DevastatingBreathAbility), so the generic one-shot ultimate of the base must
# never fire — its node no longer exists in this tree.
func _on_owner_ultimate_casted() -> void:
	pass
#endregion
