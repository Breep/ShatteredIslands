class_name UIOracle
extends Control

# ============================== Local Nodes ==============================

@onready var _buy_xp_price_label: Label = %BuyXPPriceLabel
@onready var _buy_xp_button: Button = %BuyXPButton
@onready var _all_levels_container: AllLevelsContainers = %AllLevelsContainers
@onready var _level_preview_container: UILevelPreviewContainer = %LevelPreviewContainer

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
	_local_player.lvl_changed.connect(_on_local_player_lvl_changed)
	_local_player.skill_choice_awaiting.connect(_on_local_player_skill_choice_awaiting)
	
	_all_levels_container.level_preview_changed.connect(_on_all_levels_container_level_preview_changed)
	
	_buy_xp_price_label.text = str(GameManager.game_rules.buy_xp_price)
	
	var max_xp: int = GameManager.game_rules.xp_per_levels[_local_player.lvl]
	_all_levels_container.update_player_xp(_local_player.lvl, _local_player.xp, max_xp)

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


# ============================== Callbacks ==============================

func _on_buy_xp_button_pressed() -> void:
	ServerOracleShop.try_buy_xp(_local_player)


func _on_close_button_pressed() -> void:
	hide()


func _on_local_player_death(_player: Player) -> void:
	set_inactive()
	_is_locked = true


func _on_local_player_xp_changed(player_ref: Player, xp: int) -> void:
	var max_xp: int = GameManager.game_rules.xp_per_levels[player_ref.lvl]
	_all_levels_container.update_player_xp(player_ref.lvl, player_ref.xp, max_xp)


func _on_local_player_lvl_changed(player_ref: Player, level: int) -> void:
	var max_xp: int = GameManager.game_rules.xp_per_levels[player_ref.lvl]
	_all_levels_container.update_player_xp(player_ref.lvl, player_ref.xp, max_xp)
	if level >= GameManager.game_rules.xp_max_player_level:
		_buy_xp_button.disabled = true


func _on_local_player_skill_choice_awaiting(skill_level: int) -> void:
	_all_levels_container.blink(skill_level)


func _on_all_levels_container_level_preview_changed(level: int) -> void:
	_level_preview_container.set_title("Level " + str(level) + " Skills")
	match level:
		3: _level_preview_container.set_skills_info(_local_player.hero.skill1A, _local_player.hero.skill1B)
		5: _level_preview_container.set_skills_info(_local_player.hero.skill2A, _local_player.hero.skill2B)
		7: _level_preview_container.set_skills_info(_local_player.hero.skill3A, _local_player.hero.skill3B)
		_: _level_preview_container.set_empty()
