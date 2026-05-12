extends Node

@onready var _sfx_stream_player:= AudioStreamPlayer.new()
var _sfx_lib: AudioLib = preload("res://23_Audio/Libraries/SFX_library.tres")

const _PITCH_VARIATION: float = 0.05

var _SOUND_MAP: Array = [
	# [signal, clé dans SFX_library.tres]
	[Events.card_bought, "card_bought"],
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Set audio stream player parameters
	_sfx_stream_player.max_polyphony = 10 # simultaneous maximum sounds TODO /!\ int number
	_sfx_stream_player.bus = "SFX"
	add_child(_sfx_stream_player)

	for entry in _SOUND_MAP:
		entry[0].connect(func(_unused) -> void: _play_sound(entry[1]))
	
	
	
func _play_sound(sound_name: String) -> void:

	if sound_name == null:
		Verbose.error("Sound name played is null", Verbose.Category.AUDIO_MANAGER)
		return
	if _sfx_lib.audio_database.get(sound_name) == null:
		Verbose.error("Couldn't find " + sound_name + " in audiolib.", Verbose.Category.AUDIO_MANAGER)
		return

	_sfx_stream_player.stream = _sfx_lib.audio_database.get(sound_name)
	_sfx_stream_player.pitch_scale = randf_range(1.0 - _PITCH_VARIATION, 1.0 + _PITCH_VARIATION)
	_sfx_stream_player.play()


func set_bus_volume(bus_name: String, linear: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		Verbose.error("Audio bus not found: " + bus_name, Verbose.Category.AUDIO_MANAGER)
		return
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear))


func play_3d(sound_name: String, position: Vector3, pitch: float = 1.0) -> void:
	if _sfx_lib.audio_database.get(sound_name) == null:
		Verbose.error("Couldn't find " + sound_name + " in audiolib.", Verbose.Category.AUDIO_MANAGER)
		return
	var player := AudioStreamPlayer3D.new()
	player.stream = _sfx_lib.audio_database.get(sound_name)
	player.bus = "SFX"
	player.pitch_scale = pitch * randf_range(1.0 - _PITCH_VARIATION, 1.0 + _PITCH_VARIATION)
	add_child(player)
	player.global_position = position
	player.finished.connect(player.queue_free)
	player.play()
