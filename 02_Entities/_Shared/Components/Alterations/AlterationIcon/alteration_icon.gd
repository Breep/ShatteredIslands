class_name AlterationIcon
extends Control

## Small reusable widget shown in SimpleInfoPanel2D's alterations container.
## Carries an alteration's icon plus a stack/time value; the icon texture is
## tinted via the alteration's configurable modulate (hue + intensity + alpha).

@onready var _texture: TextureRect = %Texture
@onready var _label: Label = %Label

var _alteration: Alteration


func bind(alteration: Alteration) -> void:
	_alteration = alteration
	if _texture != null:
		_texture.texture = alteration.icon
		# With an icon: apply its configurable modulate (hue + intensity + alpha).
		# Without one: tint the empty rect with display_color so it still reads.
		_texture.modulate = alteration.get_icon_modulate() if alteration.icon != null else alteration.display_color


func set_value(value: Variant) -> void:
	if _label == null: return
	if value is bool:
		_label.text = "INF" if value else ""
	elif value is float or value is int:
		_label.text = "%d" % int(value)
	else:
		_label.text = str(value)
