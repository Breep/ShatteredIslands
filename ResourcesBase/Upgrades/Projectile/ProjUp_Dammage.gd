extends ProjectileUpgrade
class_name ProjUp_Dammage

@export var dammage_increase: int

func apply_upgrade(projectile: Projectile):
	projectile.dammage += dammage_increase
	
func get_description():
	return "Increase auto-attack dammage by " + str(dammage_increase)
