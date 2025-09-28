extends Control

@export var _hero_id: Hero.HeroId

func _enter_tree() -> void:
	GameManager.init()
	GameManager._game_type = GameManager.GameType.SOLO
	PlayerManager.join_game(1, "breep")
	PlayerManager.players[1].hero = Shared.HEROES[_hero_id]
	
