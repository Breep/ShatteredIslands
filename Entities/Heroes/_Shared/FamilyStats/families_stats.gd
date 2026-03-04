class_name FamiliesStats
extends Resource

var warrior: FamilyWarriorStats
var engineer: FamilyEngineerStats
var ardent_celestial: FamilyArdentCelestialStats
var storm_caller: FamilyStormCallerStats
var light: FamilyLightStats
var colossus: FamilyColossusStats
var poison: FamilyPoisonStats
var necro: FamilyNecroStats
var chicken_lord: FamilyChickenLordStats

func _init() -> void:
	warrior = FamilyWarriorStats.new()
	engineer = FamilyEngineerStats.new()
	ardent_celestial = FamilyArdentCelestialStats.new()
	storm_caller = FamilyStormCallerStats.new()
	light = FamilyLightStats.new()
	colossus = FamilyColossusStats.new()
	poison = FamilyPoisonStats.new()
	necro = FamilyNecroStats.new()
	chicken_lord = FamilyChickenLordStats.new()
