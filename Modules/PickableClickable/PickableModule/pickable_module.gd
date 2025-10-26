class_name PickableModule
extends Node

# ============================== Public variable ==============================

const PICKABLE_META: String = "pickable_module"
var pickable_locked: bool = false # True if the object can't be picked up

# ============================== Export ==============================

@export var _owner: Node3D
@export var _pickable_collider: PickableCollider
@export var _spawn_area_checker: SpawnAreaChecker

# ============================== Private variables ==============================

var _is_picked_up: bool = false
var _is_constrained: bool = false
var _is_on_owner_spawn_area: bool = false
var _is_on_other_spawn_area: bool = false

const SPAWN_AREA_MASK: int = 4

# ============================== Node base functions ==============================

func _ready() -> void:
	if _owner == null:
		printerr("ClickableModule: No owner set [", get_path(), "]")
		return
	
	_connect_to_owner()
	
	if _pickable_collider != null:
		_pickable_collider.overlapped.connect(_on_pickable_collider_overlapped)
		_pickable_collider.freed.connect(_on_pickable_collider_freed)
	
	if _spawn_area_checker != null:
		_spawn_area_checker.team = _owner.team # TODO Maybe find a safer way to do this shit ?
		_spawn_area_checker.owner_team_spawn_area_overlapped.connect(_on_spawn_area_checker_owner_team_spawn_area_overlapped)
		_spawn_area_checker.owner_team_spawn_area_freed.connect(_on_spawn_area_checker_owner_team_spawn_area_freed)
		_spawn_area_checker.other_team_spawn_area_overlapped.connect(_on_spawn_area_checker_other_team_spawn_area_overlapped)
		_spawn_area_checker.other_team_spawn_area_freed.connect(_on_spawn_area_checker_other_team_spawn_area_freed)
	else:
		_is_on_owner_spawn_area = true
	
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)

# ============================== Public functions ==============================

func pick() -> bool:
	if _is_picked_up or _is_locked(): return false
	_is_picked_up = true
	return _pick()


func drop() -> bool:
	if not _is_picked_up or _is_locked(): return false
	if _drop():
		_is_picked_up = false
		return true
	else:
		return false

# ============================== Private functions ==============================

func _connect_to_owner() -> void:
	_owner.set_meta(PICKABLE_META, self)


func _pick() -> bool:
	if _owner.has_method("_on_clickable_module_picked"):
		_owner.call("_on_clickable_module_picked")
	return true


func _drop() -> bool:
	if _owner.has_method("_on_clickable_module_dropped"): # TODO wtf c'est un peu nimps ici faut changer ça
		_owner.call("_on_clickable_module_dropped")
	return _can_be_dropped()


func _can_be_dropped() -> bool:
	if _owner.has_method("_on_clickable_module_override_can_be_dropped"):
		return _owner.call("_on_clickable_module_override_can_be_dropped")
	return _default_can_be_dropped()


func _is_locked() -> bool:
	if pickable_locked: return true
	if multiplayer.is_server(): return false
	if _owner.get_multiplayer_authority() != PlayerManager.get_local_player().id: return true
	return false

# ============================== DEFAULT "can be dropped" check ==============================

func _default_can_be_dropped() -> bool:
	var can_be_dropped: bool = true
	if _is_constrained: can_be_dropped = false
	if not _is_on_owner_spawn_area: can_be_dropped = false
	if _is_on_other_spawn_area: can_be_dropped = false
	return can_be_dropped

# ============================== Callback ==============================

func _on_pickable_collider_freed() -> void:
	_is_constrained = false


func _on_pickable_collider_overlapped() -> void:
	_is_constrained = true


func _on_spawn_area_checker_owner_team_spawn_area_overlapped() -> void:
	_is_on_owner_spawn_area = true


func _on_spawn_area_checker_owner_team_spawn_area_freed() -> void:
	_is_on_owner_spawn_area = false


func _on_spawn_area_checker_other_team_spawn_area_overlapped() -> void:
	_is_on_other_spawn_area = true


func _on_spawn_area_checker_other_team_spawn_area_freed() -> void:
	_is_on_other_spawn_area = false


func _on_game_manager_game_state_changed(game_state: Game.GameState) -> void:
	if _spawn_area_checker == null: return
	match game_state:
		Game.GameState.FIGHTING_POSITIONING:
			pickable_locked = false
			_spawn_area_checker.team = _owner.team
		Game.GameState.FIGHTING_COUNTDOWN:
			pickable_locked = true
		Game.GameState.FIGHTING_NORMAL:
			pickable_locked = true 
