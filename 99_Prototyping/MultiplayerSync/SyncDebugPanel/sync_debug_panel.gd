extends Control

# ============================== Description ==============================
#
# SyncDebugPanel - Live debug panel for multiplayer sync prototyping
# Shows phase state, log counts, configurable sync settings,
# and end-of-simulation entity state + log comparison

# ============================== Signals ==============================

signal sync_period_changed(new_period: float)
signal client_delay_changed(new_delay_ms: int)
signal start_fight_requested()

# ============================== Export variables ==============================

@export_group("External nodes")
@export var _battle_writer: BattleWriter
@export var _battle_reader: BattleReader
@export var _entity_manager: EntityManager

# ============================== Onready nodes ==============================

@onready var _phase_label: Label = %PhaseLabel
@onready var _log_count_label: Label = %LogCountLabel
@onready var _role_label: Label = %RoleLabel
@onready var _connection_status_label: RichTextLabel = %ConnectionStatusLabel
@onready var _start_fight_button: Button = %StartFightButton

@onready var _sync_period_slider: HSlider = %SyncPeriodSlider
@onready var _sync_period_value_label: Label = %SyncPeriodValueLabel

@onready var _client_delay_slider: HSlider = %ClientDelaySlider
@onready var _client_delay_value_label: Label = %ClientDelayValueLabel

@onready var _comparison_result: RichTextLabel = %ComparisonResult

# ============================== Node base functions ==============================

func update_role() -> void:
	_role_label.text = "SERVER" if multiplayer.is_server() else "CLIENT"
	_start_fight_button.visible = multiplayer.is_server()
	_start_fight_button.disabled = true # Enabled once client connects

# ============================== Node base functions ==============================

func _ready() -> void:
	GlobalFightingManager.fighting_phase_state_changed.connect(_on_phase_state_changed)
	GlobalFightingManager.all_fights_are_over.connect(_on_all_fights_over)

	_sync_period_slider.value_changed.connect(_on_sync_period_slider_changed)
	_client_delay_slider.value_changed.connect(_on_client_delay_slider_changed)
	_start_fight_button.pressed.connect(_on_start_fight_button_pressed)

	_role_label.text = "SERVER" if multiplayer.is_server() else "CLIENT"
	_comparison_result.text = ""
	_connection_status_label.text = "Waiting..."

	# Server shows the button, client hides it
	_start_fight_button.visible = multiplayer.is_server()
	_start_fight_button.disabled = true # Enabled once client connects

	# Set initial slider label values
	_sync_period_value_label.text = str(_sync_period_slider.value).pad_decimals(1) + "s"
	_client_delay_value_label.text = str(int(_client_delay_slider.value)) + "ms"


func _process(_delta: float) -> void:
	_update_log_count()


# ============================== Private functions ==============================

func _update_log_count() -> void:
	if multiplayer.is_server():
		if _battle_writer != null:
			_log_count_label.text = "Logs written: " + str(_battle_writer.get_all_logs().size())
	else:
		if _battle_reader != null:
			_log_count_label.text = "Logs received: " + str(_battle_reader.get_all_logs().size())


func _on_phase_state_changed(new_state: GlobalFightingManager.FightingPhaseState) -> void:
	_phase_label.text = "Phase: " + GlobalFightingManager.FightingPhaseState.keys()[new_state]


func _on_all_fights_over() -> void:
	if multiplayer.is_server():
		_run_server_comparison()
	# Client comparison is triggered by receiving server data via RPC


func _run_server_comparison() -> void:
	# Capture server final entity states
	var final_states: Array[Dictionary] = _capture_entity_states()
	var final_logs: Array[Dictionary] = _battle_writer.get_all_logs() if _battle_writer != null else []

	# Display on server side
	_display_server_summary(final_states, final_logs)

	# Send to client for comparison
	_send_final_data_to_client.rpc(final_states, final_logs)


func _capture_entity_states() -> Array[Dictionary]:
	var states: Array[Dictionary] = []
	if _entity_manager == null:
		return states

	for entity_id: int in _entity_manager.entities.keys():
		var entity: Entity = _entity_manager.entities[entity_id]
		if entity == null or not is_instance_valid(entity):
			continue
		var state: Dictionary = {
			BattleLog.Main.SOURCE: entity.uid, # Reuse enum as key for entity id
			BattleLog.Main.ACTION_ID: entity.entity_name, # Reuse enum as key for name
			BattleLog.Main.VALUE: entity.stats.health, # Reuse enum as key for HP
			BattleLog.Main.CRITICAL: entity.is_dead(), # Reuse enum as key for dead status
		}
		states.append(state)
	return states


