class_name UIGlossary
extends Control

# Écran glossaire joueur : affiche une liste d'entrées (GlossaryEntry) regroupées
# par catégorie, avec recherche texte et filtres de catégorie. Le rendu réutilise
# le TooltipManager pour les couleurs et icônes inline, afin que le wording colle
# aux tooltips en jeu. Générique : la source des entrées est fournie via populate().

#region ============================== Signals ==============================
signal closed
#endregion


#region ============================== Private vars ==============================
const _ALL_CATEGORY := "Tous"
const _TERM_FONT_SIZE := 22
const _DESC_FONT_SIZE := 17

var _entries: Array[GlossaryEntry] = []
var _active_category: String = _ALL_CATEGORY
var _search_query: String = ""
var _strip_markup := RegEx.new()
#endregion


#region ============================== Local nodes ==============================
@onready var _search_edit: LineEdit = %SearchEdit
@onready var _category_bar: HBoxContainer = %CategoryBar
@onready var _entry_list: VBoxContainer = %EntryList
@onready var _close_button: Button = %CloseButton
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	_strip_markup.compile("\\[.*?\\]|\\{\\{.*?\\}\\}")
	_search_edit.text_changed.connect(_on_search_changed)
	_close_button.pressed.connect(close)
#endregion


#region ============================== Public functions ==============================
func populate(entries: Array[GlossaryEntry]) -> void:
	_entries = entries
	_build_category_bar()
	_refresh()


func open() -> void:
	show()


func close() -> void:
	hide()
	closed.emit()


func filter_category(category: String) -> void:
	_active_category = category
	for button in _category_bar.get_children():
		if button is Button:
			button.button_pressed = button.text == category
	_refresh()


func search(text: String) -> void:
	_search_query = text
	if _search_edit.text != text:
		_search_edit.text = text
	_refresh()
#endregion


#region ============================== Private functions ==============================
func _build_category_bar() -> void:
	for child in _category_bar.get_children():
		child.queue_free()

	var group := ButtonGroup.new()
	var categories: Array[String] = [_ALL_CATEGORY]
	for entry in _entries:
		if entry.category not in categories:
			categories.append(entry.category)

	for category in categories:
		var button := Button.new()
		button.text = category
		button.toggle_mode = true
		button.button_group = group
		button.button_pressed = category == _active_category
		button.pressed.connect(filter_category.bind(category))
		_category_bar.add_child(button)


func _refresh() -> void:
	for child in _entry_list.get_children():
		child.queue_free()

	var current_category := ""
	for entry in _entries:
		if _active_category != _ALL_CATEGORY and entry.category != _active_category:
			continue
		if not _matches_search(entry):
			continue
		if entry.category != current_category:
			current_category = entry.category
			_entry_list.add_child(_make_header(current_category))
		_entry_list.add_child(_make_row(entry))


func _matches_search(entry: GlossaryEntry) -> bool:
	if _search_query.strip_edges().is_empty():
		return true
	var haystack := "%s %s %s" % [_strip(entry.term), _strip(entry.description), entry.category]
	return haystack.to_lower().contains(_search_query.to_lower())


func _strip(text: String) -> String:
	return _strip_markup.sub(text, "", true)


func _make_header(category: String) -> Control:
	var label := Label.new()
	label.text = category
	label.add_theme_font_size_override("font_size", _TERM_FONT_SIZE + 4)
	label.add_theme_constant_override("outline_size", 6)
	return label


func _make_row(entry: GlossaryEntry) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		margin.add_theme_constant_override(side, 8)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	margin.add_child(row)

	if not entry.icon_key.is_empty():
		row.add_child(_make_icon(entry.icon_key))

	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(column)
	column.add_child(_make_label(entry.term, _TERM_FONT_SIZE, true))
	column.add_child(_make_label(entry.description, _DESC_FONT_SIZE, false))

	return panel


func _make_icon(icon_key: String) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = TooltipManager.get_icon(icon_key)
	icon.custom_minimum_size = Vector2(36, 36)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return icon


func _make_label(text: String, font_size: int, is_title: bool) -> RichTextLabel:
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("normal_font_size", font_size)
	if is_title:
		label.add_theme_font_size_override("bold_font_size", font_size)
		label.text = "[b]%s[/b]" % TooltipManager.render_bbcode(text, font_size)
	else:
		label.text = TooltipManager.render_bbcode(text, font_size)
	return label
#endregion


#region ============================== Callbacks ==============================
func _on_search_changed(text: String) -> void:
	_search_query = text
	_refresh()
#endregion
