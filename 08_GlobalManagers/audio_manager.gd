# Point d'entrée unique pour tout l'audio du jeu : SFX flat (2D),
# SFX positionnels (3D) et BGM avec crossfade.
extends Node

#region ============================== Constants ==============================
const _PITCH_VARIATION: float = 0.05
const _BGM_SILENT_DB: float = -80.0
const _BGM_DEFAULT_FADE: float = 1.0
#endregion

#region ============================== Private vars ==============================
@onready var _sfx_stream_player := AudioStreamPlayer.new()
var _sfx_lib: AudioLib = preload("res://23_Audio/Libraries/SFX_library.tres")
var _bgm_lib: AudioLib = preload("res://23_Audio/Libraries/BGM_library.tres")

var _bgm_player_a: AudioStreamPlayer
var _bgm_player_b: AudioStreamPlayer
var _bgm_active_player: AudioStreamPlayer
var _bgm_tween: Tween
#endregion

#region ============================== Signal maps ==============================
var _SOUND_MAP: Array = [
	# [signal, clé dans SFX_library.tres]
	[Events.card_bought, "card_bought"],
]

var _BGM_MAP: Array = [
	# [signal, clé dans BGM_library.tres]
	[Events.card_shop_init, "BGM_01"],
]
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	_sfx_stream_player.max_polyphony = 10
	_sfx_stream_player.bus = "SFX"
	add_child(_sfx_stream_player)

	_bgm_player_a = AudioStreamPlayer.new()
	_bgm_player_a.bus = "Music"
	_bgm_player_a.volume_db = _BGM_SILENT_DB
	add_child(_bgm_player_a)

	_bgm_player_b = AudioStreamPlayer.new()
	_bgm_player_b.bus = "Music"
	_bgm_player_b.volume_db = _BGM_SILENT_DB
	add_child(_bgm_player_b)

	for entry in _SOUND_MAP:
		var key: String = entry[1]
		entry[0].connect((func(): _play_sound(key)).unbind(_signal_arg_count(entry[0])))

	for entry in _BGM_MAP:
		var key: String = entry[1]
		entry[0].connect((func(): play_bgm(key)).unbind(_signal_arg_count(entry[0])))
#endregion

#region ============================== Public functions ==============================
func play_sfx(sound_name: String) -> void:
	_play_sound(sound_name)


func play_bgm(sound_name: String, fade_duration: float = _BGM_DEFAULT_FADE) -> void:
	if _bgm_lib.audio_database.get(sound_name) == null:
		Verbose.error("Couldn't find " + sound_name + " in BGM lib.", Verbose.Category.AUDIO_MANAGER)
		return
	if _bgm_active_player != null and _bgm_active_player.stream == _bgm_lib.audio_database.get(sound_name):
		return

	var incoming := _bgm_inactive_player()
	incoming.stream = _bgm_lib.audio_database.get(sound_name)
	incoming.volume_db = _BGM_SILENT_DB
	incoming.play()

	if _bgm_tween:
		_bgm_tween.kill()
	_bgm_tween = create_tween().set_parallel(true)
	_bgm_tween.tween_property(incoming, "volume_db", 0.0, fade_duration)
	if _bgm_active_player != null:
		var outgoing := _bgm_active_player
		_bgm_tween.tween_property(outgoing, "volume_db", _BGM_SILENT_DB, fade_duration)
		_bgm_tween.tween_callback(outgoing.stop).set_delay(fade_duration)

	_bgm_active_player = incoming


func stop_bgm(fade_duration: float = _BGM_DEFAULT_FADE) -> void:
	if _bgm_active_player == null:
		return
	if _bgm_tween:
		_bgm_tween.kill()
	var outgoing := _bgm_active_player
	_bgm_active_player = null
	_bgm_tween = create_tween()
	_bgm_tween.tween_property(outgoing, "volume_db", _BGM_SILENT_DB, fade_duration)
	_bgm_tween.tween_callback(outgoing.stop).set_delay(fade_duration)


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
#endregion

#region ============================== Private functions ==============================
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


func _bgm_inactive_player() -> AudioStreamPlayer:
	return _bgm_player_b if _bgm_active_player == _bgm_player_a else _bgm_player_a


func _signal_arg_count(sig: Signal) -> int:
	for method in sig.get_object().get_signal_list():
		if method.name == sig.get_name():
			return method.args.size()
	return 0
#endregion
