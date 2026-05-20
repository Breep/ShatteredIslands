# Ferme la boucle de vie des entités éphémères (summons par défaut).
# Sur signal `died` de l'owner, planifie l'animation de despawn (shrink + queue_free)
# après `_owner._despawn_timer` secondes via le periodic_timer_registry.
# No-op si `_despawn_timer <= 0` (entités persistantes : héros, bâtiments fixes).
class_name DespawnModule
extends EntityComponent


#region ============================== Node base functions ==============================
func _ready() -> void:
	if _owner == null:
		Verbose.error("DespawnModule: _owner is null! Misconfigured.", Verbose.Category.ENTITY_MODULE)
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
	if _owner._despawn_timer <= 0.0:
		return
	if _owner.periodic_timer_registry == null:
		return
	_owner.periodic_timer_registry.register_oneshot(_owner._despawn_timer, play_despawn_animation)
#endregion
