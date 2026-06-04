extends Control

## Proto: tune each alteration icon's modulate (color + alpha) and intensity.
## Left = selectable list of every alteration icon; right = a shared ColorPicker
## + intensity slider acting on the selected icon. Save writes per-icon
## overrides to AlterationIconConfig. Accessing private members of tested
## components is allowed in proto scenes.

const CONFIG_PATH: String = "res://02_Entities/_Shared/Components/Alterations/AlterationIcon/alteration_icon_config.tres"
const ALTERATION_ICON_SCENE: PackedScene = preload("res://02_Entities/_Shared/Components/Alterations/AlterationIcon/alteration_icon.tscn")

@onready var _list: VBoxContainer = %List
@onready var _save_all_button: Button = %SaveAllButton
@onready var _reload_button: Button = %ReloadButton
@onready var _status: Label = %Status
@onready var _selected_label: Label = %SelectedLabel
@onready var _color_picker: ColorPicker = %ColorPicker
@onready var _intensity_slider: HSlider = %IntensitySlider
@onready var _intensity_value: Label = %IntensityValue
@onready var _save_selected_button: Button = %SaveSelected

var _config: AlterationIconConfig
var _rows: Array[Dictionary] = []
var _selected: Dictionary = {}
var _loading: bool = false


func _ready() -> void:
	_load_config()
	_build_rows()
	_save_all_button.pressed.connect(_on_save_all_pressed)
	_reload_button.pressed.connect(_on_reload_pressed)
	_save_selected_button.pressed.connect(_on_save_selected_pressed)
	_color_picker.color_changed.connect(_on_color_changed)
	_intensity_slider.value_changed.connect(_on_intensity_changed)
	if not _rows.is_empty():
		_select(_rows[0])


func _load_config() -> void:
	_config = null
	if ResourceLoader.exists(CONFIG_PATH):
		_config = ResourceLoader.load(CONFIG_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	if _config == null:
		_config = AlterationIconConfig.new()


func _build_rows() -> void:
	for child: Node in _list.get_children():
		child.queue_free()
	_rows.clear()
	_selected = {}

	for alteration: Alteration in AlterationsComponent.create_all_alterations():
		if alteration.icon == null:
			continue
		_add_row(alteration)


func _add_row(alteration: Alteration) -> void:
	var alt_type: int = alteration.type
	var alt_name: String = Alteration.Type.keys()[alt_type]

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var preview := ALTERATION_ICON_SCENE.instantiate() as AlterationIcon
	preview.custom_minimum_size = Vector2(48, 48)
	row.add_child(preview)

	var name_label := Label.new()
	name_label.custom_minimum_size = Vector2(150, 0)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.text = alt_name
	row.add_child(name_label)

	var edit_button := Button.new()
	edit_button.text = "Edit"
	row.add_child(edit_button)

	_list.add_child(row)

	# The preview is now in the tree, so its @onready members are resolved and
	# bind() can apply the per-alteration texture (calling bind before this point
	# silently no-ops because _texture is still null).
	preview.bind(alteration)
	preview.set_value(3)

	var color: Color = alteration.icon_modulate
	var intensity: float = alteration.icon_intensity
	if _config.has_override(alt_type):
		color = _config.get_color(alt_type)
		intensity = _config.get_intensity(alt_type)

	var row_data: Dictionary = {
		"type": alt_type,
		"name": alt_name,
		"preview": preview,
		"color": color,
		"intensity": intensity,
	}
	_rows.append(row_data)

	edit_button.pressed.connect(func() -> void: _select(row_data))
	_apply_preview(row_data)


func _select(row_data: Dictionary) -> void:
	_selected = row_data
	_loading = true
	_selected_label.text = "Selected: " + str(row_data["name"])
	_color_picker.color = row_data["color"]
	_intensity_slider.value = float(row_data["intensity"])
	_intensity_value.text = "%.2f" % float(row_data["intensity"])
	_loading = false


func _on_color_changed(color: Color) -> void:
	if _loading or _selected.is_empty():
		return
	_selected["color"] = color
	_apply_preview(_selected)


func _on_intensity_changed(value: float) -> void:
	if _loading or _selected.is_empty():
		return
	_selected["intensity"] = value
	_intensity_value.text = "%.2f" % value
	_apply_preview(_selected)


func _apply_preview(row_data: Dictionary) -> void:
	var color: Color = row_data["color"]
	var intensity: float = float(row_data["intensity"])
	var tint := Color(color.r * intensity, color.g * intensity, color.b * intensity, color.a)
	var preview := row_data["preview"] as AlterationIcon
	if preview._texture != null:
		preview._texture.modulate = tint


func _on_save_selected_pressed() -> void:
	if _selected.is_empty():
		return
	_store(_selected)
	_persist("Saved: " + str(_selected["name"]))


func _on_save_all_pressed() -> void:
	for row_data: Dictionary in _rows:
		_store(row_data)
	_persist("Saved all")


func _store(row_data: Dictionary) -> void:
	_config.set_override(row_data["type"] as int, row_data["color"], float(row_data["intensity"]))


func _persist(message: String) -> void:
	var err: int = ResourceSaver.save(_config, CONFIG_PATH)
	if err == OK:
		_config.take_over_path(CONFIG_PATH)
		Alteration.reload_icon_config()
		_status.text = message
	else:
		_status.text = "Save failed (err %d)" % err


func _on_reload_pressed() -> void:
	Alteration.reload_icon_config()
	_load_config()
	_build_rows()
	if not _rows.is_empty():
		_select(_rows[0])
	_status.text = "Reloaded from disk"
