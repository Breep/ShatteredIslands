class_name UIStoryIntro
extends Control

# Tutorial-only intro cinematic. Plays N StoryBeats one after the other:
# black background, a per-beat scene instantiated in the stage. Each beat scene
# owns its visual layout, optional AnimationPlayer "intro", and a RichTextLabel
# named "StoryText" that hosts the typewriter line at the position of its
# choice. Click / Space advance, Skip button or Esc jumps to the end. Emits
# `finished` when the cinematic terminates. The default top-level behavior is
# to call GameManager.start_solo_game() on `finished`; the proto scene
# disables that to test in isolation.

#region ============================== Signals ==============================
signal finished()
#endregion


#region ============================== Constants ==============================
const TYPEWRITER_CHARS_PER_SEC: float = 26.0
const BEAT_FADE_OUT_TIME: float = 0.4
const BEAT_FADE_IN_TIME: float = 1.0
const AUDIO_CROSSFADE_TIME: float = 0.5
const FINAL_FADE_OUT_TIME: float = 0.5
const ANIMATION_PLAYER_NAME: StringName = &"AnimationPlayer"
const INTRO_ANIMATION_NAME: StringName = &"intro"
#endregion


#region ============================== Export ==============================
@export var beats: Array[StoryBeat] = []

## When true (default), starts the solo game when the cinematic ends. Disable
## in proto / standalone test scenes that should NOT launch the game.
@export var auto_start_game_on_finish: bool = true
#endregion


#region ============================== Private variables ==============================
var _beat_index: int = -1
var _current_beat: StoryBeat
var _current_beat_node: Node
var _story_text: RichTextLabel
var _typewriter_tween: Tween
var _stage_tween: Tween
var _audio_tween: Tween
var _global_tween: Tween
var _hold_timer: Timer
var _typewriter_finished: bool = false
var _cinematic_finished: bool = false
#endregion


#region ============================== Local nodes ==============================
@onready var _beat_stage: Control = %BeatStage
@onready var _skip_button: Button = %SkipButton
@onready var _audio_player: AudioStreamPlayer = %AudioPlayer
@onready var _fade_overlay: ColorRect = %FadeOverlay
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	_skip_button.pressed.connect(_on_skip_pressed)
	finished.connect(_on_finished)

	_hold_timer = Timer.new()
	_hold_timer.one_shot = true
	add_child(_hold_timer)
	_hold_timer.timeout.connect(_advance_beat)

	if beats.is_empty():
		Verbose.warn("UIStoryIntro started with no beats", Verbose.Category.TUTORIAL)
		_finish()
		return

	_advance_beat()


func _unhandled_input(event: InputEvent) -> void:
	if _cinematic_finished:
		return
	if event.is_action_pressed("ui_cancel"):
		_finish()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		_handle_user_advance()
		get_viewport().set_input_as_handled()
#endregion


#region ============================== Public functions ==============================
func play(p_beats: Array[StoryBeat]) -> void:
	beats = p_beats
	_beat_index = -1
	if is_inside_tree():
		_advance_beat()
#endregion


#region ============================== Private functions ==============================
func _advance_beat() -> void:
	_beat_index += 1
	if _beat_index >= beats.size():
		_finish()
		return

	_current_beat = beats[_beat_index]
	if _current_beat == null:
		Verbose.warn("UIStoryIntro: null beat at index " + str(_beat_index), Verbose.Category.TUTORIAL)
		_advance_beat()
		return

	Verbose.debug("Beat " + str(_beat_index) + ": " + String(_current_beat.id), Verbose.Category.TUTORIAL)

	_typewriter_finished = false
	_hold_timer.stop()

	_swap_beat_scene(_current_beat.beat_scene)
	if _current_beat.continues_previous_audio:
		if _current_beat.ambiance_stream != null:
			Verbose.warn("Beat " + String(_current_beat.id) + ": continues_previous_audio=true overrides ambiance_stream", Verbose.Category.TUTORIAL)
	else:
		_swap_audio(_current_beat.ambiance_stream)
	_start_typewriter(_current_beat.text)


