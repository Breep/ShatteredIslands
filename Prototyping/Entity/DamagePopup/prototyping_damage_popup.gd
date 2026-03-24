extends Node3D

const DAMAGE_POPUP_SCENE: PackedScene = preload("res://Prototyping/Entity/DamagePopup/damage_popup2.tscn")

@export_group("External Nodes")
@export var _owner_entity: Entity

@export var _center_point_camera: CenterPointCamera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_center_point_camera.set_active()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#func _init() -> void
	


func _on_button_pressed() -> void:
	var damage_popup: DamagePopup2 = DAMAGE_POPUP_SCENE.instantiate()
	damage_popup.init(_owner_entity.global_position)
	add_child(damage_popup)


func _on_button_2_pressed() -> void:
	for i in 20:
		_owner_entity.take_damage(i, Utils.ActionType.DAMAGE_PHYSICAL, false, "lol")
