class_name HitMarkerComponent
extends EntityComponent

## Joue un VFX de marqueur d'impact sur le porteur à chaque coup direct subi.
## Auto-chargé sur toutes les entités. Écoute action_received (et non
## damage_taken) car seul l'action_id permet d'exclure les ticks de DoT : le
## burn (ignite) inflige ses ticks en DAMAGE_MAGICAL, indissociable d'un vrai
## coup magique par le seul type.

#region ============================== Constants ==============================
const _HIT_MARKER_VFX := preload("res://22_VFX/VFX_3D/Hit_marker/hit_marker.tscn")

## Couvre l'animation "hit" (0.7s) du VFX avant le free.
const _VFX_LIFETIME: float = 1.0

## Action_id du tick de burn — exclu par id car il passe en DAMAGE_MAGICAL.
const _IGNITE_PERIODIC_ID: StringName = &"Ignite Periodic"
#endregion

#region ============================== Node base functions ==============================
func _enter_tree() -> void:
	if _owner == null: return
	if _owner.hit_marker != null and _owner.hit_marker != self:
		Verbose.trace("Override: HitMarkerComponent on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.hit_marker.queue_free()
	_owner.hit_marker = self


func _ready() -> void:
	super._ready()
	if _owner == null or _owner.hit_marker != self:
		return
	_owner.action_received.connect(_on_owner_action_received)
#endregion

#region ============================== Private functions ==============================
func _is_direct_hit(action_type: Utils.ActionType, action_id: StringName) -> bool:
	match action_type:
		Utils.ActionType.DAMAGE_PHYSICAL, Utils.ActionType.DAMAGE_MAGICAL, Utils.ActionType.DAMAGE_PURE:
			return action_id != _IGNITE_PERIODIC_ID
		_:
			return false


func _play_marker() -> void:
	var vfx: Node3D = _HIT_MARKER_VFX.instantiate()
	_owner.get_tree().current_scene.add_child(vfx)
	vfx.global_position = _owner.global_position
	_owner.get_tree().create_timer(_VFX_LIFETIME).timeout.connect(
		func() -> void:
			if is_instance_valid(vfx):
				vfx.queue_free()
	)
#endregion

#region ============================== Callbacks ==============================
func _on_owner_action_received(_source: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, _is_critical: bool) -> void:
	if value <= 0:
		return
	if not _is_direct_hit(action_type, action_id):
		return
	_play_marker()
#endregion
