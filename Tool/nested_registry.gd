class_name NestedRegistry
extends RefCounted

var data: Dictionary = {}
# {
# main_key_1: {
#     secondary_key_1: value,
#     secondary_key_2: value },
# main_key_2: {
#     secondary_key_1: value,
#     secondary_key_2: value }
# }

func get_data(main_key: StringName, secondary_key: StringName, default: Variant = null) -> Variant:
	if data.has(main_key):
		# On utilise .get() sur le sous-dictionnaire pour la sécurité
		return data[main_key].get(secondary_key, default)
	return default


func update_data(main_key: StringName, secondary_key: StringName, value: Variant) -> void:
	if not data.has(main_key):
		data[main_key] = {}
	data[main_key][secondary_key] = value


func delete_data(main_key: StringName, secondary_key: StringName) -> void:
	if data.has(main_key):
		data[main_key].erase(secondary_key)
		if data[main_key].is_empty():
			data.erase(main_key)
