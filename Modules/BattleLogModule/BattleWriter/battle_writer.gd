class_name BattleWriter
extends Node

# [CLIENT ONLY]

# ============================== External nodes ==============================

@export_group("External nodes")
@export var _fighting_area: FightingArea

# ============================== Private variables ==============================

var _battle_logs: Array[Dictionary]
var _last_log_index_sent: int = 0
var _is_recording: bool = false
var _normal_fight_duration: float
var _accelerated_fight_start_time: float
var _is_accelerated_fight: bool = false

# ============================== Node base functions ==============================

func _ready() -> void:
	if not multiplayer.is_server():
		queue_free()
		return # Only the server writes battle logs
	GlobalFightingManager.fighting_phase_state_changed.connect(_on_gfm_fighting_phase_state_changed)
	
	_fighting_area.action_done.connect(_on_fighting_area_action_done)
	_fighting_area.action_received.connect(_on_fighting_area_action_received)
	_fighting_area.projectile_spawned.connect(_on_fighting_area_projectile_spawned)
	_fighting_area.entity_spawned.connect(_on_fighting_area_entity_spawned)
	_fighting_area.projectile_target_hit.connect(_on_fighting_area_projectile_target_hit)


func _input(event: InputEvent) -> void:
	# Détecte Alt + F12
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F12 and event.alt_pressed:
			_save_logs_to_file()


# ============================== Public functions ==============================

# Should return the new logs (current logs - last logs (how to do so ?))
func get_current_logs() -> Array[Dictionary]:
	var new_logs: Array[Dictionary] = _battle_logs.slice(_last_log_index_sent)
	_last_log_index_sent = _battle_logs.size()
	return new_logs


func get_all_logs() -> Array[Dictionary]:
	return _battle_logs

# ============================== Private functions ==============================
func _create_base_entry() -> Dictionary:
	var manager = _fighting_area.fighting_manager
	var tick = manager.current_tick
	return {
		"tick": tick,                         # Précision pour le déterminisme
		"time": snapped(tick / 60.0, 0.001),  # Lisibilité float (basé sur 60 FPS)
	}

func _save_logs_to_file() -> void:
	Verbose.debug("Saving battle logs to disk", Verbose.Category.BATTLE_WRITER)
	if _battle_logs.is_empty():
		Verbose.warn("Tentative d'exportation de logs vides.", Verbose.Category.BATTLE_WRITER)
		return

	# Création d'un nom de fichier unique avec horodatage
	var datetime = Time.get_datetime_dict_from_system()
	var file_name = "battle_log_%d-%02d-%02d_%02d-%02d-%02d.json" % [
		datetime.year, datetime.month, datetime.day,
		datetime.hour, datetime.minute, datetime.second
	]
	var path = "user://" + file_name # Enregistre dans l'AppData du projet

	# Conversion des logs en chaîne JSON formatée (avec des tabulations pour la lisibilité)
	var json_string = JSON.stringify(_battle_logs, "\t")
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("Logs de bataille enregistrés avec succès dans : ", ProjectSettings.globalize_path(path))
	else:
		Verbose.error("Impossible de créer le fichier de log à l'emplacement : " + path, Verbose.Category.BATTLE_WRITER)


#region logs
func _log_action_done(source: Entity, target: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool) -> void:
	if not is_instance_valid(source):
		Verbose.warn("_log_action_done() -> source invalid", Verbose.Category.BATTLE_WRITER)
		return
	
	if not is_instance_valid(target):
		Verbose.warn("_log_action_done() -> target invalid", Verbose.Category.BATTLE_WRITER)
		return
	
	var entry = _create_base_entry()
	entry.merge({
		"type": "action_done",
		"action_type": Utils.ActionType.keys()[action_type],
		"id": action_id,
		"value": value,
		"critical": is_critical,
		"source": source.uid,
		"target": target.uid
	})
	
	_append_log(entry)


