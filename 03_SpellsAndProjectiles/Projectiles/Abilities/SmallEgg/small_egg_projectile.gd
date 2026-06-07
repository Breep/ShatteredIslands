extends Projectile


func _on_hit(hit_target: Entity) -> void:
	AudioManager.play_3d("egg_hit", global_position, 0.95)
	super._on_hit(hit_target)
