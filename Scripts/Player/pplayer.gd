class_name Player
extends Resource

var name: String # Nickname of the player
var id: int # Multiplayer id

var team: int # Current team of the player during this round

var health: int
var hero: Hero
var deck: PlayerDeck
var gold: int

var ready: bool
