@tool

class_name Chain
extends Node3D

const CHAIN_LINK: PackedScene = preload("res://Prototyping/Chain/chain_link.tscn")
const BASE_LINK: PackedScene = preload("res://Prototyping/Chain/base_link.tscn")

var _link_number: int
@export var link_number: int:
	get: return _link_number
	set(value):
		if _link_number == value: return
		_link_number = value
		_update_links()

@export var _base_link: BaseLink

@export var _links: Array[Node3D] = []

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_pin_all_links()


func _pin_all_links() -> void:
	print("DEBUG - Pin all links: ", _link_number, " ", _links.size())
	for i in _links.size() - 1:
		for child in _links[i].get_children(false):
			if child is PinJoint3D:
				var pin_joint: PinJoint3D = child
				pin_joint.node_a = _links[i].get_path()
				pin_joint.node_b = _links[i+1].get_path()


func _update_links() -> void:
	print("DEBUG - Updating links: ", _link_number)
	if not Engine.is_editor_hint(): return
	for child in get_children(false):
		if child is ChainLink:
			print("DEBUG - queue freeing ", child.name)
			child.queue_free()
			child.owner = get_tree().edited_scene_root
	for child in _base_link.get_children(false):
		if child is PinJoint3D:
			child.queue_free()
			child.owner = get_tree().edited_scene_root
	_links.clear()
	
	var previous_link: Node3D = _base_link
	for i in _link_number:
		_links.append(previous_link)
		print("DEBUG _ Adding link number ", i)
		var chain_link: ChainLink = CHAIN_LINK.instantiate()
		chain_link.name = "ChainLink" + str(i)
		var pin_join := PinJoint3D.new()
		add_child(chain_link)
		chain_link.owner = get_tree().edited_scene_root
		previous_link.add_child(pin_join)
		pin_join.position = 0.5 * Vector3.UP
		pin_join.owner = get_tree().edited_scene_root
		chain_link.position = (i+1) * Vector3.UP
		previous_link = chain_link
	_links.append(previous_link)