func _swap_beat_scene(new_scene: PackedScene) -> void:
	_kill_tween(_stage_tween)

	var old_node: Node = _current_beat_node
	_current_beat_node = null
	_story_text = null

	var new_node: Node = null
	if new_scene != null:
		new_node = new_scene.instantiate()
		var new_canvas: CanvasItem = new_node as CanvasItem
		if new_canvas != null:
			new_canvas.modulate.a = 0.0
		_beat_stage.add_child(new_node)
		_current_beat_node = new_node
		_story_text = new_node.find_child("StoryText", true, false) as RichTextLabel
		if _story_text != null:
			_story_text.text = ""
			_story_text.visible_ratio = 0.0
		# Start the intro animation immediately (before the fade-in) so the
		# nodes snap to the animation's first keyframe instead of showing the
		# scene-default state during the fade.
		_play_beat_animation(new_node)

	_stage_tween = create_tween()
	_stage_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	if old_node != null and is_instance_valid(old_node):
		var old_canvas: CanvasItem = old_node as CanvasItem
		if old_canvas != null:
			_stage_tween.tween_property(old_canvas, "modulate:a", 0.0, BEAT_FADE_OUT_TIME)
		_stage_tween.tween_callback(old_node.queue_free)

	if new_node != null:
		var new_canvas2: CanvasItem = new_node as CanvasItem
		if new_canvas2 != null:
			_stage_tween.tween_property(new_canvas2, "modulate:a", 1.0, BEAT_FADE_IN_TIME)


func _play_beat_animation(beat_node: Node) -> void:
	if beat_node == null or not is_instance_valid(beat_node):
		return
	var anim_player: AnimationPlayer = beat_node.find_child(String(ANIMATION_PLAYER_NAME), true, false) as AnimationPlayer
	if anim_player == null:
		return
	if not anim_player.has_animation(INTRO_ANIMATION_NAME):
		return
	anim_player.play(INTRO_ANIMATION_NAME)


func _swap_audio(new_stream: AudioStream) -> void:
	_kill_tween(_audio_tween)
	if new_stream == null:
		if _audio_player.playing:
			_audio_tween = create_tween()
			_audio_tween.tween_property(_audio_player, "volume_db", -40.0, AUDIO_CROSSFADE_TIME)
			_audio_tween.tween_callback(_audio_player.stop)
		return

	if _audio_player.stream == new_stream and _audio_player.playing:
		return

	_audio_tween = create_tween()
	if _audio_player.playing:
		_audio_tween.tween_property(_audio_player, "volume_db", -40.0, AUDIO_CROSSFADE_TIME * 0.5)
		_audio_tween.tween_callback(func():
			_audio_player.stop()
			_audio_player.stream = new_stream
			_audio_player.volume_db = -40.0
			_audio_player.play()
		)
	else:
		_audio_tween.tween_callback(func():
			_audio_player.stream = new_stream
			_audio_player.volume_db = -40.0
			_audio_player.play()
		)
	_audio_tween.tween_property(_audio_player, "volume_db", 0.0, AUDIO_CROSSFADE_TIME)


func _start_typewriter(text: String) -> void:
	_kill_tween(_typewriter_tween)
	if _story_text == null or text.is_empty():
		_typewriter_finished = true
		_schedule_hold()
		return
	_story_text.text = text
	_story_text.visible_ratio = 0.0
	var duration: float = max(0.05, text.length() / TYPEWRITER_CHARS_PER_SEC)
	_typewriter_tween = create_tween()
	_typewriter_tween.tween_property(_story_text, "visible_ratio", 1.0, duration)
	_typewriter_tween.tween_callback(_on_typewriter_done)


func _on_typewriter_done() -> void:
	_typewriter_finished = true
	_schedule_hold()


func _schedule_hold() -> void:
	if _current_beat == null: return
	_hold_timer.wait_time = max(0.05, _current_beat.hold_after_typewriter)
	_hold_timer.start()


func _handle_user_advance() -> void:
	if not _typewriter_finished:
		_kill_tween(_typewriter_tween)
		if _story_text != null:
			_story_text.visible_ratio = 1.0
		_typewriter_finished = true
		_schedule_hold()
		return
	_hold_timer.stop()
	_advance_beat()


func _finish() -> void:
	if _cinematic_finished:
		return
	_cinematic_finished = true
	_hold_timer.stop()
	_kill_tween(_typewriter_tween)
	_kill_tween(_stage_tween)

	_kill_tween(_global_tween)
	_global_tween = create_tween()
	_global_tween.set_parallel(true)
	_global_tween.tween_property(_fade_overlay, "modulate:a", 1.0, FINAL_FADE_OUT_TIME)
	if _audio_player.playing:
		_global_tween.tween_property(_audio_player, "volume_db", -40.0, FINAL_FADE_OUT_TIME)
	_global_tween.set_parallel(false)
	_global_tween.tween_callback(func(): finished.emit())


func _kill_tween(t: Tween) -> void:
	if t and t.is_valid():
		t.kill()
#endregion


#region ============================== Callbacks ==============================
func _on_skip_pressed() -> void:
	_finish()


func _on_finished() -> void:
	if not auto_start_game_on_finish:
		return
	Verbose.debug("Cinematic finished — starting solo game", Verbose.Category.TUTORIAL)
	GameManager.start_solo_game()
#endregion
