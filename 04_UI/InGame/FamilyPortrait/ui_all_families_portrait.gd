class_name UIAllFamiliesPortrait
extends Control

# ============================== Signal ==============================

signal family_selected(family_type: Family.Type)

# ============================== Effects Configuration ==============================

@export_group("Animation Configuration")
@export var _step : float = 0.04
@export var _effect_duration: float = 0.4
@export var _select_anim_duration: float = 0.15
@export var _active_scale_factor: float = 1.4

# ============================== Local Nodes ==============================

@export_group("Local Nodes")
@export var _family_portraits: Array[UIFamilyPortrait]
@export var _family_controls: Array[Control]

@onready var _vbox_container: VBoxContainer = %VBoxContainer

# ============================== Public variables ==============================

var _player: Player

# ============================== Private variables ==============================

var _tweens: Array[Tween]
var _select_tween: Tween

var _portrait_to_control_map: Dictionary[UIFamilyPortrait, Control]
var _base_min_size_y: float

# ============================== Node base functions ==============================

func _ready() -> void:
	if _family_controls.size() > 0:
		_base_min_size_y = _family_controls[0].custom_minimum_size.y
	init_portait_families(GameManager.active_families)
	Events.entity_clicked.connect(_on_events_entity_clicked)

# ============================== Public functions ==============================

func init_portait_families(families: Array[Family]) -> void:
	if families.size() > _family_portraits.size():
		Verbose.error("UIAllFamiliesPortrait: Too many active families at once")
		return
	for i: int in _family_portraits.size():
		_portrait_to_control_map[_family_portraits[i]] = _family_controls[i]
		_family_portraits[i].selected.connect(_on_portrait_family_selected)
		_family_portraits[i].unselected.connect(_on_portrait_family_unselected)
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
	_animate_family_controls(null)

# ============================== Private functions ==============================

func _connect_new_player(new_player: Player) -> void:
	if _player != null and _player.hand.has_changed.is_connected(_on_player_hand_has_changed):
			_player.hand.has_changed.disconnect(_on_player_hand_has_changed)
	
	_player = new_player
	#_player.hand.has_changed.connect(_on_player_hand_has_changed) # TODO a rework complétement
	_update_portrait_families()
	Events.signal_ui_family_portrait_unselected()


func _update_portrait_families() -> void:
	for family_portrait: UIFamilyPortrait in _family_portraits:
		var family_type: Family.Type = family_portrait.family_type
		var family_point: int = 40# _player.hand.get_family_points(family_type)
		var xp: int = GameManager.game_rules.family_point_to_xp(family_point)
		var xp_max: int = GameManager.game_rules.family_point_to_xp_max(family_point)
		var lvl: int = 4#_player.hand.get_family_level(family_type) # TODO a rework complètement
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

func _animate_family_controls(active_portrait: UIFamilyPortrait) -> void:
	if _select_tween and _select_tween.is_running():
		_select_tween.kill()
	_select_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	for portrait: UIFamilyPortrait in _family_portraits:
		var control: Control = _portrait_to_control_map[portrait]
		var child_index: int = control.get_index()
		if child_index % 2 != 0:
			continue
		var target_y := _base_min_size_y * _active_scale_factor if portrait == active_portrait else _base_min_size_y
		_select_tween.tween_property(control, "custom_minimum_size:y", target_y, _select_anim_duration)


# ============================== Callbacks ==============================

func _on_player_hand_has_changed() -> void:
	_update_portrait_families()


func _on_portrait_family_selected(portrait_family: UIFamilyPortrait) -> void:
	family_selected.emit(portrait_family.family_type)
	for pf: UIFamilyPortrait in _family_portraits:
		if pf != portrait_family:
			pf.unselect()
	_animate_family_controls(portrait_family)
	Events.signal_ui_family_portrait_requested(_player, portrait_family._family) # TODO: oulala private


func _on_portrait_family_unselected(_portrait_family: UIFamilyPortrait) -> void:
	family_selected.emit(Family.Type.UNDEF)
	_animate_family_controls(null)
	Events.signal_ui_family_portrait_unselected()


func _on_events_entity_clicked(entity: Entity) -> void:
	if not entity.is_hero(): return
	#var hero: Entity = entity
	#if hero.player != null:
		#update_content(hero.player)












 
