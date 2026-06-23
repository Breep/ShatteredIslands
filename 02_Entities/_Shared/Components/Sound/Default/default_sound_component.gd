# Composant sonore par défaut : joue un son positionnel sur les évènements de
# cycle de vie de l'entité (mort, spawn, auto-attaque). Pendant audio du
# DefaultAnimationComponent. Un export laissé vide = aucun son joué pour cet évènement.

class_name DefaultSoundComponent
extends SoundComponent

#region ============================== Export ==============================
@export var _death_sound: AudioStream
@export var _death_sound_db: float = 0
@export var _auto_attack_sound: AudioStream
@export var _auto_attack_sound_db: float = 0
@export var _spawn_sound: AudioStream
@export var _spawn_sound_db: float = 0
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	super._ready()
	if _owner == null:
		return

	_owner.life_state_changed.connect(_on_owner_life_state_changed)
	_owner.spawn_completed.connect(_on_owner_spawn_completed)
	# auto_attack est instancié par Entity dans la même passe : déféré pour
	# garantir que _owner.auto_attack est résolu avant la connexion.
	_connect_auto_attack.call_deferred()
#endregion


#region ============================== Private functions ==============================
func _connect_auto_attack() -> void:
	if _owner == null or _owner.auto_attack == null:
		return
	_owner.auto_attack.attack_started.connect(_on_owner_auto_attack_started)


func _play(stream: AudioStream, db: float = 0.0) -> void:
	if stream == null:
		return
	AudioManager.play_audiostream_3d(stream, _owner.global_position, db)
#endregion


#region ============================== Callbacks ==============================
func _on_owner_life_state_changed(life_state: Entity.LifeState) -> void:
	if life_state == Entity.LifeState.DEAD:
		_play(_death_sound, _death_sound_db)


func _on_owner_spawn_completed() -> void:
	_play(_spawn_sound, _spawn_sound_db)


func _on_owner_auto_attack_started(_lock_seconds: float) -> void:
	_play(_auto_attack_sound, _auto_attack_sound_db)
#endregion
