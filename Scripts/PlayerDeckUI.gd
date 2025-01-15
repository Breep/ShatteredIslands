extends Control

var test: Array[Card] = []
func _ready():
	show_player_cards(test)

func show_player_cards(cards: Array[Card]):
	var grid_container = get_node("NinePatchRect/GridContainer")
	for child in grid_container.get_children():
		print(child)
		child.queue_free()
		
	
	for card in cards:
		var slot = TextureRect.new()  
		slot.texture = card.picture  
		grid_container.add_child(slot) 
		
