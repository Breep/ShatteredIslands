class_name UiModifierViewerRow
extends HBoxContainer

# Une ligne du UiModifiersViewer : icône + libellé + valeur. Le viewer instancie
# cette scène pour chaque ligne (base et modifiers). La couleur de la valeur
# distingue bonus (vert) et malus (rouge).

#region ============================== Onready ==============================
@onready var _icon: TextureRect = %Icon
@onready var _name: Label = %Name
@onready var _value: Label = %Value
#endregion

#region ============================== Public functions ==============================
# value_color = null => on garde la couleur par défaut du thème (ligne de base).
func setup(icon: Texture2D, label: String, value: String, value_color: Variant = null) -> void:
	_icon.texture = icon
	_name.text = label
	_value.text = value
	if value_color is Color:
		_value.add_theme_color_override("font_color", value_color)
	else:
		_value.remove_theme_color_override("font_color")
#endregion
