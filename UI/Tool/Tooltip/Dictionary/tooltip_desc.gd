class_name TooltipDesc
extends Resource

@export var key: StringName
@export var display_name: String
@export_multiline var description: String

# Force icons to come from the theme via a key, not a free Texture:
@export_enum("DEFAULT_ICON","POISON_FAMILY_ICON","POISON_STACK_ICON","POISON_DAMAGE_ICON")
var icon_key := "DEFAULT_ICON"
