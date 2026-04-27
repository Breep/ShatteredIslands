extends AnimationModule

@export var _feather_particles: GPUParticles3D


func _ready() -> void:
	super._ready()
	(_entity_owner as TRex).primal_shaked.connect(_on_primal_shaked)


func _on_primal_shaked() -> void:
	_on_entity_owner_ultimate_casted()
	if _feather_particles != null:
		_feather_particles.restart()
