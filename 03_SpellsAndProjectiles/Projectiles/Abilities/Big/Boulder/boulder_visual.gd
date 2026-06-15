# Visuel du Boulder : porte le mesh roulant et ses deux effets de particules —
# une traînée de terre projetée à l'arrière pendant le roulement, et un nuage
# de poussière one-shot joué à l'impact contre un mur. Piloté par boulder.gd.
class_name BoulderVisual
extends Node3D

#region ============================== Onready ==============================
@onready var _mesh: MeshInstance3D = %MeshInstance3D
@onready var _dirt_trail: GPUParticles3D = %DirtTrail
@onready var _impact_dust: GPUParticles3D = %ImpactDust
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	_dirt_trail.emitting = true
#endregion

#region ============================== Public functions ==============================
# Roule le mesh autour de son axe X local. L'angle signé est calculé par
# boulder.gd à partir de la vitesse linéaire et du rayon mis à l'échelle.
func roll(angle: float) -> void:
	_mesh.rotate_object_local(Vector3.RIGHT, -angle)


# Coupe la traînée puis détache le nuage de poussière pour qu'il termine son
# cycle one-shot malgré la destruction imminente du boulder, et se libère seul.
func play_impact() -> void:
	_dirt_trail.emitting = false
	var world: Node = get_tree().current_scene
	if world == null: return
	_impact_dust.reparent(world)
	_impact_dust.finished.connect(_impact_dust.queue_free)
	_impact_dust.restart()
#endregion
