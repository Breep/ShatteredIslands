class_name Hero
extends Entity

# == VIRTUAL CLASS ==

#region ============================== Signal ==============================
signal aa_done()
signal ultimate_casted()
#endregion

#region ============================== Export ==============================
@export_group("Configuration")
@export var hero_desc: HeroDesc
@export_range(1, 10, 1) var level: int = 1

@export_group("Local Nodes")
@export var _hero_animator: HeroAnimator


@export_subgroup("Optional")

@export var anim_events_manager: AnimEventsManager
#endregion

#region ============================== Public variables ==============================
var fighting_area: FightingArea
var families_stats: FamiliesStats
#endregion

#region ============================== Private variables ==============================
var _interact_module: InteractModule
var _action_module: ActionModule
var _auto_attack_module: AutoAttackModule

var _skill_manager: SkillManager
var _family_managers: Array[FamilyManager]
#endregion

#region ============================== Public functions ==============================
func connect_to_fighting_area(fighting_area_ref: FightingArea) -> void:
	if fighting_area_ref == null:
		Verbose.error("Trying to connect a null fighting area to a Hero", Verbose.Category.HERO)
		return
	
	fighting_area = fighting_area_ref
	_action_module.connect_to_spawn_manager(fighting_area.spawn_manager)


func get_auto_attack_spawn() -> Node3D:
	return self


#func get_rank_changed_signal() -> Signal: # TODO
	#return _get_rank_changed_signal()
#endregion

#region ===== Actions =====
func direct_attack(target: Entity, damage: float, damage_type: Utils.DamageType, action_id: StringName) -> void:
	_action_module.direct_attack(target, damage, damage_type, action_id)


func direct_attack_percent(target: Entity, damage_percent: float, damage_type: Utils.DamageType, percent_modifier: Utils.PercentModifier, action_id: StringName) -> void:
	_action_module.direct_attack_percent(target, damage_percent, damage_type, percent_modifier, action_id)


