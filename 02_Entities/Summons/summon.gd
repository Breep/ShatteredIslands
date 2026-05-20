# Thin wrapper compatibilité pour les archétypes summon.
# Pose le default `_despawn_timer = 5.0` (vs 0 hérité d'Entity = pas de despawn).
# Le reste du comportement summon (summoner, despawn anim, register dans bds_registry,
# hide/show health_bar) vit maintenant sur Entity + DespawnModule.
# Sera supprimée à l'étape 9 une fois que chaque summon scene posera son timer
# explicitement (en .tscn ou en .gd).
class_name Summon
extends Entity


func _init() -> void:
	super._init()
	_despawn_timer = 5.0
	category = Category.SUMMON
