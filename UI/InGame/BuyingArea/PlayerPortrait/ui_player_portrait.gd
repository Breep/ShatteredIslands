@tool

class_name UIPlayerPortrait
extends Control

# ============================== Private variables ==============================

var player: Player

#region ============================== Controllers ==============================
@export var flip_ui: bool = false:
	get: return flip_ui
	set(value):
		flip_ui = value
		if flip_ui: _player_health_bar.scale.x = -1
		else: _player_health_bar.scale.x = 1
#endregion
# ============================== Local nodes ==============================

@export_group("Local Nodes")
@export var _player_name_label: RichTextLabel
@export var _hero_portrait_button: TextureButton
@export var _player_illustration_portrait: TextureRect
@export var _player_health_bar: TextureProgressBar

#@onready var _player_health_label: Label = %PlayerHealthLabel

#@onready var _damage_label: Label = %PlayerDamageLabel
#@onready var _level_label: Label = %PlayerLevelLabel

# ============================== Public functions ==============================

func connect_to_player(new_player: Player) -> void:
	player = new_player
	player.hero_changed.connect(_on_player_hero_changed)
	_setup_local_nodes()

# ============================== Node base functions ==============================

func _ready() -> void:
	if _player_health_bar.material != null:
		_player_health_bar.material = _player_health_bar.material.duplicate()
	_setup_local_nodes()

# ============================== Private functions ==============================

func _setup_local_nodes() -> void:
	if not is_node_ready() or player == null: return
	_player_name_label.text = player.player_name
	if player.hero != null:
		_player_illustration_portrait.texture = player.hero.portrait
	
	#player.damage_changed.connect(_on_player_damage_changed)
	#_on_player_damage_changed(player, player.damage)
	#
	#player.lvl_changed.connect(_on_player_lvl_changed)
	#_on_player_lvl_changed(player, player.lvl)
	
	player.death.connect(_on_player_death)
	
	player.health_changed.connect(_on_player_health_changed)
	player.max_health_changed.connect(_on_player_max_health_changed)
	_update_health_bar(player.health, player.max_health)
	
	#_player_health_label.text = str(player.health)

func _update_health_bar(health: float, health_max: float) -> void:
	_player_health_bar.max_value = health_max
	_player_health_bar.value = health

# ============================== Callbacks ==============================

func _on_player_hero_changed(_player: Player, hero_desc: HeroDesc) -> void:
	_player_illustration_portrait.texture = hero_desc.portrait
	_update_health_bar(_player.health, _player.max_health)


func _on_player_max_health_changed(_player: Player, max_health: int) -> void:
	_update_health_bar(_player.health, _player.max_health)


func _on_player_health_changed(_player: Player, health: int) -> void:
	_update_health_bar(_player.health, _player.max_health)
	#_player_health_label.text = str(health)


#func _on_player_damage_changed(_player: Player, damage: int) -> void:
	#_damage_label.text = str(damage)
#
#
#func _on_player_lvl_changed(_player: Player, lvl: int) -> void:
	#_level_label.text = str(lvl)


func _on_player_death(_player: Player) -> void:
	pass
