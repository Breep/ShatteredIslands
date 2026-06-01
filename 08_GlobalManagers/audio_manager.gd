# Point d'entrée unique pour tout l'audio du jeu : SFX flat (2D),
# SFX positionnels (3D) et BGM avec crossfade.
extends Node

#region ============================== Constants ==============================
const _PITCH_VARIATION: float = 0.05
const _BGM_SILENT_DB: float = -80.0
const _BGM_DEFAULT_FADE: float = 1.0
const _GOLD_PER_SOUND: int = 10
const _GOLD_SOUNDS_MAX: int = 8
const _GOLD_SOUND_SPACING: float = 0.08

# Volumes par défaut appliqués au démarrage (linéaire 0.0 → 1.0).
# Forcés en code car l'éditeur Godot resauve default_bus_layout.tres tout seul
# quand on touche au panel Audio, écrasant nos valeurs.
const _DEFAULT_SFX_VOLUME: float = 1.0
const _DEFAULT_UI_VOLUME: float = 0.8
const _DEFAULT_BGM_VOLUME: float = 0.15
#endregion

#region ============================== Private vars ==============================
@onready var _sfx_stream_player := AudioStreamPlayer.new()
@onready var _ui_stream_player := AudioStreamPlayer.new()
@onready var _sfx_3d_template: AudioStreamPlayer3D = %SFX3DTemplate
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
	[Events.hero_locked, "hero_locked"],
	[Events.ui_family_portrait_requested, "ui_family_portrait_requested"],
	[Events.tavern_continue_pressed, "start_fight"],
	[Events.card_drawn, "card_drawn"],
	[Events.insufficient_gold, "insufficient_gold"],
	[Events.ui_window_opened, "window_appear"],
]

var _BGM_MAP: Array = [
	# [signal, clé dans BGM_library.tres]
]
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	_sfx_stream_player.max_polyphony = 10
	_sfx_stream_player.bus = "SFX"
	add_child(_sfx_stream_player)

	_ui_stream_player.max_polyphony = 10
	_ui_stream_player.bus = "UI"
	add_child(_ui_stream_player)

	# Forcer les volumes par défaut — voir _DEFAULT_*_VOLUME pour la raison.
	set_bus_volume("SFX", _DEFAULT_SFX_VOLUME)
	set_bus_volume("UI", _DEFAULT_UI_VOLUME)
	set_bus_volume("Music", _DEFAULT_BGM_VOLUME)

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
		var sfx_callable := func(): _play_sound(key)
		var sfx_count := _signal_arg_count(entry[0])
		entry[0].connect(sfx_callable.unbind(sfx_count) if sfx_count > 0 else sfx_callable)

	Events.gold_gained.connect(_on_gold_gained)

	for entry in _BGM_MAP:
		var key: String = entry[1]
		var bgm_callable := func(): play_bgm(key)
		var bgm_count := _signal_arg_count(entry[0])
		entry[0].connect(bgm_callable.unbind(bgm_count) if bgm_count > 0 else bgm_callable)
#endregion

#region ============================== Public functions ==============================
# Joue un son flat sur le bus SFX (gameplay : combat, gold, projectiles...).
func play_sfx(sound_name: String, volume_db: float = 0.0) -> void:
	_play_on_player(_sfx_stream_player, sound_name, volume_db)


# Joue un son flat sur le bus UI (hover/click boutons, ouverture de fenêtre...).
# Le bus UI envoie vers SFX, donc le slider SFX des settings s'applique aussi —
# mais un slider UI dédié permet de baisser uniquement les sons UI.
func play_ui(sound_name: String, volume_db: float = 0.0) -> void:
	_play_on_player(_ui_stream_player, sound_name, volume_db)


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
	var player := _sfx_3d_template.duplicate() as AudioStreamPlayer3D
	player.stream = _sfx_lib.audio_database.get(sound_name)
	player.pitch_scale = pitch * randf_range(1.0 - _PITCH_VARIATION, 1.0 + _PITCH_VARIATION)
	add_child(player)
	player.global_position = position
	player.finished.connect(player.queue_free)
	player.play()
#endregion

#region ============================== Private functions ==============================
func _play_sound(sound_name: String) -> void:
	_play_on_player(_sfx_stream_player, sound_name, 0.0)


func _play_on_player(template_player: AudioStreamPlayer, sound_name: String, volume_db: float) -> void:
	if sound_name == null or sound_name.is_empty():
		return
		
	var audio_stream = _sfx_lib.audio_database.get(sound_name)
	if audio_stream == null:
		Verbose.error("Couldn't find " + sound_name + " in audiolib.", Verbose.Category.AUDIO_MANAGER)
		return
		
	# On crée une copie du player (qui a déjà le bon bus assigné)
	var player := template_player.duplicate() as AudioStreamPlayer
	player.stream = audio_stream
	player.pitch_scale = randf_range(1.0 - _PITCH_VARIATION, 1.0 + _PITCH_VARIATION)
	player.volume_db = volume_db
	
	add_child(player)
	
	# On détruit le nœud quand le son est terminé pour éviter les fuites de mémoire
	player.finished.connect(player.queue_free)
	
	player.play()


func _bgm_inactive_player() -> AudioStreamPlayer:
	return _bgm_player_b if _bgm_active_player == _bgm_player_a else _bgm_player_a


# Plays gold_gained 1 fois par tranche de _GOLD_PER_SOUND, capé à _GOLD_SOUNDS_MAX,
# espacé de _GOLD_SOUND_SPACING. Un gain < 10 joue quand même 1 son.
func _on_gold_gained(amount: int) -> void:
	if amount <= 0:
		return
	var count: int = clampi(maxi(1, int(amount / float(_GOLD_PER_SOUND))), 1, _GOLD_SOUNDS_MAX)
	for i in count:
		if i == 0:
			_play_sound("gold_gained")
		else:
			get_tree().create_timer(i * _GOLD_SOUND_SPACING).timeout.connect(func(): _play_sound("gold_gained"))


func _signal_arg_count(sig: Signal) -> int:
	for method in sig.get_object().get_signal_list():
		if method.name == sig.get_name():
			return method.args.size()
	return 0
#endregion
