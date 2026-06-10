class_name FreeStraightLineTrajectory
extends ProjectileTrajectory

## Ligne droite "libre" horizontale : capte une direction unique à l'init
## (start -> cible, projetée sur le plan du sol), puis avance indéfiniment
## dessus sans jamais relire l'état de la cible. Contrairement à
## StraightTrajectory, ne suit pas une cible mobile et ne s'interrompt pas si
## la cible meurt. La composante verticale est ignorée : le projectile reste
## à sa hauteur de spawn (roulement au sol).

var _direction: Vector3


func _on_init() -> void:
	if is_instance_valid(_target):
		var to_target: Vector3 = _target.get_collision_center() - _start_pos
		to_target.y = 0.0
		_direction = to_target.normalized()
	if _projectile and _direction != Vector3.ZERO:
		_projectile.look_at(_start_pos + _direction)


func update(logic_pos: Vector3, delta: float) -> Vector3:
	return logic_pos + _direction * speed * delta
