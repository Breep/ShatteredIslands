# Ferme la boucle de vie des entités éphémères.
# Sur signal `died` de l'owner, planifie l'animation de despawn (shrink + queue_free)
# après `_owner._despawn_timer` secondes via le battle_callback_registry.
# No-op si `_despawn_timer <= 0` (entités persistantes : héros, bâtiments fixes).
class_name DespawnAnimationComponent
extends EntityComponent

@export var _despawn_timer: float = 5.0

#region ============================== Node base functions ==============================
func _enter_tree() -> void:
	if _owner == null: return
	if _owner.despawn != null and _owner.despawn != self:
		Verbose.trace("Override: DespawnAnimationComponent on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.despawn.queue_free()
	_owner.despawn = self


func _ready() -> void:
	super._ready()
	if _owner == null or _owner.despawn != self:
		return
	_owner.died.connect(_on_owner_died)
#endregion


#region ============================== Public functions ==============================
# Joue immédiatement l'animation de despawn et queue_free l'owner.
# Appelable sans passer par le signal `died` (ex: ChickenEgg après hatch).
func play_despawn_animation() -> void:
	var visual: Node3D = _owner._visual_3d
	if not is_instance_valid(visual):
		_owner.queue_free()
		return
	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector3.ONE * 1.2, 0.1) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(visual, "scale", Vector3.ZERO, 0.25) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(_owner.queue_free)
#endregion


#region ============================== Callbacks ==============================
func _on_owner_died() -> void:
	if _despawn_timer <= 0.0:
		return
	if _owner.battle_callback_registry == null:
		return
	_owner.battle_callback_registry.register_oneshot(_despawn_timer, play_despawn_animation)
#endregion
