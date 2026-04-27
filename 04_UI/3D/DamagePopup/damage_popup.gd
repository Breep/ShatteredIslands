class_name DamagePopUp
extends Node3D
 
# ============================== Public functions ============================== 

@export var label3d: Label3D

# ============================== Public functions ============================== 

func set_value(value: float) -> void:
	label3d.text = str(value).pad_decimals(0)

func modulate(color: Color) -> void:
	label3d.modulate = color

func outline_modulate(color: Color) -> void:
	label3d.outline_modulate = color

# ============================== Node base functions ==============================

func _ready() -> void:
	_pop()

# ============================== Private functions ============================== 

func _pop():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector3(1.5,1.5,1.5), 0.2)
	tween.chain().tween_property(self, "scale", Vector3(1,1,1), 0.2)
	await tween.finished
	queue_free()
