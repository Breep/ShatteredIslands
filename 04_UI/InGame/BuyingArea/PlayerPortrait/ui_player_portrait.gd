# Stub : ce panneau UI était lié au modèle PvP (santé/dégâts/mort du joueur)
# qui n'existe plus en flow roguelite. Conservé pour préserver les .tscn qui
# le référencent, à supprimer ou repenser quand un usage roguelite émerge.
@tool
class_name UIPlayerPortrait
extends Control

@export_group("Local Nodes")
@export var _player_name_label: RichTextLabel
@export var _hero_portrait_button: TextureButton
@export var _player_illustration_portrait: TextureRect
@export var _player_health_bar: TextureProgressBar

var player: Player


func connect_to_player(new_player: Player) -> void:
	player = new_player
	if not is_node_ready() or player == null: return
	_player_name_label.text = player.player_name
	if player.hero != null:
		_player_illustration_portrait.texture = player.hero.portrait
