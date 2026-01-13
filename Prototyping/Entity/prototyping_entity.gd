extends Node3D

var _entities: Array[Entity]

@onready var _entities_node: Node3D = %Entities

func _ready() -> void:
	for child in _entities_node.get_children():
		if child is Entity:
			_entities.append(child)



# ===== UI =====
#region Global Commands
func _on_start_fight_button_pressed() -> void:
	pass # Replace with function body.


func _on_stop_fight_button_pressed() -> void:
	pass # Replace with function body.


func _on_reset_fight_button_pressed() -> void:
	pass # Replace with function body.
#endregion
