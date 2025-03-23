class_name UIPlayerPortrait
extends Control

# ============================== Private variables ==============================

var _player: Player

# ============================== Local nodes ==============================

@onready var _player_name_label: Label = %PlayerNameLabel
@onready var _hero_portrait: TextureRect = %HeroPortrait
@onready var _ui_player_life: UIPlayerLife = %PlayerLife

# ============================== Public functions ==============================

func connect_to_player(new_player: Player) -> void:
	_player = new_player
	_player.hero_changed.connect(_on_player_hero_changed)
	_setup_local_nodes()

# ============================== Node base functions ==============================

func _ready() -> void:
	_setup_local_nodes()

# ============================== Private functions ==============================

func _setup_local_nodes() -> void:
	if not is_node_ready() or _player == null: return
	_player_name_label.text = _player.name
	if _player.hero != null:
		_hero_portrait.texture = _player.hero.portrait
	_ui_player_life.connect_to_player_health_signal(_player.health_changed)
	_ui_player_life.connect_to_player_max_health_signal(_player.max_health_changed)
	_ui_player_life.update_player_life(_player.health, _player.max_health)

# ============================== Callbacks ==============================

func _on_player_hero_changed(hero: Hero) -> void:
	_hero_portrait.texture = _player.hero.portrait
