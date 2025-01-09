extends Control
class_name CardUI

@onready var descriptionLabel : Label = $SubViewportContainer/SubViewport/Card/Description
@onready var image : TextureRect = $SubViewportContainer/SubViewport/Card/Image
@onready var title : RichTextLabel = $SubViewportContainer/SubViewport/Card/Title
@onready var type : TextureRect = $SubViewportContainer/SubViewport/Card/Type
@onready var level : Label = $SubViewportContainer/SubViewport/Card/Level
@onready var rarity : Control = $SubViewportContainer/SubViewport/Card/Rarity
@onready var lvlcontainer : VBoxContainer = $SubViewportContainer/SubViewport/Card/Control/lvlcontainer


func _ready() -> void:
	tween_hover = create_tween()
	tween_rot = create_tween()
	
	
func update_visual_card(card: Card) :
	descriptionLabel.text = card.description
	image.texture = card.image
	type.texture = card.famille
	title.text = card.name
	level.text = str(card.lvl) + "/5"
	match card.rarity :
		Card.Rarity.COMMON:
			print("Carte Commune")
			$SubViewportContainer/SubViewport/Card/Rarity/Common.show()
		Card.Rarity.RARE:
			print("Carte Rare")
			$SubViewportContainer/SubViewport/Card/Rarity/Rare.show()
		Card.Rarity.EPIC:
			print("Carte Epic")
			$SubViewportContainer/SubViewport/Card/Rarity/Epic.show()
	for i in card.lvl:
		var hbox_node = lvlcontainer.get_node(str(i))
		if hbox_node:
			hbox_node.show()
		else:
			print("Node not found:")


#Tween part =>

@export var angle_x_max: float = 15.0
@export var angle_y_max: float = 15.0
@export var max_offset_shadow: float = 50.0

var tween_rot: Tween
var tween_hover: Tween
var tween_handle: Tween

@onready var card_texture = $SubViewportContainer

var following_mouse: bool = false
@onready var collision_shape = $Area2D/CollisionShape2D

func _on_mouse_entered() -> void:
	print("coucou2")
	if tween_hover:
		print("coucou3")
		tween_hover.kill()
		tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween_hover.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)


func _on_mouse_exited() -> void:
	print("coucou1")
	if tween_rot:
		print("coucou4")
		tween_rot.kill()
		tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
		tween_rot.tween_property($SubViewportContainer.material, "shader_parameter/x_rot", 0.0, 0.5)
		tween_rot.tween_property($SubViewportContainer.material, "shader_parameter/y_rot", 0.0, 0.5)
		print("coucou6")
	
	# Reset scale
	if tween_hover:
		print("coucou5")
		tween_hover.kill()
		tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween_hover.tween_property(self, "scale", Vector2.ONE, 0.55)


func _on_pressed() -> void:
	$".".hide()


func _on_sub_viewport_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		subview_3d_rotate_card()

func subview_3d_rotate_card():
	var mouse_pos: Vector2 = get_local_mouse_position()
	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)

	var rot_x: float = lerpf(-angle_x_max, angle_x_max, lerp_val_x)
	var rot_y: float = lerpf(angle_y_max, -angle_y_max, lerp_val_y)
	print(rot_x, "  ",  rot_y,"    ", lerp_val_x, "  ", lerp_val_y)
	
	card_texture.material.set_shader_parameter("x_rot", rot_y)
	card_texture.material.set_shader_parameter("y_rot", rot_x)
