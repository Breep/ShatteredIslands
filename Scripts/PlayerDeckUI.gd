extends Control
class_name PlayerDeckUI

func _ready():
	return

func show_player_cards(cards: Array[Card]):
	var grid_container = %GridContainer
	for child in grid_container.get_children():
		print(child)
		child.queue_free()
	
	for card in cards:
			var slot = TextureRect.new()
			slot.texture = card.picture
			slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			slot.stretch_mode = TextureRect.STRETCH_SCALE  
			slot.custom_minimum_size = Vector2(150, 200) 
			grid_container.add_child(slot)
		


func _on_leave_pressed() -> void:
	$".".hide()
