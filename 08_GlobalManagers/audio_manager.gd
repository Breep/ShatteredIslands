extends Node

@onready var _sfx_stream_player:= AudioStreamPlayer.new()
var _sfx_lib: AudioLib = preload("res://23_Audio/Libraries/SFX_library.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Set audio stream player parameters
	_sfx_stream_player.max_polyphony = 10 # simultaneous maximum sounds TODO /!\ int number
	_sfx_stream_player.bus = "SFX"
	add_child(_sfx_stream_player)
	
	
	Events.card_bought.connect(func(_unused) -> void: _play_sound("card_bought"))
	
	
	
func _play_sound(sound_name: String) -> void:
	
	if sound_name == null:
		Verbose.error("Sound name played is null", Verbose.Category.AUDIO_MANAGER)
		return
	if _sfx_lib.audio_database.get(sound_name) == null:
		Verbose.error("Couldn't find " + sound_name + "in audiolib." ,Verbose.Category.AUDIO_MANAGER)
		return
		
	_sfx_stream_player.stream = _sfx_lib.audio_database.get(sound_name)
	_sfx_stream_player.play()
