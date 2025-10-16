class_name SmartTextLabel
extends RichTextLabel

# ============================== Private Variables ==============================

var _tooltip: Tooltip
var _raw_text: String

@export_multiline var text_template: String:
	set(value):
		if value.is_empty(): return
		_raw_text = value
		if Engine.is_editor_hint():
			text = value
		else:
			text = TooltipManager.render_bbcode(value)
	get:
		return _raw_text


func _ready() -> void:
	text = TooltipManager.render_bbcode(text)

# ============================== Callbacks ==============================

func _on_meta_hover_started(meta: Variant) -> void:
	if _tooltip == null:
		_tooltip = TooltipManager.create_tooltip(meta)
		if _tooltip == null:
			return
		_tooltip.queue_freed.connect(_on_tooltip_queue_freed)


func _on_meta_hover_ended(_meta: Variant) -> void:
	if _tooltip != null and not _tooltip.is_queued_for_deletion():
		_tooltip.start_self_free()


func _on_tooltip_queue_freed() -> void:
	_tooltip = null
