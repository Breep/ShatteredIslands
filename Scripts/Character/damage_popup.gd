class_name DamagePopUp
extends Label
 
# ============================== Node base functions ==============================

func _ready():
	pop()

# ============================== Public functions ============================== 

func pop():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(2,2), 0.1)
	tween.chain().tween_property(self, "scale", Vector2(1,1), 0.1)
	await tween.finished
	queue_free()
