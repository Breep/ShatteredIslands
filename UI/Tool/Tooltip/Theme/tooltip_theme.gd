class_name TooltipTheme
extends Resource

@export_group("Icons")
@export_subgroup("Stack types")
@export var ARMOR_STACK_ICON: CompressedTexture2D
@export var POISON_STACK_ICON: CompressedTexture2D
@export var IGNITE_STACK_ICON: CompressedTexture2D

@export_subgroup("Damage types")
@export var MAGICAL_DAMAGE_ICON: CompressedTexture2D
@export var PHYSICAL_DAMAGE_ICON: CompressedTexture2D
@export var POISON_DAMAGE_ICON: CompressedTexture2D

@export_subgroup("Families")
@export var POISON_FAMILY_ICON: CompressedTexture2D

@export_subgroup("Misc")
@export var DEFAULT_ICON: CompressedTexture2D

@export_group("Colors")
@export var POISON_COLOR: Color = Color.DARK_OLIVE_GREEN
@export var FIRE_COLOR: Color = Color.DARK_RED
@export var DEFAULT_COLOR: Color = Color.WHITE


func color_html(color_key: String, include_alpha: bool = true) -> String:
	var color = get(color_key)
	if color != null:
		return color.to_html(include_alpha)
	else:
		return DEFAULT_COLOR.to_html(include_alpha)


func icon(icon_key: String) -> Texture2D:
	var icon_texture = get(icon_key)
	if icon_texture != null:
		return icon_texture
	else:
		return DEFAULT_ICON
