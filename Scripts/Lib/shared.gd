extends Node

const HEROES: Dictionary [Hero.HeroType, Hero] = {
	Hero.HeroType.ANCIENT_TREE: preload("res://Resources/Heroes/ancient_tree.tres"),
	Hero.HeroType.CYBORG: preload("res://Resources/Heroes/cyborg.tres"),
	Hero.HeroType.DR_BOOM: preload("res://Resources/Heroes/dr_boom.tres"),
	Hero.HeroType.ENERGY_MAN: preload("res://Resources/Heroes/energy_man.tres"),
	Hero.HeroType.LAURENT_KROFT: preload("res://Resources/Heroes/laurent_kroft.tres"),
	Hero.HeroType.MR_KRUMB: preload("res://Resources/Heroes/mr_krumb.tres"),
	Hero.HeroType.SIR_REGINALD: preload("res://Resources/Heroes/sir_reginald.tres"),
	Hero.HeroType.TONY_LE_BARDE: preload("res://Resources/Heroes/tony_le_barde.tres")
}

const PROJECTILES = {
	Projectile.ProjectileType.AA_ANCIENT_TREE: preload("res://Scenes/Heroes/AncientTree/projectile.tscn"),
	Projectile.ProjectileType.AA_CYBORG: preload("res://Scenes/Heroes/Cyborg/projectile.tscn"),
	Projectile.ProjectileType.AA_DR_BOOM: preload("res://Scenes/Heroes/DrBoom/projectile.tscn"),
	Projectile.ProjectileType.AA_ENERGY_MAN: preload("res://Scenes/Heroes/EnergyMan/projectile.tscn"),
	Projectile.ProjectileType.AA_LAURENT_KROFT: preload("res://Scenes/Heroes/LaurentKroft/projectile.tscn"),
	Projectile.ProjectileType.AA_MR_KRUMB: preload("res://Scenes/Heroes/MrKrumb/projectile.tscn"),
	Projectile.ProjectileType.AA_SIR_REGINALD: preload("res://Scenes/Heroes/SirReginald/projectile.tscn"),
	Projectile.ProjectileType.AA_TONY_LE_BARDE: preload("res://Scenes/Heroes/TonyLeBarde/projectile.tscn"),
	Projectile.ProjectileType.SPELL_FIRBOLT: preload("res://Scenes/SpellsAndProjectiles/default_projectile.tscn"),
	Projectile.ProjectileType.SPELL_SHADOW_BOLT: preload("res://Scenes/SpellsAndProjectiles/default_projectile.tscn")
}

func get_n_random_heroes(heroes_number: int) -> Array[Hero]:
	var random_heroes: Array[Hero]
	if heroes_number <= 0 or heroes_number > HEROES.size():
		printerr("Hero: Wrong heroes_number: ", heroes_number)
		return random_heroes
	
	var heroes: Array[Hero]
	for hero in HEROES.values():
		heroes.append(hero)
	
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in heroes_number:
		var random_index: int = rng.randi_range(0, heroes.size() - 1)
		random_heroes.append(heroes.get(random_index))
		heroes.remove_at(random_index)
	
	return random_heroes
