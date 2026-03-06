class_name UIAllFamiliesPortrait
extends Control

# ============================== Signal ==============================

signal family_selected(family_type: Family.Type)

# ============================== Effects Configuration ==============================

@export_group("Animation Configuration")
@export var _step : float = 0.04
@export var _effect_duration: float = 0.4

# ============================== Local Nodes ==============================

@export_group("Local Nodes")
@export var _family_portraits: Array[UIFamilyPortrait]

@onready var _vbox_container: VBoxContainer = %VBoxContainer

# ============================== Public variables ==============================

var _player: Player

# ============================== Private variables ==============================

var _tweens: Array[Tween]

# ============================== Node base functions ==============================

func _ready() -> void:
	hide()
	for i: int in _family_portraits.size():
		var portrait_family: UIFamilyPortrait = _family_portraits[_family_portraits.size() - i - 1]
		portrait_family.modulate.a = 0
		portrait_family.scale = Vector2(0.9, 0.9)
		portrait_family.selected.connect(_on_portrait_family_selected)
		portrait_family.unselected.connect(_on_portrait_family_unselected)

# ============================== Public functions ==============================

func show_families() -> void:
	show()
	_tweens.clear()
	for i: int in _family_portraits.size():
		var portrait_family: UIFamilyPortrait = _family_portraits[_family_portraits.size() - i - 1]
		var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_tweens.append(tw)
		tw.tween_property(portrait_family, "modulate:a", 1.0, _effect_duration).from(0.0).set_delay(i * _step)
		tw.parallel().tween_property(portrait_family, "scale", Vector2.ONE, _effect_duration).from(Vector2(0.9, 0.9)).set_delay(i * _step)


func hide_families() -> void:
	hide()
	for tween: Tween in _tweens:
		tween.kill()
	for i: int in _family_portraits.size():
		var portrait_family: UIFamilyPortrait = _family_portraits[_family_portraits.size() - i - 1]
		portrait_family.modulate.a = 0
		portrait_family.scale = Vector2(0.9, 0.9)


func init_portait_families(families: Array[Family]) -> void:
	if families.size() != _family_portraits.size():
		Verbose.error("UIAllFamiliesPortrait: Too many active families at once")
		return
	for i: int in _family_portraits.size():
		_family_portraits[i].init(families[i])


func update_content(player: Player) -> void:
	_connect_new_player(player)


func reset_buttons_state() -> void:
	for pf: UIFamilyPortrait in _family_portraits:
		pf.unselect()

# ============================== Private functions ==============================

func _connect_new_player(new_player: Player) -> void:
	if _player != null and _player.deck.has_changed.is_connected(_on_player_deck_has_changed):
			_player.deck.has_changed.disconnect(_on_player_deck_has_changed)
	
	_player = new_player
	_player.deck.has_changed.connect(_on_player_deck_has_changed)
	_update_portrait_families()


func _update_portrait_families() -> void:
	_reset_portrait_families()
	var families_count: Dictionary[Family.Type, int] = _player.deck.families_count
	for family_portrait: UIFamilyPortrait in _family_portraits:
		for family_type in families_count.keys():
			if family_portrait.family_type == family_type:
				family_portrait.family_count = families_count[family_type]
	_sort_family_portraits()


func _reset_portrait_families() -> void:
	for family_portrait in _family_portraits:
		family_portrait.family_count = 0


func _sort_family_portraits() -> void:
	var family_portraits_sorted: Array[UIFamilyPortrait] = _family_portraits.duplicate()
	family_portraits_sorted.sort_custom(_custom_sort_fp)
	for i: int in family_portraits_sorted.size():
		var parent_control_node: Control = family_portraits_sorted[i].get_parent()
		_vbox_container.move_child(parent_control_node, i)


func _custom_sort_fp(fp1: UIFamilyPortrait, fp2: UIFamilyPortrait) -> bool:
	return fp1.family_count > fp2.family_count

# ============================== Callbacks ==============================

func _on_player_deck_has_changed() -> void:
	_update_portrait_families()


func _on_portrait_family_selected(portrait_family: UIFamilyPortrait) -> void:
	family_selected.emit(portrait_family.family_type)
	for pf: UIFamilyPortrait in _family_portraits:
		if pf != portrait_family:
			pf.unselect()


func _on_portrait_family_unselected(_portrait_family: UIFamilyPortrait) -> void:
	family_selected.emit(Family.Type.UNDEF)















 
