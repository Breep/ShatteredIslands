class_name BlockAlteration
extends StackAlteration

## Buff stack: each stack absorbs one non-PURE damage instance (including DoT
## ticks). Consumption is driven by the damage receiver via `try_consume`.


func _init() -> void:
	type = Type.BLOCK
	polarity = Polarity.BUFF
	id = &"Block"
	display_color = Color.WHITE_SMOKE
	icon = preload("res://02_Entities/_Shared/Modules//AlterationsModule/AlterationIcon/Icons/block_icon.png")


## Attempt to consume 1 block stack against an incoming damage instance.
## Returns true if the damage should be fully blocked.
func try_consume(damage_type: Utils.ActionType) -> bool:
	if damage_type == Utils.ActionType.DAMAGE_PURE: return false
	if _stacks < 1: return false
	_stacks -= 1
	return true
