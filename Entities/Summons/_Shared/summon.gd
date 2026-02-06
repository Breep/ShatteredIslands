class_name Summon
extends Entity

# == VIRTUAL CLASS ==

#region ============================== Enums ==============================
#endregion

#region ============================== Signal ==============================
signal aa_done()
#endregion

#region ============================== Export ==============================
@export_group("Configuration")

@export_group("Local Nodes")

@export_group("Optional")

#region ============================== Public variables ==============================
var fighting_area: FightingArea
#endregion

#region ============================== Private variables ==============================
#endregion

#region ============================== Public functions ==============================
func init(fighting_area_ref: FightingArea = null) -> Summon:
	if fighting_area_ref != null:
		connect_to_fighting_area(fighting_area_ref)
	
	return self


func connect_to_fighting_area(fighting_area_ref: FightingArea) -> void:
	if fighting_area_ref == null:
		Verbose.error("Trying to connect a null fighting area to a Hero", Verbose.Category.HERO)
		return
	
	fighting_area = fighting_area_ref
	_action_module.connect_to_spawn_manager(fighting_area.spawn_manager)
	_action_module.connect_to_arena_zone_manager(fighting_area.arena_zone_manager)


func get_auto_attack_spawn() -> Node3D:
	return self
#endregion

#region ===== Actions (Summon-specific overrides) =====
#endregion

#region ============================== Node base functions ==============================
func _init() -> void:
	_hero_init()
	_entity_init()

func _hero_init() -> void:
	# Stats initialization is deferred to _hero_ready() to properly detect manual base_stats override
	pass


func _enter_tree() -> void:
	_summon_enter_tree()
	_entity_enter_tree()


func _summon_enter_tree() -> void:
	# Add AutoAttack Module
	if _auto_attack_module == null:
		var module: AutoAttackModule = Shared.ENTITY_MODULE_SCENES[Module.ModuleType.AUTOATTACK].instantiate()
		_auto_attack_module = module.init(self)
		add_child(_auto_attack_module)


func _ready() -> void:
	_summon_ready()


func _summon_ready() -> void:
	Verbose.debug("Hero [" + entity_name + "] ready", Verbose.Category.HERO)
	
	GlobalFightingManager.fighting_phase_state_changed.connect(_on_gfm_fighting_phase_state_changed)

	fighting_state_changed.connect(_on_summon_fighting_state_changed)
	_auto_attack_module.attack_done.connect(_on_aa_module_attack_done)
	
	_auto_attack_module.start()
	_entity_ready()


func _exit_tree() -> void:
	_summon_exit_tree()
	_entity_exit_tree()


func _summon_exit_tree() -> void:
	# Disconnect all signals to avoid ghost references
	if GlobalFightingManager.fighting_phase_state_changed.is_connected(_on_gfm_fighting_phase_state_changed):
		GlobalFightingManager.fighting_phase_state_changed.disconnect(_on_gfm_fighting_phase_state_changed)
	if fighting_state_changed.is_connected(_on_summon_fighting_state_changed):
		fighting_state_changed.disconnect(_on_summon_fighting_state_changed)
	if _auto_attack_module != null and _auto_attack_module.attack_done.is_connected(_on_aa_module_attack_done):
		_auto_attack_module.attack_done.disconnect(_on_aa_module_attack_done)
	if _animation_module != null and _animation_module.attack_hit_frame.is_connected(_on_animation_module_attack_hit_frame):
		_animation_module.attack_hit_frame.disconnect(_on_animation_module_attack_hit_frame)
#endregion

#region ============================== Private functions ==============================
func _on_summon_fighting_state_changed(new_fighting_state: FightingState) -> void:
	match new_fighting_state:
		FightingState.IDLE:
			_auto_attack_module.stop()
		FightingState.FIGHTING:
			print("START AA MODULE FOR SUMMON")
			_auto_attack_module.start()
		FightingState.CELEBRATING: pass
		FightingState.DEAD: pass
		FightingState.UNDEF: pass
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

 
func _on_aa_module_attack_done() -> void:
	aa_done.emit()
#endregion
