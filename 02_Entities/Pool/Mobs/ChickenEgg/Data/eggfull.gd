extends Node3D

const ENGINEER_SHADER: ShaderMaterial = preload("res://02_Entities/Summons/ChickenLord/_Shared/gifted_engineer_shader.tres")

@onready var _mesh: MeshInstance3D = %egg_mesh

func set_shader(chicken_type: Chicken.Type) -> void:
	match chicken_type:
		Chicken.Type.GIFTED_ENGINEER:
			var mat = _mesh.get_active_material(0)
			if mat!= null:
				#mat = mat.duplicate(true)
				mat.next_pass = ENGINEER_SHADER.duplicate()