func _log_action_received(receiver: Entity, source: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool) -> void:
	Verbose.trace("_log_interaction_received() | " + str(receiver) + " | " + str(source), Verbose.Category.BATTLE_WRITER)
	
	if not is_instance_valid(receiver):
		Verbose.warn("_log_action_done() -> receiver invalid", Verbose.Category.BATTLE_WRITER)
		return
	
	var entry = _create_base_entry()
	entry.merge({
		"type": "action_received",
		"action_type": Utils.ActionType.keys()[action_type],
		"id": action_id,
		"value": value,
		"critical": is_critical,
		"receiver": receiver.uid,
		"source": source.uid if source != null else -1,
	})
	
	_append_log(entry)


func _log_projectile_spawned(source: Entity, target: Entity, projectile_type: Projectile.Type, gpos: Vector3, projectile_uid: int) -> void:
	if not is_instance_valid(source) or not is_instance_valid(target): return
	var entry = _create_base_entry()
	entry.merge({
		"type": "projectile_spawned",
		"source": source.uid,
		"target": target.uid,
		"projectile_uid": projectile_uid,
		"projectile_type": Projectile.Type.keys()[projectile_type],
		"position": gpos
	})
	_append_log(entry)


func _log_entity_spawned(entity: Entity, entity_type: Entity.EntityType, gpos: Vector3) -> void:
	if not is_instance_valid(entity): return
	var entry = _create_base_entry()
	entry.merge({
		"type": "entity_spawned",
		"uid": entity.uid,
		"entity_type": Entity.EntityType.keys()[entity_type],
		"position": gpos
	})
	_append_log(entry)


func _log_projectile_target_hit(target: Entity, gpos: Vector3, projectile_uid: int) -> void:
	if not is_instance_valid(target): return
	var entry = _create_base_entry()
	entry.merge({
		"type": "projectile_target_hit",
		"target": target.uid,
		"projectile_uid": projectile_uid,
		"position": gpos
	})
	_append_log(entry)
#endregion


func _append_log(data: Dictionary) -> void:
	if not _is_recording: return
	_battle_logs.append(data)

func _get_time() -> float:
	if _is_accelerated_fight:
		return _normal_fight_duration + ((Time.get_ticks_msec() as float) / 1000.0 - _accelerated_fight_start_time)
	else:
		return (Time.get_ticks_msec() as float) / 1000.0 - GlobalFightingManager.fight_start_time

# ============================== Callbacks ==============================

func _on_gfm_fighting_phase_state_changed(state: GlobalFightingManager.FightingPhaseState) -> void:
	match state:
		GlobalFightingManager.FightingPhaseState.NORMAL:
			_is_recording = true
			_is_accelerated_fight = false
		GlobalFightingManager.FightingPhaseState.ACCELERATED:
			_normal_fight_duration = _get_time()
			_accelerated_fight_start_time = (Time.get_ticks_msec() as float) / 1000.0
			_is_accelerated_fight = true
		GlobalFightingManager.FightingPhaseState.FINISHED:
			_is_recording = false
			_save_logs_to_file()
			_battle_logs.clear()


func _on_fighting_area_projectile_spawned(source: Entity, target: Entity, projectile_type: Projectile.Type, projectile: Projectile, gpos: Vector3) -> void:
	_log_projectile_spawned(source, target, projectile_type, gpos, projectile.uid)


func _on_fighting_area_entity_spawned(entity: Entity, entity_type: Entity.EntityType, gpos: Vector3) -> void:
	_log_entity_spawned(entity, entity_type, gpos)


func _on_fighting_area_action_received(receiver: Entity, source: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool) -> void:
	_log_action_received(receiver, source, action_type, action_id, value, is_critical)


func _on_fighting_area_action_done(source: Entity, target: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool) -> void:
	_log_action_done(source, target, action_type, action_id, value, is_critical)


func _on_fighting_area_projectile_target_hit(target: Entity, gpos: Vector3, projectile_uid: int) -> void:
	_log_projectile_target_hit(target, gpos, projectile_uid)
