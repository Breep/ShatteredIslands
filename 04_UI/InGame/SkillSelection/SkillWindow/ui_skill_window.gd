class_name UISkillWindow
extends Control

## Vignette d'un skill sélectionnable : affiche son icône, son nom et sa
## description, grossit légèrement au survol et émet Events.skill_selected au clic.

#region Constants
const HOVER_SCALE := Vector2(1.05, 1.05)
const TWEEN_TIME := 0.1
#endregion

#region Private vars
var _skill: Skill
var _tween: Tween
#endregion

#region Node base functions
@onready var _container: PanelContainer = %SkillContainer
@onready var _icon: TextureRect = %SkillIcon
@onready var _name_label: Label = %SkillName
@onready var _description: RichTextLabel = %SkillDescription


func _ready() -> void:
	_container.mouse_entered.connect(_on_container_mouse_entered)
	_container.mouse_exited.connect(_on_container_mouse_exited)
	_container.gui_input.connect(_on_container_gui_input)
#endregion

#region Public functions
func update(skill: Skill) -> void:
	_skill = skill
	if skill == null: return
	_icon.texture = skill.portrait
	_name_label.text = skill.name
	_description.text = skill.description
#endregion

#region Private functions
func _scale_to(target: Vector2) -> void:
	if _tween and _tween.is_valid(): _tween.kill()
	_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_container, "scale", target, TWEEN_TIME)
#endregion

#region Callbacks
func _on_container_mouse_entered() -> void:
	_scale_to(HOVER_SCALE)


func _on_container_mouse_exited() -> void:
	_scale_to(Vector2.ONE)


func _on_container_gui_input(event: InputEvent) -> void:
	if _skill == null: return
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		Events.signal_skill_selected(_skill)
#endregion
