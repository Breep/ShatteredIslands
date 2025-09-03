class_name UIAllFamiliesPortrait
extends Control

@export_group("Local Nodes")
@export var _portrait_families: Array[UIFamilyPortrait]

var _player: Player
var player: Player:
	get: return _player
	set(value):
		if value == _player: return
		_connect_new_player(value)


func _ready() -> void:
	_settup_portait_families()
	if multiplayer.is_server():
		Events.entity_cliked.connect(_on_events_entity_clicked)
	else:
		player = PlayerManager.get_local_player()


func _settup_portait_families() -> void:
	if GameManager.active_families_type.size() > 8:
		printerr("UIAllFamiliesPortrait: Too many active families at once")
		return
	for i in _portrait_families.size():
		if i < GameManager.active_families_type.size():
			_portrait_families[i].family_type = GameManager.active_families_type[i]
		else:
			_portrait_families[i].hide()


func _connect_new_player(new_player: Player) -> void:
	if _player != null and _player.deck.has_changed.is_connected(_on_player_deck_has_changed):
			_player.deck.has_changed.disconnect(_on_player_deck_has_changed)
	
	_player = new_player
	_player.deck.has_changed.connect(_on_player_deck_has_changed)
	_update_portrait_families()


func _update_portrait_families() -> void:
	_reset_portrait_families()
	var families_count: Dictionary[Family.FamilyType, int] = _player.deck.families_count
	for family_portrait in _portrait_families:
		for family_type in families_count.keys():
			if family_portrait.family_type == family_type:
				family_portrait.family_count = families_count[family_type]


func _reset_portrait_families() -> void:
	for family_portrait in _portrait_families:
		family_portrait.family_count = 0

func _on_player_deck_has_changed() -> void:
	_update_portrait_families()


func _on_events_entity_clicked(entity: Entity) -> void:
	if not entity is Character: return
	if not multiplayer.is_server(): return
	player = (entity as Character).player
















 
