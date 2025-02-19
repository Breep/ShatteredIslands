class_name Module
extends Node

var _source: Character # Owner of the module

var _defense_manager: DefenseManager = null
var _fire_manager: FireManager = null
var _storm_manager: StormManager = null
var _heal_manager: SerenityManager = null
var _poison_manager: PoisonManager = null
var _movement_manager: MovementManager = null
var _shadow_manager: ShadowManager = null
var _life_manager: LifeManager = null

func init(source: Character) -> void:
	_source = source
