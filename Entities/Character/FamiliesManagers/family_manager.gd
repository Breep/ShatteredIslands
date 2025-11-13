class_name FamilyManager
extends Node

@export var _owner: Character # Ref to character owner
@export var _action_module: ActionModule

var _optional_timers: Array[Timer]
var _optional_spells: Array[Node]

var _player: Player
var _family_type: Family.FamilyType

func _ready() -> void:
	if _owner == null:
		printerr("FamilyManager: Need a character owner [", get_path(), "]")
	
	if _action_module == null:
		printerr("FamilyManager: Need a ref to the character owner ActionModule [", get_path(), "]")
	
	_optional_spells.clear()
	_optional_timers.clear()

func connect_to_player(player: Player) -> void:
	_player = player
	_player.deck.has_changed.connect(_on_owner_player_deck_has_changed)


func init() -> void:
	_specific_init()


func start() -> void:
	printerr("FamilyManager: virtual start() called [", get_path(), "]")


func stop() -> void:
	printerr("FamilyManager: virtual stop() called [", get_path(), "]")


func _specific_init() -> void:
	pass


func _on_owner_player_deck_has_changed() -> void:
	var deck: PlayerDeck = _owner.player.deck
	print("family [", _family_type, "] | level = ", deck.get_family_lvl(_family_type))
