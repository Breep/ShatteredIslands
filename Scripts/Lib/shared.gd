extends Node

const HEROES: Dictionary[Hero.HeroId, Hero] = {
	Hero.HeroId.ANCIENT_TREE: preload("res://Resources/Heroes/ancient_tree.tres"),
	Hero.HeroId.CYBORG: preload("res://Resources/Heroes/cyborg.tres"),
	Hero.HeroId.DR_BOOM: preload("res://Resources/Heroes/dr_boom.tres"),
	Hero.HeroId.ENERGY_MAN: preload("res://Resources/Heroes/energy_man.tres"),
	Hero.HeroId.LAURENT_KROFT: preload("res://Resources/Heroes/laurent_kroft.tres"),
	Hero.HeroId.MR_KRUMB: preload("res://Resources/Heroes/mr_krumb.tres"),
	Hero.HeroId.SIR_REGINALD: preload("res://Resources/Heroes/sir_reginald.tres"),
	Hero.HeroId.TONY_LE_BARDE: preload("res://Resources/Heroes/tony_le_barde.tres")
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























 
