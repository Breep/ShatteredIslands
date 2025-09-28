class_name UIOracle
extends Control

# ============================== Local Nodes ==============================

@onready var _skill1APanel: UISkillPanel = %UiSkillPanel_1A
@onready var _skill1BPanel: UISkillPanel = %UiSkillPanel_1B
@onready var _skill2APanel: UISkillPanel = %UiSkillPanel_2A
@onready var _skill2BPanel: UISkillPanel = %UiSkillPanel_2B
@onready var _skill3APanel: UISkillPanel = %UiSkillPanel_3A
@onready var _skill3BPanel: UISkillPanel = %UiSkillPanel_3B

@export_group("XP")
@export var _player_level_label: Label
@export var _xp_bar: ProgressBar
@export var _xp_label: Label

@onready var _buy_xp_price_label: Label = %BuyXPPriceLabel
@onready var _flame_texture: ColorRect = %FlameTexture

@onready var _buy_xp_container: Control = %BuyXPContainer
@onready var _xp_container: Control = %XPContainer

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
	_local_player.lvl_changed.connect(_on_local_player_lvl_changed)
	
	_buy_xp_price_label.text = str(GameManager.game_rules.buy_xp_price)
	
	_local_player.hero_changed.connect(_on_local_player_hero_changed)

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


func _activate_max_level_ui() -> void:
	_buy_xp_container.hide()


func _update_level_label(level: int) -> void:
	_player_level_label.text = str(level)


func _init_skills_table() -> void:
	_skill1APanel.init(_local_player.hero.skill1A_name, _local_player.hero.skill1A_description)
	_skill1BPanel.init(_local_player.hero.skill1B_name, _local_player.hero.skill1B_description)
	_skill2APanel.init(_local_player.hero.skill2A_name, _local_player.hero.skill2A_description)
	_skill2BPanel.init(_local_player.hero.skill2B_name, _local_player.hero.skill2B_description)
	_skill3APanel.init(_local_player.hero.skill3A_name, _local_player.hero.skill3A_description)
	_skill3BPanel.init(_local_player.hero.skill3B_name, _local_player.hero.skill3B_description)

# ============================== Callbacks ==============================

func _on_buy_xp_button_pressed() -> void:
	ServerOracleShop.try_buy_xp(_local_player)


func _on_close_button_pressed() -> void:
	hide()


func _on_local_player_death(_player: Player) -> void:
	print("Oracle: lock oracle for ", _local_player.name)
	set_inactive()
	_is_locked = true


func _on_local_player_xp_changed(player_ref: Player, xp: int) -> void:
	var max_xp: int = GameManager.game_rules.xp_per_levels[player_ref.lvl]
	_update_xp_bar(xp, max_xp)


func _on_local_player_lvl_changed(_player_ref: Player, level: int) -> void:
	_update_level_label(level)
	if level == GameManager.game_rules.xp_max_player_level:
		_activate_max_level_ui()


func _on_local_player_hero_changed(_player_ref: Player, _new_hero: Hero) -> void:
	_init_skills_table()
