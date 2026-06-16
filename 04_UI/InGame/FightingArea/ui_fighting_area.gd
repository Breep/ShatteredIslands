class_name UIFightingArea
extends Control

# ============================== Local nodes ==============================

@onready var _ui_countdown: UICountdown = %Countdown
@onready var _ui_dps_meter: UIDPSMeter = %UiDpsMeter
@onready var _advance_button: Button = %AdvanceButton
@onready var _ui_roaster_list: UIRoasterList = $UiRoasterList

@onready var _intro_timer: Timer = %IntroTimer

# ============================== Private variables ==============================

var _is_active: bool = false
var _fighting_area: FightingArea = null

# ============================== Node base functions ==============================

func _ready() -> void:
	GlobalFightingManager.fighting_phase_state_changed.connect(_on_gfm_fighting_phase_state_changed)
	_advance_button.pressed.connect(_on_advance_button_pressed)
	_ui_roaster_list.placement_changed.connect(_on_roaster_placement_changed)
	_advance_button.hide()
	_ui_roaster_list.hide()
	hide()

# ============================== Public functions ==============================

func update_content(fighting_area: FightingArea) -> void:
	_fighting_area = fighting_area
	var heroes: Array[Entity] = fighting_area.get_fighting_heroes()
	_ui_dps_meter.set_heroes(heroes)
	_ui_roaster_list.setup(_local_roaster(), fighting_area)
	_ui_roaster_list.hide()


func set_active() -> void:
	if _is_active: return
	_is_active = true
	_intro_timer.start()
	_advance_button.hide()
	_ui_dps_meter.hide()
	show()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	hide()

# ============================== Private functions ==============================

# Roaster du joueur local : source des unités à placer. null hors run (proto).
func _local_roaster() -> Roaster:
	var party: Party = GameManager.run_context.party if GameManager.run_context != null else null
	if party == null:
		return null
	var slot: PlayerState.Slot = PlayerState.Slot.PLAYER_1
	var local_player: Player = PlayerManager.get_local_player()
	if local_player != null and local_player.state != null:
		slot = local_player.state.slot
	return party.get_roaster(slot)


# READY désactivé tant qu'il reste des unités non placées (combat non lançable).
func _refresh_ready_gate() -> void:
	_advance_button.disabled = _ui_roaster_list.has_unplaced()

# ============================== Callbacks ==============================

func _on_gfm_fighting_phase_state_changed(fighting_phase_state: GlobalFightingManager.FightingPhaseState) -> void:
	match fighting_phase_state:
		GlobalFightingManager.FightingPhaseState.POSITIONING:
			_advance_button.text = "READY"
			_refresh_ready_gate()
		GlobalFightingManager.FightingPhaseState.COUNTDOWN:
			_ui_dps_meter.show()
			_advance_button.hide()
			_ui_roaster_list.close()
			_ui_countdown.start(int(GameManager.game_rules.duration_fighting_countdown), "FIGHT")
			Events.combat_started.emit()
		GlobalFightingManager.FightingPhaseState.CELEBRATION:
			_advance_button.text = "NEXT"
			_advance_button.disabled = false
			_advance_button.show()
			_ui_roaster_list.close()
		_:
			_advance_button.hide()
			_ui_roaster_list.close()


func _on_roaster_placement_changed() -> void:
	if _ui_roaster_list.visible:
		_refresh_ready_gate()
	if not _ui_roaster_list.has_unplaced():
		_ui_roaster_list.close()


func _on_advance_button_pressed() -> void:
	if _fighting_area == null or _fighting_area.fighting_manager == null:
		Verbose.warn("UIFightingArea.AdvanceButton pressed but no FightingArea bound", Verbose.Category.FIGHTING_AREA)
		return
	# Garde-fou : combat non lançable tant qu'une unité n'est pas placée.
	if _ui_roaster_list.has_unplaced():
		Verbose.debug("UIFightingArea: lancement bloqué, unités non placées", Verbose.Category.FIGHTING_AREA)
		return
	_advance_button.hide()
	_fighting_area.fighting_manager.request_phase_advance()


func _on_intro_timer_timeout() -> void:
	if _ui_roaster_list.has_unplaced():
		_ui_roaster_list.open()
		Events.unit_placement_started.emit()
	_advance_button.show()
