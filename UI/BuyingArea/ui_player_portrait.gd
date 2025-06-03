class_name UIPlayerPortrait
extends Control

# ============================== Private variables ==============================

var player: Player

# ============================== Local nodes ==============================

@onready var _player_name_label: Label = %PlayerNameLabel
@onready var _hero_portrait: TextureRect = %HeroPortrait
@onready var _ui_player_life: UIPlayerLife = %PlayerLife
@onready var _damage_label: Label = %DamageLabel
@onready var _level_label: Label = %LevelLabel

# ============================== Public functions ==============================

func connect_to_player(new_player: Player) -> void:
	player = new_player
	player.hero_changed.connect(_on_player_hero_changed)
	_setup_local_nodes()

# ============================== Node base functions ==============================

func _ready() -> void:
	_setup_local_nodes()

# ============================== Private functions ==============================

func _setup_local_nodes() -> void:
	if not is_node_ready() or player == null: return
	_player_name_label.text = player.name
	if player.hero != null:
		_hero_portrait.texture = player.hero.portrait
	_ui_player_life.connect_to_player_health_signal(player.health_changed)
	_ui_player_life.connect_to_player_max_health_signal(player.max_health_changed)
	_ui_player_life.update_player_life(player.health, player.max_health)
	player.damage_changed.connect(_on_player_damage_changed)
	_on_player_damage_changed(player, player.damage)
	player.lvl_changed.connect(_on_player_lvl_changed)
	_on_player_lvl_changed(player, player.lvl)

# ============================== Callbacks ==============================

func _on_player_hero_changed(_player: Player, hero: Hero) -> void:
	_hero_portrait.texture = player.hero.portrait


func _on_player_damage_changed(_player: Player, damage: int) -> void:
	_damage_label.text = str(damage)


func _on_player_lvl_changed(_player: Player, lvl: int) -> void:
	_level_label.text = str(lvl)
