class_name UIOracle
extends Control

# ============================== Local Nodes ==============================

@export_group("Skills")
@export var _skill1A: UISkillPanel
@export var _skill1B: UISkillPanel
@export var _skill2A: UISkillPanel
@export var _skill2B: UISkillPanel
@export var _skill3A: UISkillPanel
@export var _skill3B: UISkillPanel

@export_group("XP")
@export var _player_level_label: Label
@export var _xp_bar: ProgressBar
@export var _xp_label: Label

# ============================== Private variables ==============================

var _local_player: Player
var _is_active: bool
var _is_locked: bool

# ============================== Node base functions ==============================

func _ready() -> void:
	if multiplayer.is_server() and GameManager.game_type != GameManager.GameType.SOLO:
		return
	_local_player = PlayerManager.get_local_player()
	
	_local_player.death.connect(_on_local_player_death)
	_local_player.xp_changed.connect(_on_local_player_xp_changed)
	var max_xp: int = GameManager.game_rules.xp_per_levels[_local_player.lvl]
	_update_xp_bar(_local_player.xp, max_xp)

# ============================== Public functions ==============================

func set_active() -> void:
	if _is_active or _is_locked: return
	_is_active = true
	show()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	hide()

# ============================== Private functions ==============================

func _update_xp_bar(value: int, max_value: int) -> void:
	_xp_bar.value = value
	_xp_bar.max_value = max_value
	_xp_label.text = str(value) + "/" + str(max_value)

# ============================== Callbacks ==============================

func _on_buy_xp_button_pressed() -> void:
	pass


func _on_close_button_pressed() -> void:
	hide()


func _on_local_player_death(_player: Player) -> void:
	print("Oracle: lock oracle for ", _local_player.name)
	set_inactive()
	_is_locked = true


func _on_local_player_xp_changed(player_ref: Player, xp: int) -> void:
	var max_xp: int = GameManager.game_rules.xp_per_levels[player_ref.lvl]
	_update_xp_bar(xp, max_xp)
