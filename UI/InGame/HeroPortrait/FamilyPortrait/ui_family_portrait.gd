class_name UIFamilyPortrait
extends Control


# ============================== Signal ==============================

signal selected(self_ref: UIFamilyPortrait)
signal unselected(self_ref: UIFamilyPortrait)

# ============================== Enums ==============================

enum {
	MAIN_FRAME_TEXTURE,
	XP_FRAME_TEXTURE,
	LVL_TICKS_TEXTURE
}

# ============================== Constants ==============================

const FAMILY_LEVEL_MAP_PROGRESS_BAR_VALUE: Array[float] =[0, 30, 50, 70, 100]

const DEACTIVATED_FRAME_SCENE: Dictionary = {
	MAIN_FRAME_TEXTURE: preload("res://UI/InGame/HeroPortrait/FamilyPortrait/Data/0_black/family_cercle_inactive_main.png"),
	XP_FRAME_TEXTURE: preload("res://UI/InGame/HeroPortrait/FamilyPortrait/Data/0_black/family_cercle_inactive_xp_container.png"),
}

const FRAME_TEXTURES: Array[Dictionary] = [
	{
		MAIN_FRAME_TEXTURE: preload("res://UI/InGame/HeroPortrait/FamilyPortrait/Data/1_Bronze/family_cercle_bronze_main_frame.png"),
		XP_FRAME_TEXTURE: preload("res://UI/InGame/HeroPortrait/FamilyPortrait/Data/1_Bronze/family_cercle_bronze_xp_frame.png"),
		LVL_TICKS_TEXTURE: preload("res://UI/InGame/HeroPortrait/FamilyPortrait/Data/1_Bronze/family_cercle_bronze_level_ticks.png"),
	},
	{
		MAIN_FRAME_TEXTURE: preload("res://UI/InGame/HeroPortrait/FamilyPortrait/Data/2_Silver/family_cercle_silver_main_frame.png"),
		XP_FRAME_TEXTURE: preload("res://UI/InGame/HeroPortrait/FamilyPortrait/Data/2_Silver/family_cercle_silver_xp_frame.png"),
		LVL_TICKS_TEXTURE: preload("res://UI/InGame/HeroPortrait/FamilyPortrait/Data/2_Silver/family_cercle_silver_level_ticks.png"),
	},
	{
		MAIN_FRAME_TEXTURE: preload("res://UI/InGame/HeroPortrait/FamilyPortrait/Data/3_Gold/family_cercle_gold_main_frame.png"),
		XP_FRAME_TEXTURE: preload("res://UI/InGame/HeroPortrait/FamilyPortrait/Data/3_Gold/family_cercle_gold_xp_frame.png"),
		LVL_TICKS_TEXTURE: preload("res://UI/InGame/HeroPortrait/FamilyPortrait/Data/3_Gold/family_cercle_gold_level_ticks.png"),
	},
	{
		MAIN_FRAME_TEXTURE: preload("res://UI/InGame/HeroPortrait/FamilyPortrait/Data/4_Platinium/family_cercle_platinium_main_frame.png"),
		XP_FRAME_TEXTURE: preload("res://UI/InGame/HeroPortrait/FamilyPortrait/Data/4_Platinium/family_cercle_platinium_xp_frame.png"),
		LVL_TICKS_TEXTURE: preload("res://UI/InGame/HeroPortrait/FamilyPortrait/Data/4_Platinium/family_cercle_platinium_level_ticks.png"),
	},
	{
		MAIN_FRAME_TEXTURE: preload("res://UI/InGame/HeroPortrait/FamilyPortrait/Data/5_Prismatic/family_cercle_prismatic_main_frame.png"),
		XP_FRAME_TEXTURE: preload("res://UI/InGame/HeroPortrait/FamilyPortrait/Data/5_Prismatic/family_cercle_prismatic_xp_frame.png"),
		LVL_TICKS_TEXTURE: preload("res://UI/InGame/HeroPortrait/FamilyPortrait/Data/5_Prismatic/family_cercle_prismatic_level_ticks.png"),
	}
]

# ============================== Local nodes ==============================

@onready var _family_icon: TextureRect = %FamilyIcon
@onready var _family_lvl_progress_bar: TextureProgressBar = %FamilyLvlProgressBar
@onready var _current_xp_progress_bar: TextureProgressBar = %XPProgressBar
@onready var _button: TextureButton = %TextureButton
@onready var _glow_effect: TextureRect = %GlowEffect
@onready var _family_background: TextureRect = %FamilyBackground
@onready var _xp_bar_frame: TextureRect = %XPBarFrame
@onready var _main_frame: TextureRect = %MainFrame

# ============================== Public variables ==============================

var family_type: Family.Type

var _family_xp: int = 0
var family_xp: int:
	get: return _family_xp
	set(value):
		var old_xp = _family_xp
		_family_xp = value
		_current_xp_progress_bar.value = _family_xp
		if old_xp == 0 and _family_lvl == 0:
			_update_frame()

var _family_xp_max: int = 0
var family_xp_max: int:
	get: return _family_xp_max
	set(value):
		_family_xp_max = value
		_current_xp_progress_bar.max_value = _family_xp_max

var _family_lvl: int = 0
var family_lvl: int:
	get: return _family_lvl
	set(value):
		_family_lvl = value
		_family_lvl_progress_bar.value = FAMILY_LEVEL_MAP_PROGRESS_BAR_VALUE[_family_lvl]
		_update_frame()


# ============================== Private variables ==============================

var _family: Family

# ============================== Node base functions ==============================

func _ready() -> void:
	if _glow_effect.material != null:
		_glow_effect.material = _glow_effect.material.duplicate()
	_update_frame()
	_glow_effect.hide()

# ============================== Public functions ==============================

func init(family: Family) -> void:
	family_type = family.family_type
	_family_background.modulate = family.color
	_glow_effect.material.set_shader_parameter("glow_color", family.color)
	_family_icon.texture = family.icon
	_family = family


func unselect() -> void:
	_button.set_pressed_no_signal(false)

# ============================== Private functions ==============================

func _on_texture_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		selected.emit(self)
	else:
		unselected.emit(self)


func _update_frame() -> void:
	if _family_lvl == 0 and _family_xp == 0:
		_main_frame.texture = DEACTIVATED_FRAME_SCENE[MAIN_FRAME_TEXTURE]
		_xp_bar_frame.hide()
		_family_lvl_progress_bar.hide()
	else:
		_main_frame.texture = FRAME_TEXTURES[_family_lvl][MAIN_FRAME_TEXTURE]
		_xp_bar_frame.texture = FRAME_TEXTURES[_family_lvl][XP_FRAME_TEXTURE]
		_family_lvl_progress_bar.texture_progress = FRAME_TEXTURES[_family_lvl][LVL_TICKS_TEXTURE]
		_xp_bar_frame.show()
		_family_lvl_progress_bar.show()
	
	if _family_lvl == 4:
		_xp_bar_frame.hide()
		_glow_effect.show()


func _glow() -> void:
	_glow_effect.show()
	#var tween = create_tween()
	#tween.tween_property(_glow_effect, "rotation:y", _visual_3d.rotation.y + TAU, 0.8) \
		#.set_trans(Tween.TRANS_QUART) \
		#.set_ease(Tween.EASE_OUT)




 
