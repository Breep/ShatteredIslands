class_name NestedRegistry
extends Resource

@export var _data: Dictionary = {}
# {
# main_key_1: {
#     secondary_key_1: value,
#     secondary_key_2: value },
# main_key_2: {
#     secondary_key_1: value,
#     secondary_key_2: value }
# }

func get_data(main_key: StringName, secondary_key: StringName, default: Variant = null) -> Variant:
	if _data.has(main_key):
		if _data[main_key].has(secondary_key):
			return _data[main_key][secondary_key]
	Verbose.warn("Trying to access to a non existant data [" + main_key + "][" + secondary_key + "]", Verbose.Category.NESTED_REGISTRY)
	return default


func update_data(main_key: StringName, secondary_key: StringName, value: Variant) -> void:
	if not _data.has(main_key):
		_data[main_key] = {}
	_data[main_key][secondary_key] = value
	Verbose.trace("Update [" + main_key + "][" + secondary_key + "] " + str(value), Verbose.Category.NESTED_REGISTRY)


func delete_data(main_key: StringName, secondary_key: StringName) -> void:
	if _data.has(main_key):
		_data[main_key].erase(secondary_key)
		if _data[main_key].is_empty():
			_data.erase(main_key)
	Verbose.trace("Delete [" + main_key + "][" + secondary_key + "]", Verbose.Category.NESTED_REGISTRY)


func increment_data(main_key: StringName, secondary_key: StringName, value: Variant) -> void:
	if not _data.has(main_key):
		_data[main_key] = {}
	if not _data[main_key].has(secondary_key):
		_data[main_key][secondary_key] = 0
	_data[main_key][secondary_key] += value
	#Verbose.trace("Increment [" + main_key + "][" + secondary_key + "] " + _data[main_key][secondary_key], Verbose.Category.NESTED_REGISTRY)


func override(new_data: Dictionary) -> void:
	_data = new_data
