extends Control

# Proto scene to iterate on UIStoryIntro feel in isolation. Exposes buttons to
# replay the full sequence, or just one beat at a time. Disables the auto
# "start solo game" behavior so the cinematic loops without launching the game.

const _STORY_INTRO_SCENE: PackedScene = preload("res://04_UI/Cinematic/StoryIntro/ui_story_intro.tscn")
const _BEAT_PATHS: Array[String] = [
	"res://04_UI/Cinematic/StoryIntro/Beats/beat_01_crystal.tres",
	"res://04_UI/Cinematic/StoryIntro/Beats/beat_02_turtle.tres",
	"res://04_UI/Cinematic/StoryIntro/Beats/beat_03_tavern.tres",
]

@onready var _stage: Control = %Stage
@onready var _replay_full_button: Button = %ReplayFullButton
@onready var _replay_beat_1_button: Button = %ReplayBeat1Button
@onready var _replay_beat_2_button: Button = %ReplayBeat2Button
@onready var _replay_beat_3_button: Button = %ReplayBeat3Button

var _current_intro: UIStoryIntro


func _ready() -> void:
	_replay_full_button.pressed.connect(_on_replay_full)
	_replay_beat_1_button.pressed.connect(_on_replay_beat.bind(0))
	_replay_beat_2_button.pressed.connect(_on_replay_beat.bind(1))
	_replay_beat_3_button.pressed.connect(_on_replay_beat.bind(2))
	_play_full()


func _play_full() -> void:
	_clear_current()
	_current_intro = _STORY_INTRO_SCENE.instantiate() as UIStoryIntro
	_current_intro.auto_start_game_on_finish = false
	_stage.add_child(_current_intro)


func _play_single_beat(index: int) -> void:
	_clear_current()
	var path: String = _BEAT_PATHS[index]
	if not ResourceLoader.exists(path):
		Verbose.warn("Proto: beat resource missing " + path, Verbose.Category.TUTORIAL)
		return
	var beat: StoryBeat = load(path)
	_current_intro = _STORY_INTRO_SCENE.instantiate() as UIStoryIntro
	_current_intro.auto_start_game_on_finish = false
	_current_intro.beats = [beat]
	_stage.add_child(_current_intro)


func _clear_current() -> void:
	if _current_intro != null and is_instance_valid(_current_intro):
		_current_intro.queue_free()
	_current_intro = null


func _on_replay_full() -> void:
	_play_full()


func _on_replay_beat(index: int) -> void:
	_play_single_beat(index)
