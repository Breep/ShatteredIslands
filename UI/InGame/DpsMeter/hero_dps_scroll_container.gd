extends ScrollContainer

@export var max_items: int = 8
@export var vbox: VBoxContainer

func _ready():
	if vbox == null:
		printerr("No VBox selected in the export of HeroDPSScrollContainer")
		return
	
	vbox.sort_children.connect(_on_vbox_sort_children)


func _adjust_height():
	var items = vbox.get_children()
	var total_height = 0.0
	
	var count = min(items.size(), max_items)
	
	if items.size() > 0:
		var last_visible_item = items[count - 1]
		total_height = last_visible_item.position.y + last_visible_item.size.y
		var spacing = vbox.get_theme_constant("separation")
		if items.size() > max_items:
			total_height += spacing / 2.0 
	custom_minimum_size.y = total_height


func _on_vbox_sort_children() -> void:
	_adjust_height()
