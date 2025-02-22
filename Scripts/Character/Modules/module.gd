class_name Module
extends Node

var _source: Character # Owner of the module

var _attack_manager: AttackManager = null
var _defense_manager: DefenseManager = null
var _fire_manager: FireManager = null
var _storm_manager: StormManager = null
var _heal_manager: SerenityManager = null
var _poison_manager: PoisonManager = null
var _shadow_manager: ShadowManager = null
var _life_manager: LifeManager = null

func init(source: Character, families_managers: Dictionary = {}) -> void:
	_source = source
	
	_attack_manager = families_managers[Family.FamilyType.Attack]
	_defense_manager = families_managers[Family.FamilyType.Defense]
	_fire_manager = families_managers[Family.FamilyType.Fire]
	_storm_manager = families_managers[Family.FamilyType.Storm]
	_heal_manager = families_managers[Family.FamilyType.Serenity]
	_poison_manager = families_managers[Family.FamilyType.Poison]
	_shadow_manager = families_managers[Family.FamilyType.Shadow]
	_life_manager = families_managers[Family.FamilyType.Life]
	
	_specific_init()


func _specific_init() -> void:
	pass
