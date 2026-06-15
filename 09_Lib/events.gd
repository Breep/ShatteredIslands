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
signal entity_alt_clicked(entity: Entity)
signal entity_right_clicked(entity: Entity)
signal furniture_clicked(furniture: Furniture)
func signal_clickable_cliked(clickable: Node3D) -> void:
	if clickable is Entity:
		entity_clicked.emit(clickable)
	elif clickable is Furniture:
		furniture_clicked.emit(clickable)

signal nothing_clicked()
func signal_nothing_clicked() -> void:
	nothing_clicked.emit()

signal floor_clicked(position: Vector3)

# ============================== DRAGGABLE ==============================

signal entity_drag_started(entity: Entity)
signal entity_drag_stopped(entity: Entity)

# ============================== UI ==============================

signal skill_selected(skill: Skill)
func signal_skill_selected(skill: Skill) -> void:
	skill_selected.emit(skill)

# Un tier à choix (bronze/silver/gold) d'un héros vient d'être débloqué et attend
# un choix joueur. Porté par le composant pour que la fenêtre de sélection (filtrée
# sur le héros local) puisse s'ouvrir.
signal hero_skill_unlocked(component: HeroSkillComponent, skill_type: Skill.Type)
func signal_hero_skill_unlocked(component: HeroSkillComponent, skill_type: Skill.Type) -> void:
	hero_skill_unlocked.emit(component, skill_type)

# Le joueur a tranché un tier : skill posée dans le roaster du héros.
signal hero_skill_chosen(component: HeroSkillComponent, skill_id: Skill.SkillID)
func signal_hero_skill_chosen(component: HeroSkillComponent, skill_id: Skill.SkillID) -> void:
	hero_skill_chosen.emit(component, skill_id)

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

signal hero_locked()

signal ui_window_opened()

# ============================ Logic ===============================
signal card_bought(card: Card)
signal card_drawn()
signal insufficient_gold()
signal gold_gained(amount: int)
signal shop_refreshed() ## The local shop was rerolled (tutorial validation).
signal shop_opened() ## The local player opened the shop panel (tutorial validation).

## Roguelite run phases (emitted by RunRoot). The TutorialManager hooks these
## because the roguelite flow does NOT drive GameManager.game_state_changed.
signal tavern_phase_started() ## A tavern/buying phase became active and its UI is up.
signal fighting_phase_started() ## A fighting phase became active.
signal confrontation_resolved(won: bool) ## A confrontation's fight ended (emitted by GameRunner). won = the party won it.

## Tutorial-driven UI state requests (so a step can guarantee the shop is open
## before pointing at a card, or hide the shop/hand while pointing at an enemy).
signal tutorial_set_shop_open(should_open: bool)
signal tutorial_set_hand_visible(is_visible: bool)

# ============================ Manager =============================
signal card_shop_init()
