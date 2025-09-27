@tool
extends EditorScript

@export var _source_file: String = "res://UI/_Themes/Data/hexagon_wood.png"
@export var _dest_folder: String = "res://UI/_Themes/Data/"
@export var _dest_file_name: String = "hexagon_wood.bm"


func _run() -> void:
	print("Creating bit map from [", _source_file, "]")
	var bm: BitMap = BitMap.new()
	
	var file: Resource = load(_source_file)
	if file == null:
		printerr("Can't load image [", _source_file, "]")
		return
	
	var image: Image = file.get_image()
	
	bm.create_from_image_alpha(image)
	var err: Error = ResourceSaver.save(bm, _dest_folder+_dest_file_name)
	if err != OK:
		printerr(_dest_folder+_dest_file_name + "can't be saved [err=", err, "]")
	else:
		print(_dest_folder+_dest_file_name + "saved")
