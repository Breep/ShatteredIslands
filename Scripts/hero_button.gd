extends Control

@onready var ui_player = $UIPlayer


func _ready() -> void:
	pass # Replace with function body.


func _on_focus_entered() -> void:
	ui_player.show()
	ui_player.z_index = 1
	
func _on_mouse_entered() -> void:
	%SubHeroIMG.texture = %HeroIMG.texture
	#%HeroUIPlayerIMG.texture = %HeroIMG.texture
	
func _on_mouse_exited() -> void:
	ui_player.hide()
