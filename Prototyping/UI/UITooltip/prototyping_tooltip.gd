extends Control

var _tooltip: Tooltip

func _on_first_label_test_meta_hover_started(meta: Variant) -> void:
	_tooltip = TooltipManager.create_tooltip(meta)


func _on_first_label_test_meta_hover_ended(_meta: Variant) -> void:
	if _tooltip != null and not _tooltip.is_queued_for_deletion():
		_tooltip.start_self_free()
