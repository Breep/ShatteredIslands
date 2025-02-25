class_name Player
extends Resource

var name: String # Nickname of the player
var id: int # Multiplayer id

var team: int # Current team of the player during this round

var health: int
var hero: Hero

signal deck_changed(deck: PlayerDeck)
var deck: PlayerDeck


signal gold_changed(gold: int)
var _gold: int
var gold: int:
	get: return _gold
	set(value):
		_gold = value
		gold_changed.emit(_gold)

var ready: bool

var character: Character

# Get the player conresponding of the serialized_data id in the GameManager
# Update some values inside the player
static func get_from_serialized(serialized_data: Dictionary) -> Player:
	var player = GameManager.players[serialized_data["id"]]
	player.team = serialized_data["team"]
	player.health = serialized_data["health"]
	player.name = serialized_data["name"]
	return player


func serialized() -> Dictionary:
	var serialized_version = {
		"name": name,
		"id": id,
		"team": team,
		"health": health
	}
	return serialized_version
