class_name AlterationIconConfig
extends Resource

## Dev-time tuning store for per-alteration icon modulate (hue + alpha) and
## intensity. Edited via the AlterationIcon proto scene and saved as a .tres in
## the repo; Alteration.get_icon_modulate() applies any override found here.
## Keyed by Alteration.Type value (int).

@export var colors: Dictionary = {}
@export var intensities: Dictionary = {}


func has_override(alteration_type: int) -> bool:
	return colors.has(alteration_type)


func get_color(alteration_type: int) -> Color:
	return colors.get(alteration_type, Color.WHITE)


func get_intensity(alteration_type: int) -> float:
	return intensities.get(alteration_type, 1.0)


func set_override(alteration_type: int, color: Color, intensity: float) -> void:
	colors[alteration_type] = color
	intensities[alteration_type] = intensity
