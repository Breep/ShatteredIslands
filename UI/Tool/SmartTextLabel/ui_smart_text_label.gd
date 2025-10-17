class_name SmartTextLabel
extends RichTextLabel

# ============================== Private Variables ==============================

var _tooltip: Tooltip

@export_multiline var text_template: String

func _ready() -> void:
	meta_hover_started.connect(_on_meta_hover_started)
	meta_hover_ended.connect(_on_meta_hover_ended)
	fit_content = true
	bbcode_enabled = true
	meta_underlined = false
	
	if text_template.is_empty():
		text = TooltipManager.render_bbcode(text)
	else:
		text = TooltipManager.render_bbcode(text_template)

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
