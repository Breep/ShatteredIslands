class_name TauntAlteration
extends StateAlteration

## State debuff: target is prioritized by enemy targeting. While active, the
## owner gains DEFENSE_BONUS stacks of DefenseAlteration (auto-applied on
## activation, removed on expiry/cancel).

const DEFENSE_BONUS: float = 30.0

var _bonus_active: bool = false


func _init() -> void:
	stackable = false
	type = Type.TAUNT
	polarity = Polarity.DEBUFF
	id = &"Taunt"
	display_color = Color.CRIMSON
	display_mode = DisplayMode.CUSTOM


func _on_added() -> void:
	if _bonus_active: return
	if _owner == null or _owner.alterations == null: return
	_owner.alterations.add_stack(Alteration.Type.DEFENSE, DEFENSE_BONUS, _owner, &"Taunt")
	_bonus_active = true


func _on_removed() -> void:
	if not _bonus_active: return
	if _owner == null or _owner.alterations == null: return
	_owner.alterations.remove_stack(Alteration.Type.DEFENSE, DEFENSE_BONUS)
	_bonus_active = false
