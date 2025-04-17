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
	
	_attack_manager = families_managers[Family.FamilyType.ATTACK]
	_defense_manager = families_managers[Family.FamilyType.DEFENSE]
	_fire_manager = families_managers[Family.FamilyType.FIRE]
	_storm_manager = families_managers[Family.FamilyType.STORM]
	_heal_manager = families_managers[Family.FamilyType.SERENITY]
	_poison_manager = families_managers[Family.FamilyType.POISON]
	_shadow_manager = families_managers[Family.FamilyType.SHADOW]
	_life_manager = families_managers[Family.FamilyType.LIFE]
	
	_specific_init()


func _specific_init() -> void:
	pass
