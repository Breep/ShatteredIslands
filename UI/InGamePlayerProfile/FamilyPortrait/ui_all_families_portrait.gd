class_name UIAllFamiliesPortrait
extends Control

@export_group("Local Nodes")
@export var _portrait_families: Array[UIFamilyPortrait]

@export var _step : float = 0.04
@export var _effect_duration: float = 0.4

var _tweens: Array[Tween]

var _player: Player
var player: Player:
	get: return _player
	set(value):
		if value == _player: return
		_connect_new_player(value)

func show_families() -> void:
	show()
	_tweens.clear()
	for i: int in _portrait_families.size():
		var portrait_family: UIFamilyPortrait = _portrait_families[_portrait_families.size() - i - 1]
		var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_tweens.append(tw)
		tw.tween_property(portrait_family, "modulate:a", 1.0, _effect_duration).from(0.0).set_delay(i * _step)
		tw.parallel().tween_property(portrait_family, "scale", Vector2.ONE, _effect_duration).from(Vector2(0.9, 0.9)).set_delay(i * _step)

func hide_families() -> void:
	hide()
	for tween: Tween in _tweens:
		tween.kill()
	for i: int in _portrait_families.size():
		var portrait_family: UIFamilyPortrait = _portrait_families[_portrait_families.size() - i - 1]
		portrait_family.modulate.a = 0
		portrait_family.scale = Vector2(0.9, 0.9)

func _ready() -> void:
	hide()
	for i: int in _portrait_families.size():
		var portrait_family: UIFamilyPortrait = _portrait_families[_portrait_families.size() - i - 1]
		portrait_family.modulate.a = 0
		portrait_family.scale = Vector2(0.9, 0.9)
	return
	
	if multiplayer.is_server():
		Events.entity_cliked.connect(_on_events_entity_clicked)
	else:
		player = PlayerManager.get_local_player()


func init_portait_families(families: Array[Family]) -> void:
	if families.size() > _portrait_families.size():
		printerr("UIAllFamiliesPortrait: Too many active families at once")
		return
	for i in _portrait_families.size():
		_portrait_families[i].init(families[i])


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
















 
