extends ProjectileUpgrade
class_name ProjUp_AttackDammage

@export var attack_dammage_increase: int

func apply_upgrade(projectile: Projectile):
	projectile.dammage += attack_dammage_increase
	
func get_description():
	return "Increase auto-attack dammage by " + str(attack_dammage_increase)
