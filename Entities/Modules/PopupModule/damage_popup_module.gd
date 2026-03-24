class_name DamagePopupModule
extends Module

@export_group("External Nodes")
@export var _owner_entity: Entity

@export var _popup_marker: Marker3D
@export var _radius: float = 1

@onready var random:= RandomNumberGenerator.new()

const DAMAGE_POPUP_SCENE: PackedScene = preload("res://Prototyping/Entity/DamagePopup/damage_popup2.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not _owner_entity:
		Verbose.error("EntityInfoPanel3D: _owner_entity is null! This node is misconfigured.", Verbose.Category.ENTITY)
		return
	
	random.randomize()
	# Connect entity signals
	_owner_entity.damage_taken.connect(_on_owner_entity_damage_taken)
	_owner_entity.heal_taken.connect(_on_owner_entity_heal_taken)


func damage_popup(amount: float, damage_type: Utils.ActionType, is_critic: bool = false):
	var popup: DamagePopup2 = DAMAGE_POPUP_SCENE.instantiate()
	var x = random.randf_range(-1,1)
	var y = random.randf_range(0.07,1)
	var r = random.randf_range(0, _radius)
	var offset = Vector3(x,y,x).normalized() * r
	
	popup.set_value(amount)
	popup.init(_popup_marker.global_position + offset)
	add_child(popup)
	
	
	#if is_critic:
		#popup.modulate(Color8(95, 20, 28, 255))
	
	#match damage_type:
		#Utils.ActionType.DAMAGE_POISON:
			#popup.global_position = _poison_popup_spawn.global_position + offset
			#popup.outline_modulate(Color8(20, 95, 28, 255))
		#Utils.ActionType.DAMAGE_PHYSICAL:
			#popup.global_position = _physical_popup_spawn.global_position + offset
		#Utils.ActionType.DAMAGE_MAGICAL:
			#popup.global_position = _magic_popup_spawn.global_position + offset
			#popup.outline_modulate(Color8(0, 0, 204, 255))
		#Utils.ActionType.UTILITY_HEAL:
			#popup.global_position = _heal_popup_spawn.global_position + offset
			#popup.outline_modulate(Color8(51, 255, 153, 255))
		#Utils.ActionType.DAMAGE_PURE:
			#popup.global_position = _pure_popup_spawn.global_position + offset
			#popup.outline_modulate(Color.DARK_GOLDENROD)
	


# ============================== Callbacks ==============================

func _on_owner_entity_damage_taken(damage: float, damage_type: Utils.ActionType, is_critical: bool, _blocked_by_armor) -> void:
	damage_popup(damage, damage_type, is_critical)

func _on_owner_entity_heal_taken(heal_amount: int, is_critical: bool) -> void:
	damage_popup(heal_amount, Utils.ActionType.UTILITY_HEAL, is_critical)
