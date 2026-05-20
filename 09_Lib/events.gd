extends Node

# ActionModule TODO ActionModule and InteractModule whould be able to interact without this, bnut it's still usefull for stats and log
signal damage_done(source, target, damage, damage_type, is_critical)
func signal_damage_done(source: Entity, target: Entity, damage: int, damage_type, is_critical) -> void:
	damage_done.emit(source, target, damage, damage_type, is_critical)

signal heal_done(source, target, heal_amount)
func signal_heal_done(source, target, heal_amount) -> void:
	heal_done.emit(source, target, heal_amount)

signal condition_stacks_done(source, target, stacks_number, stack_type)
func signal_condition_stacks_done(source, target, stacks_number, stack_type) -> void:
	condition_stacks_done.emit(source, target, stacks_number, stack_type)

# ============================== GAME STATE ==============================

signal local_player_is_dead()
func signal_local_player_is_dead() -> void:
	local_player_is_dead.emit()

# ============================== MISC TODO: Check if those signals are really usefull ==============================

signal fighting_island_spawned(fighting_island_ref: FightingIsland, player_id: int)
func signal_fighting_island_spawned(fighting_island_ref: FightingIsland, player_id: int) -> void:
	fighting_island_spawned.emit(fighting_island_ref, player_id)

signal player_won_a_fight(player: Player)
func signal_player_won_a_fight(player: Player) -> void:
	player_won_a_fight.emit(player)

signal player_lost_a_fight(player: Player)
func signal_player_lost_a_fight(player: Player) -> void:
	player_lost_a_fight.emit(player)

# ============================== CLICKABLE ==============================

signal entity_clicked(entity: Entity)
signal furniture_clicked(furniture: Furniture)
func signal_clickable_cliked(clickable: Node3D) -> void:
	if clickable is Entity:
		entity_clicked.emit(clickable)
	elif clickable is Furniture:
		furniture_clicked.emit(clickable)

signal nothing_clicked()
func signal_nothing_clicked() -> void:
	nothing_clicked.emit()

# ============================== UI ==============================

signal ui_skill_picked(skill_id: Skill.SkillID)
func signal_ui_skill_picked(skill_id: Skill.SkillID) -> void:
	ui_skill_picked.emit(skill_id)

signal scene_switched(floating_island: FloatingIsland)
func signal_scene_switched(floating_island: FloatingIsland) -> void:
	scene_switched.emit(floating_island)

signal ui_family_portrait_selected(family_portrait: UIFamilyPortrait)
func signal_ui_family_portrait_selected(family_portrait: UIFamilyPortrait) -> void:
	ui_family_portrait_selected.emit(family_portrait)

signal ui_family_portrait_unselected()
func signal_ui_family_portrait_unselected() -> void:
	ui_family_portrait_unselected.emit()

signal ui_family_portrait_requested(player: Player, family: Family)
func signal_ui_family_portrait_requested(player: Player, family: Family) -> void:
	ui_family_portrait_requested.emit(player, family)

signal tavern_continue_pressed
func signal_tavern_continue_pressed() -> void:
	tavern_continue_pressed.emit()
