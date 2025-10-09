extends Control

var time_elapsed: float = 0.0
var duration: float = 2.0
var wave_duration: float = 5.0   # Durée d’une vague (réglable)
var wave_strength: float = 5.0   # Intensité max de la vague

@onready var light: PointLight2D = $VFX_focus_energy3/PointLight2D
@onready var flare: Node2D = $VFX_focus_energy3/flare2
@onready var sparks: GPUParticles2D = $VFX_focus_energy3/sparks12

func _process(delta: float) -> void:
	var mat := material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("mouse_position", get_viewport().get_mouse_position())
		mat.set_shader_parameter("sprite_position", global_position)

	# Avancer le temps (max 2 sec)
	if time_elapsed < duration:
		time_elapsed += delta
		var t: float = clamp(time_elapsed / duration, 0.0, 1.0)

		# Lumière -> oscillation en vagues de 5s (et décroissance)
		var wave: float = (sin((time_elapsed / wave_duration) * TAU) + 1.0) / 2.0
		light.energy = lerp(10.0, 0.0, t) + wave * wave_strength

		# Flare -> très fort puis se stabilise
		flare.scale = Vector2.ONE * lerp(3.0, 0.0, t)

		# Sparks -> 600 au départ, 0 au bout de 2 sec
		if sparks.process_material:
			sparks.process_material.set("amount", int(lerp(600.0, 0.0, t)))
