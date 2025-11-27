class_name SmartTextLabel
extends RichTextLabel

# ============================== Private Variables ==============================

var _tooltip: Tooltip

# ============================== Public Variables ==============================

var _text_raw: String
@export_multiline var text_raw: String:
	get: return _text_raw
	set(value):
		if value.is_empty(): return
		_text_raw = value
		_generate_text()

# ============================== Node base functions ==============================

func _ready() -> void:
	meta_hover_started.connect(_on_meta_hover_started)
	meta_hover_ended.connect(_on_meta_hover_ended)
	fit_content = true
	bbcode_enabled = true
	meta_underlined = false
	_generate_text()

# ============================== Private functions ==============================

func _generate_text() -> void:
	if text_raw.is_empty():
		text = TooltipManager.render_bbcode(text)
	else:
		text = TooltipManager.render_bbcode(text_raw)

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
