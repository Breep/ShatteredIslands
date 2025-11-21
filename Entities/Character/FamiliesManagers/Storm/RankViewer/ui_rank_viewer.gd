class_name UIRankViewer
extends Control



var _owner_character: Character
var _blink_tween: Tween

@onready var _label: Label = %Label

func connect_entity(entity: Entity) -> void:
	if entity == null or not (entity is Character):
		hide()
		return
	
	var new_character: Character = entity as Character
	if _owner_character != null and _owner_character.get_rank_changed_signal().is_connected(_on_rank_changed):
		_owner_character.get_rank_changed_signal().disconnect(_on_rank_changed)
	
	_owner_character = new_character
	_owner_character.get_rank_changed_signal().connect(_on_rank_changed)


func _ready() -> void:
	_label.pivot_offset = _label.size / 2


func _on_rank_changed(new_rank: StormManager.Rank) -> void:
	_stop_blinking()
	_play_scale_bump()
	match new_rank:
		StormManager.Rank.D: _label.text = "D"
		StormManager.Rank.C: _label.text = "C"
		StormManager.Rank.B: _label.text = "B"
		StormManager.Rank.A: _label.text = "A"
		StormManager.Rank.S:
			_label.text = "S"
			_start_blinking()


#region ===== ANIMATIONS =====
func _play_scale_bump() -> void:
	_label.pivot_offset = _label.size / 2
	
	var t := create_tween()
	t.set_trans(Tween.TRANS_ELASTIC)
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(_label, "scale", Vector2(1.25, 1.25), 0.15)
	t.tween_property(_label, "scale", Vector2.ONE, 0.25)


func _start_blinking() -> void:
	if _blink_tween != null and _blink_tween.is_running():
		return
	_blink_tween = create_tween()
	_blink_tween.set_loops()
	_blink_tween.tween_property(_label, "modulate", Color.NAVY_BLUE, 0.25)
	_blink_tween.tween_property(_label, "modulate", Color.WHITE, 0.25)


func _stop_blinking() -> void:
	if _blink_tween != null:
		_blink_tween.stop()
	_blink_tween = null
	_label.modulate.a = 1.0
#endregion
