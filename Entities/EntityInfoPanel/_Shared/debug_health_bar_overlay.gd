class_name DebugHealthBarOverlay

static var _visible: bool = false
static var _callbacks: Array[Callable] = []


static func is_visible() -> bool:
	return _visible


static func register(callback: Callable) -> void:
	_callbacks.append(callback)


static func unregister(callback: Callable) -> void:
	_callbacks.erase(callback)


static func toggle() -> void:
	_visible = not _visible
	for cb: Callable in _callbacks:
		if cb.is_valid():
			cb.call(_visible)
