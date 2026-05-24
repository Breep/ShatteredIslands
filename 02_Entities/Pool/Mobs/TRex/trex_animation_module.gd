extends AnimationComponent

@export var _feather_particles: GPUParticles3D

func _ready() -> void:
	super._ready()
	(_owner as TRex).primal_shaked.connect(_on_primal_shaked)


func _on_primal_shaked() -> void:
	if _feather_particles != null:
		_feather_particles.restart()
