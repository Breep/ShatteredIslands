extends Node

@export var _ui_hero_picking_screen: UIHeroPickingScreen

func _ready() -> void:
	var heroes: Array[HeroDesc]
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	heroes.append(Shared.HEROES[HeroDesc.HeroId.DARK_KNIGHT])
	_ui_hero_picking_screen.update_heroes(heroes)
