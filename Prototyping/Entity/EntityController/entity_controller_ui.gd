extends Control

@onready var _targeting_strat_choice: OptionButton = %TargetingStratChoice

func _ready() -> void:
	var i = 0
	for targeting_strategy: String in TargetModule.TargettingStrategy.keys():
		_targeting_strat_choice.add_item(targeting_strategy, i)
	pass