func _display_server_summary(final_states: Array[Dictionary], final_logs: Array[Dictionary]) -> void:
	var text: String = "[b]=== SERVER SUMMARY ===[/b]\n"
	text += "Total logs: " + str(final_logs.size()) + "\n"
	text += "[b]Entity States:[/b]\n"
	for state: Dictionary in final_states:
		var dead_str: String = " [color=red]DEAD[/color]" if state[BattleLog.Main.CRITICAL] else " [color=green]ALIVE[/color]"
		text += "  " + str(state[BattleLog.Main.ACTION_ID]) + " (uid:" + str(state[BattleLog.Main.SOURCE]) + ")"
		text += " | HP: " + str(state[BattleLog.Main.VALUE]).pad_decimals(0) + dead_str + "\n"
	_comparison_result.text = text


func _display_client_comparison(server_states: Array[Dictionary], server_logs: Array[Dictionary]) -> void:
	var client_states: Array[Dictionary] = _capture_entity_states()
	var client_logs: Array[Dictionary] = _battle_reader.get_all_logs() if _battle_reader != null else []

	var text: String = "[b]=== SYNC COMPARISON ===[/b]\n\n"

	# --- Log comparison ---
	text += "[b]Logs:[/b]  Server=" + str(server_logs.size()) + "  Client=" + str(client_logs.size())
	if server_logs.size() == client_logs.size():
		text += "  [color=green]✓ MATCH[/color]\n"
	else:
		text += "  [color=red]✗ MISMATCH (delta=" + str(server_logs.size() - client_logs.size()) + ")[/color]\n"

	# --- Entity state comparison ---
	text += "\n[b]Entity States:[/b]\n"
	for server_state: Dictionary in server_states:
		var s_uid: int = server_state[BattleLog.Main.SOURCE]
		var s_name: String = server_state[BattleLog.Main.ACTION_ID]
		var s_hp: float = server_state[BattleLog.Main.VALUE]
		var s_dead: bool = server_state[BattleLog.Main.CRITICAL]

		# Find matching client entity
		var client_state: Dictionary = {}
		for cs: Dictionary in client_states:
			if cs[BattleLog.Main.SOURCE] == s_uid:
				client_state = cs
				break

		text += "  [b]" + s_name + "[/b] (uid:" + str(s_uid) + ")\n"
		if client_state.is_empty():
			text += "    [color=red]NOT FOUND ON CLIENT[/color]\n"
			continue

		var c_hp: float = client_state[BattleLog.Main.VALUE]
		var c_dead: bool = client_state[BattleLog.Main.CRITICAL]

		# HP comparison
		var hp_diff: float = absf(s_hp - c_hp)
		if hp_diff < 0.01:
			text += "    HP: " + str(s_hp).pad_decimals(0) + " [color=green]✓[/color]\n"
		else:
			text += "    HP: Server=" + str(s_hp).pad_decimals(0) + " Client=" + str(c_hp).pad_decimals(0)
			text += " [color=red]✗ Δ=" + str(hp_diff).pad_decimals(1) + "[/color]\n"

		# Dead status comparison
		if s_dead == c_dead:
			var status: String = "DEAD" if s_dead else "ALIVE"
			text += "    Status: " + status + " [color=green]✓[/color]\n"
		else:
			text += "    Status: Server=" + ("DEAD" if s_dead else "ALIVE")
			text += " Client=" + ("DEAD" if c_dead else "ALIVE")
			text += " [color=red]✗ MISMATCH[/color]\n"

	_comparison_result.text = text

# ============================== Public functions ==============================

func set_client_connected(connected: bool) -> void:
	if connected:
		_connection_status_label.text = "[color=green]Connected[/color]"
		_start_fight_button.disabled = false
	else:
		_connection_status_label.text = "[color=red]Disconnected[/color]"
		_start_fight_button.disabled = true

# ============================== Slider callbacks ==============================

func _on_sync_period_slider_changed(value: float) -> void:
	_sync_period_value_label.text = str(value).pad_decimals(1) + "s"
	sync_period_changed.emit(value)


func _on_client_delay_slider_changed(value: float) -> void:
	_client_delay_value_label.text = str(int(value)) + "ms"
	client_delay_changed.emit(int(value))


func _on_start_fight_button_pressed() -> void:
	_start_fight_button.disabled = true
	_start_fight_button.text = "Fighting..."
	start_fight_requested.emit()

# ============================== RPC ==============================

@rpc("authority", "call_remote", "reliable")
func _send_final_data_to_client(server_states: Array[Dictionary], server_logs: Array[Dictionary]) -> void:
	_display_client_comparison(server_states, server_logs)
