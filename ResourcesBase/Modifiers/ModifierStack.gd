extends Resource
class_name ModifierStack

enum ModifierStackType {
	ARMOR,
	NECROSIS,
	VULNERABILITY,
	IGNITE,
	POISON,
	STATIC_CHARGE,
	PACIFY
}

@export var name: String
@export var LIFE_TIME_MAX: float

var _stackNumber: int
var _lifeTime: float

func get_description():
	pass

func apply_effect(player: Player):
	pass
