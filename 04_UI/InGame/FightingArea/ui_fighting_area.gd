class_name UIFightingArea
extends Control

# ============================== Constants ==============================

# Multiplicateurs de vitesse de combat (ticks logiques par frame physique),
# alignés par index sur _speed_buttons (boutons x1 / x2 / x4 / x8).
const _TICK_MULTIPLIERS: Array[int] = [1, 2, 4, 8]

# ============================== Local nodes ==============================

@onready var _ui_countdown: UICountdown = %Countdown
@onready var _ui_dps_meter: UIDPSMeter = %UiDpsMeter
@onready var _advance_button: Button = %AdvanceButton
@onready var _ui_roaster_list: UIRoasterList = $UiRoasterList

@onready var _intro_timer: Timer = %IntroTimer

@onready var _speed_buttons: Array[Button] = [%SpeedX1, %SpeedX2, %SpeedX4, %SpeedX8]

# ============================== Private variables ==============================

var _is_active: bool = false
var _fighting_area: FightingArea = null
# Groupe radio des boutons de vitesse : un seul actif à la fois.
var _speed_button_group: ButtonGroup

# ============================== Node base functions ==============================

func _ready() -> void:
	GlobalFightingManager.fighting_phase_state_changed.connect(_on_gfm_fighting_phase_state_changed)
	_advance_button.pressed.connect(_on_advance_button_pressed)
	_ui_roaster_list.placement_changed.connect(_on_roaster_placement_changed)
	_setup_speed_buttons()
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
	_reset_speed()
	_intro_timer.start()
	_advance_button.hide()
	_ui_dps_meter.hide()
	show()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	_reset_speed()
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


# Met les boutons de vitesse en mode radio (un seul actif) et branche chacun sur
# son multiplicateur de ticks.
func _setup_speed_buttons() -> void:
	_speed_button_group = ButtonGroup.new()
	for i: int in _speed_buttons.size():
		var btn: Button = _speed_buttons[i]
		btn.toggle_mode = true
		btn.button_group = _speed_button_group
		btn.pressed.connect(_on_speed_button_pressed.bind(_TICK_MULTIPLIERS[i]))


# Revient à x1 : vitesse de combat normale + bouton x1 sélectionné. Setter de
# button_pressed n'émet pas `pressed`, donc pas de rappel récursif.
func _reset_speed() -> void:
	if not _speed_buttons.is_empty():
		_speed_buttons[0].button_pressed = true
	_apply_tick_multiplier(1)


# Applique la vitesse au GlobalFightingManager : il pilote l'horloge de phase
# partagée et la propage aux FMs (phase + combat synchrones).
func _apply_tick_multiplier(multiplier: int) -> void:
	GlobalFightingManager.set_speed_multiplier(multiplier)

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
			_reset_speed()
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


func _on_speed_button_pressed(multiplier: int) -> void:
	_apply_tick_multiplier(multiplier)
