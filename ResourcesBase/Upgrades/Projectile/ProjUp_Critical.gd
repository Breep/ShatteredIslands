extends ProjectileUpgrade
class_name ProjUp_AttackDammage

@export var attack_dammage_increase: int

func apply_upgrade(projectile: Projectile):
	projectile.damage += attack_dammage_increase
