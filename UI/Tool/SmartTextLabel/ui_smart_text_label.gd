class_name SmartTextLabel
extends RichTextLabel

var _tooltip: Tooltip

func _on_meta_hover_started(meta: Variant) -> void:
	if _tooltip == null:
		_tooltip = TooltipManager.create_tooltip(meta)
		_tooltip.queue_freed.connect(_on_tooltip_queue_freed)


func _on_meta_hover_ended(_meta: Variant) -> void:
	if _tooltip != null and not _tooltip.is_queued_for_deletion():
		_tooltip.start_self_free()


func _on_tooltip_queue_freed() -> void:
	_tooltip = null
