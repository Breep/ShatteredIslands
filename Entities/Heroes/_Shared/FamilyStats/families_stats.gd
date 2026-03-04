class_name FamiliesStats
extends Resource

var auto_attack: FamilyAttackStats
var defense: FamilyDefenseStats
var fire: FamilyFireStats
var storm: FamilyStormStats
var serenity: FamilySerenityStats
var life: FamilyLifeStats
var poison: FamilyPoisonStats
var necro: FamilyNecroStats
var chicken: FamilyChickenStats

func _init() -> void:
	auto_attack = FamilyAttackStats.new()
	defense = FamilyDefenseStats.new()
	fire = FamilyFireStats.new()
	storm = FamilyStormStats.new()
	serenity = FamilySerenityStats.new()
	life = FamilyLifeStats.new()
	poison = FamilyPoisonStats.new()
	necro = FamilyNecroStats.new()
	chicken = FamilyChickenStats.new()
