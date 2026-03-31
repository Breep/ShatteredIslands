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
@export var _family_controls: Array[Control]

@onready var _vbox_container: VBoxContainer = %VBoxContainer

# ============================== Public variables ==============================

var _player: Player

# ============================== Private variables ==============================

var _tweens: Array[Tween]

var _portrait_to_control_map: Dictionary[UIFamilyPortrait, Control]

# ============================== Node base functions ==============================

func _ready() -> void:
	init_portait_families(GameManager.active_families)
	pass

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
	if families.size() > _family_portraits.size():
		Verbose.error("UIAllFamiliesPortrait: Too many active families at once")
		return
	for i: int in _family_portraits.size():
		_portrait_to_control_map[_family_portraits[i]] = _family_controls[i]
		_family_portraits[i].hide()
	for i: int in families.size():
		_family_portraits[i].init(families[i])
		_family_portraits[i].show()


func update_content(player: Player) -> void:
	if player == null: return
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
	for family_portrait: UIFamilyPortrait in _family_portraits:
		var family_type: Family.Type = family_portrait.family_type
		var family_point: int = _player.deck.get_family_points(family_type)
		var xp: int = GameManager.game_rules.family_point_to_xp(family_point)
		var xp_max: int = GameManager.game_rules.family_point_to_xp_max(family_point)
		var lvl: int = _player.deck.get_family_level(family_type)
		family_portrait.family_xp = xp
		family_portrait.family_xp_max = xp_max
		family_portrait.family_lvl = lvl
	_sort_family_portraits()


func _reset_portrait_families() -> void:
	for family_portrait in _family_portraits:
		family_portrait.family_xp = 0


func _sort_family_portraits() -> void:
	var family_portraits_sorted: Array[UIFamilyPortrait] = _family_portraits.duplicate()
	family_portraits_sorted.sort_custom(_custom_sort_fp)
	for i: int in family_portraits_sorted.size():
		var parent_control_node: Control = _portrait_to_control_map[family_portraits_sorted[i]]
		_vbox_container.move_child(parent_control_node, i)
		parent_control_node.layout_direction = LayoutDirection.LAYOUT_DIRECTION_RTL if i % 2 == 0 else LayoutDirection.LAYOUT_DIRECTION_LTR


func _custom_sort_fp(fp1: UIFamilyPortrait, fp2: UIFamilyPortrait) -> bool:
	if fp1.family_lvl > fp2.family_lvl:
		return true
	elif fp1.family_lvl == fp2.family_lvl:
		return fp1.family_xp > fp2.family_xp
	else:
		return false

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















 
