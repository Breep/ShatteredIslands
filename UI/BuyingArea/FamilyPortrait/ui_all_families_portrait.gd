class_name UIAllFamiliesPortrait
extends Control

@export_group("Local Nodes")
@export var _portrait_families: Array[UIFamilyPortrait]

var _player: Player
var player: Player:
	get: return _player
	set(value):
		if value == _player: return
		_player = value

func _ready() -> void:
	_settup_portait_families()

func _settup_portait_families() -> void:
	if GameManager.active_families_type.size() > 8:
		printerr("UIAllFamiliesPortrait: Too many active families at once")
		return
	for i in _portrait_families.size():
		if i < GameManager.active_families_type.size():
			_portrait_families[i].family_type = GameManager.active_families_type[i]
		else:
			_portrait_families[i].hide()

func _update_portrait_families() -> void:
	print("Update portrait card families for ", player.name)
