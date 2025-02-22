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
		_gold = gold
		gold_changed.emit(_gold)

var ready: bool

var character: Character