var _pending_attacks: Array[AttackCommand]
func projectile_attack(target: Entity, projectile_type: Projectile.ProjectileType, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
	if projectile_type == Projectile.ProjectileType.AUTO_ATTACK:
		var attack_cmd: AttackCommand = _action_module.build_projectile_attack(target, projectile_type, projectile_spawn, projectile_stats)
		if attack_cmd == null:
			Verbose.error("Can't create an AttackCommand | " + entity_name, Verbose.Category.HERO)
			return
		if _pending_attacks.is_empty(): _pending_attacks.append(attack_cmd)
		else: _pending_attacks[0] = attack_cmd
		auto_attack_started.emit(projectile_stats.physical_is_critical)
	else:
		_action_module.projectile_attack(target, projectile_type, projectile_spawn, projectile_stats)


func _on_anim_events_manager_attack_hit_frame() -> void:
	if _pending_attacks.is_empty():
		# Can be empty if it's an critical strike, both hands attacks -> TODO: Maybe see if there is a better way
		return
	var attack_cmd: AttackCommand = _pending_attacks.pop_front()
	if !is_instance_valid(attack_cmd.target) or attack_cmd.target.is_queued_for_deletion(): return
	look_at_target_y_only(attack_cmd.target.global_position)
	_action_module.projectile_attack(attack_cmd.target, attack_cmd.projectile_type, attack_cmd.spawn_node, attack_cmd.stats)


func cast_spell(target: Entity, spell_type: Spell.Type, spell_modifier: Dictionary = {}) -> void:
	_action_module.cast_spell(target, spell_type, spell_modifier)

func cast_ultimate() -> void:
	ultimate_casted.emit()

func heal(target: Entity, heal_amount: float, action_id: StringName) -> void:
	_action_module.heal(target, heal_amount, action_id)

func heal_percent(target: Entity, percent: float, percent_modifier: Utils.PercentModifier, action_id: StringName) -> void:
	_action_module.heal_percent(target, percent, percent_modifier, action_id)

func inflict_condition_stacks(target: Entity, stacks_number: float, stack_type: Utils.StackType, action_id: StringName, duration: float = 5.0) -> void:
	_action_module.inflict_condition_stacks(target, stacks_number, stack_type, action_id, duration)

func summon_entity(entity_type: EntityType, entity_spawn_global_position: Vector3, entity_modifier: Dictionary) -> void:
	_action_module.summon_entity(entity_type, entity_spawn_global_position, entity_modifier)

func cleanse(target: Entity, value: float, action_id: StringName) -> void:
	_action_module.cleanse(target, value, action_id)

func dispell(target: Entity, value: float, action_id: StringName) -> void:
	_action_module.dispell(target, value, action_id)
#endregion

#region ===== Interaction =====
func take_damage(damage: float, damage_type: Utils.DamageType, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	return _interact_module.take_damage(damage, damage_type, is_critical, action_id, source)

func take_damage_percent(percent: float, percent_modifier: Utils.PercentModifier, damage_type: Utils.DamageType, is_critical: bool, action_id: StringName, source: Entity = null) -> void:
	_interact_module.take_damage_percent(percent, percent_modifier, damage_type, is_critical, action_id, source)

func take_condition_stacks(stacks_number: float, stack_type: Utils.StackType, is_critical: bool, action_id: StringName, source: Entity = null, duration: float = 5.0) -> float:
	return _interact_module.take_condition_stacks(stacks_number, stack_type, is_critical, action_id, source, duration)

func take_heal(heal_amount: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	return _interact_module.take_heal(heal_amount, is_critical, action_id, source)

func take_cleanse(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	return _interact_module.take_cleanse(value, is_critical, action_id, source)

func take_dispell(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	return _interact_module.take_dispell(value, is_critical, action_id, source)
#endregion

#region ============================== Node base functions ==============================
func _enter_tree() -> void:
	_hero_enter_tree()
	_entity_enter_tree()


func _hero_enter_tree() -> void:
	# Configure stats
	if base_stats == null and hero_desc != null:
		base_stats = EntityStats.new().reset_from_hero_desc(hero_desc, level)
	
	# Add Family Managers and Family stats
	families_stats = FamiliesStats.new()
	for family_type: Family.FamilyType in Shared.FAMILY_MANAGER_SCENES.keys():
		_family_managers[family_type] = Shared.FAMILY_MANAGER_SCENES[family_type].instantiate().init(self)
		add_child(_family_managers[family_type])
	
	# Add Action/Interact/AutoAttack Modules
	if _interact_module == null:
		_interact_module = Shared.ENTITY_MODULE_SCENES[Module.ModuleType.ACTION].instantiate().init(self)
		add_child(_interact_module)
	
	if _action_module == null:
		_action_module = Shared.ENTITY_MODULE_SCENES[Module.ModuleType.INTERACT].instantiate().init(self)
		add_child(_action_module)
	
	if _auto_attack_module == null:
		_auto_attack_module = Shared.ENTITY_MODULE_SCENES[Module.ModuleType.AUTOATTACK].instantiate().init(self)
		add_child(_auto_attack_module)


func _ready() -> void:
	_hero_ready()


func _hero_ready() -> void:
	if battle_id == -1:
		_entity_info_panel_3d.hide()
	
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)
	GlobalFightingManager.fighting_phase_state_changed.connect(_on_gfm_fighting_phase_state_changed)
	
	stats.health_changed.connect(_on_stats_health_changed)
	
	_auto_attack_module.attack_done.connect(_on_aa_module_attack_done)
	
	anim_events_manager.attack_hit_frame.connect(_on_anim_events_manager_attack_hit_frame)
	
	_entity_info_panel_3d.update_health_bar(stats.health, stats.health_max)
#endregion

#region ============================== Private functions ==============================

#endregion

#region ============================== Private ==============================
func _handle_death() -> void:
	died.emit(self)
	_is_dead = true
#endregion

#region ============================== Other callbacks ==============================
func _on_gfm_fighting_phase_state_changed(fighting_phase_state: GlobalFightingManager.FightingPhaseState) -> void:
	match fighting_phase_state:
		GlobalFightingManager.FightingPhaseState.POSITIONING:
			fighting_state = FightingState.IDLE
		GlobalFightingManager.FightingPhaseState.NORMAL:
			fighting_state = FightingState.FIGHTING
		GlobalFightingManager.FightingPhaseState.CELEBRATING:
			fighting_state = FightingState.CELEBRATING


func _on_game_manager_game_state_changed(game_state: GameManager.GameState) -> void:
	match game_state:
		GameManager.GameState.BUYING:
			_is_dead = false
			_pending_attacks.clear()
			_entity_info_panel_3d.hide()


func _on_stats_health_changed(new_health: int) -> void:
	if _entity_info_panel_3d != null: _entity_info_panel_3d.update_health_bar(new_health, stats.health_max)
	if new_health <= 0:
		signal_death()

 
func _on_aa_module_attack_done() -> void:
	aa_done.emit()
#endregion
