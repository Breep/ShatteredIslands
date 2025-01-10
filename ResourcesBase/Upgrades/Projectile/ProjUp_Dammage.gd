extends ProjectileUpgrade
class_name ProjUp_Dammage

@export var dammage_increase: int

func apply_upgrade(projectile: Projectile):
	projectile.damage += dammage_increase
