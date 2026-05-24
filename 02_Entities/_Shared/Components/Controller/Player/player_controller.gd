class_name PlayerController
extends ControllerStrategy

# Mode MANUAL du EntityController. Écoute les signaux globaux émis par les
# surfaces cliquables :
# - Events.entity_right_clicked(entity) → set_target sur AutoAttack (sauf si self)
# - Events.floor_clicked(position) → clear target + move_to la position
# Les sources sont décentralisées (ClickableComponent côté entités, FloorArea
# côté sol) ; le controller se contente de réagir.


#region ============================== Node base functions ==============================
func _ready() -> void:
	if _owner == null: return
	Events.entity_right_clicked.connect(_on_entity_right_clicked)
	Events.floor_clicked.connect(_on_floor_clicked)


func _exit_tree() -> void:
	if _active:
		disable()
#endregion


#region ============================== Callbacks ==============================
func _on_entity_right_clicked(target: Entity) -> void:
	if not _active: return
	if target == null or target == _owner: return
	if _owner.auto_attack == null: return
	_owner.auto_attack.set_target(target)
	Verbose.debug("PlayerController [" + _owner.entity_name + "]: set_target → " + target.entity_name, Verbose.Category.ENTITY_MODULE)


func _on_floor_clicked(world_position: Vector3) -> void:
	if not _active: return
	if _owner.auto_attack != null:
		_owner.auto_attack.clear_target()
	if _owner.movement != null:
		_owner.movement.set_target_position(world_position)
		Verbose.debug("PlayerController [" + _owner.entity_name + "]: move_to " + str(world_position), Verbose.Category.ENTITY_MODULE)
#endregion
