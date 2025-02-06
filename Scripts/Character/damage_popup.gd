class_name DamagePopUp
extends Label3D
 
var _str: String

# ============================== Public functions ============================== 

func set_value(value: int) -> void:
	_str = str(value)

# ============================== Node base functions ==============================

func _ready() -> void:
	_pop()

# ============================== Private functions ============================== 

func _pop():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector3(1.5,1.5, 1.5), 0.2)
	tween.chain().tween_property(self, "scale", Vector3(1,1,1), 0.2)
	await tween.finished
	queue_free()
