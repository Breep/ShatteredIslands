extends Label
 
func _ready():
	pop()
 

func pop():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.5,1.5), 0.2)
	tween.chain().tween_property(self, "scale", Vector2(1,1), 0.2)
	await tween.finished
	queue_free()
