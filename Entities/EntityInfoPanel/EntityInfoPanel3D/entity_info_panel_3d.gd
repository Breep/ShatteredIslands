class_name EntityInfoPanel3D
extends Node3D

# ============================== Local scene nodes ==============================

@export_group("Popup Spawns")
@export var _physical_popup_spawn: SpawnPoint
@export var _magic_popup_spawn: SpawnPoint
@export var _poison_popup_spawn: SpawnPoint
@export var _heal_popup_spawn: SpawnPoint
@export var _pure_popup_spawn: SpawnPoint

@export_group("External Nodes")
@export var _owner_entity: Entity

@export_group("Local Nodes")
@export var _entity_info_panel_2d: EntityInfoPanel2D

# ============================== Node base functions ==============================

func _enter_tree() -> void:
	_entity_info_panel_2d.init(_owner_entity)

func _ready() -> void:
	Debug.set_target(self)
	# Early validation - crash if misconfigured
	if not _owner_entity:
		Verbose.error("EntityInfoPanel3D: _owner_entity is null! This node is misconfigured.", Verbose.Category.ENTITY)
		return
	
	# Connect entity signals
	_owner_entity.damage_taken.connect(_on_owner_entity_damage_taken)
	_owner_entity.heal_taken.connect(_on_owner_entity_heal_taken)

# ============================== Public ==============================

func damage_popup(amount: float, damage_type: Utils.ActionType, is_critic: bool = false):
	var popup: DamagePopUp = Shared.DAMAGE_POPUP_SCENE.instantiate()
	var offset = Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), 0)
	popup.set_value(amount)
	add_child(popup)
	
	if is_critic:
		popup.modulate(Color8(95, 20, 28, 255))
	
	match damage_type:
		Utils.ActionType.DAMAGE_POISON:
			popup.global_position = _poison_popup_spawn.global_position + offset
			popup.outline_modulate(Color8(20, 95, 28, 255))
		Utils.ActionType.DAMAGE_PHYSICAL:
			popup.global_position = _physical_popup_spawn.global_position + offset
		Utils.ActionType.DAMAGE_MAGICAL:
			popup.global_position = _magic_popup_spawn.global_position + offset
			popup.outline_modulate(Color8(0, 0, 204, 255))
		Utils.ActionType.UTILITY_HEAL:
			popup.global_position = _heal_popup_spawn.global_position + offset
			popup.outline_modulate(Color8(51, 255, 153, 255))
		Utils.ActionType.DAMAGE_PURE:
			popup.global_position = _pure_popup_spawn.global_position + offset
			popup.outline_modulate(Color.DARK_GOLDENROD)
	
	popup.look_at(get_viewport().get_camera_3d().global_position)

# ============================== Callbacks ==============================

func _on_owner_entity_damage_taken(damage: int, damage_type: Utils.ActionType, is_critical: bool, _blocked_by_armor) -> void:
	damage_popup(damage, damage_type, is_critical)

func _on_owner_entity_heal_taken(heal_amount: int, is_critical: bool) -> void:
	damage_popup(heal_amount, Utils.ActionType.UTILITY_HEAL, is_critical)
