extends Node3D

# VFX d'atterrissage auto-géré : déclenche ses particules one-shot au spawn puis se
# libère seul une fois leur durée de vie écoulée. L'appelant n'a qu'à l'instancier
# et le positionner, sans piloter les nodes de particules.

func _ready() -> void:
	var longest_lifetime := 0.0
	for node in find_children("*", "GPUParticles3D", true, false):
		var particles := node as GPUParticles3D
		particles.emitting = true
		longest_lifetime = maxf(longest_lifetime, particles.lifetime)
	get_tree().create_timer(longest_lifetime + 0.1).timeout.connect(queue_free)
