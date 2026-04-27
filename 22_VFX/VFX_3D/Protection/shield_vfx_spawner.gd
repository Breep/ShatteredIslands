class_name ShieldVfxSpawner

const SHIELD_VFX_SCENE: PackedScene = preload("res://22_VFX/VFX_3D/Protection/Scenes/VFX_Protection_4_Shield.tscn")

## Spawns a protection shield VFX centered on the given entity.
## The VFX plays its "Start" animation and auto-destroys after [param duration] seconds.
static func spawn_on(entity: Node3D, duration: float = 1.5) -> void:
	if not is_instance_valid(entity):
		return

	var vfx: Node3D = SHIELD_VFX_SCENE.instantiate()
	entity.add_child(vfx)
	vfx.position = Vector3.ZERO

	# Play the Start animation
	var anim_player: AnimationPlayer = vfx.get_node_or_null("AnimationPlayer")
	if anim_player:
		anim_player.play("Start")

	# Auto-destroy after duration
	var tree := entity.get_tree()
	if tree:
		tree.create_timer(duration).timeout.connect(func() -> void:
			if is_instance_valid(vfx):
				vfx.queue_free()
		)
