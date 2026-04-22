class_name AlterationIcon
extends Control

## Small reusable widget shown in SimpleInfoPanel2D's alterations container.
## Carries an alteration's icon plus a stack/time value; the label's tint comes
## from the alteration's display_color (applied via modulate).

@onready var _texture: TextureRect = %Texture
@onready var _label: Label = %Label

var _alteration: Alteration


func bind(alteration: Alteration) -> void:
	_alteration = alteration
	if _texture != null:
		_texture.texture = alteration.icon
		# When no icon asset, tint the (empty) rect with the alteration color so
		# the widget still reads at a glance.
		_texture.modulate = alteration.display_color if alteration.icon == null else Color.WHITE
	#if _label != null:
		#_label.modulate = alteration.display_color


func set_value(value: Variant) -> void:
	if _label == null: return
	if value is bool:
		_label.text = "INF" if value else ""
	elif value is float or value is int:
		_label.text = "%d" % int(value)
	else:
		_label.text = str(value)
