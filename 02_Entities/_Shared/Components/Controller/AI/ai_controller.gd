class_name AIController
extends ControllerStrategy

# Mode AUTO du EntityController. Décision actuelle : choisir la cible AA
# courante via TargetComponent et la passer à AutoAttack. Tick périodique via
# battle_callback_registry (auto-pause sur stun, auto-stop hors combat via
# le state machine de l'entité).

#region ============================== Constants ==============================
const DECISION_CALLBACK_ID: StringName = &"ai_controller_decision"
#endregion


#region ============================== Export ==============================
@export var _strategy: TargetComponent.TargettingStrategy = TargetComponent.TargettingStrategy.CLOSEST_ENEMY
@export_range(0.05, 5.0, 0.05) var _decision_interval_seconds: float = 0.25
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	if _owner == null: return
	# Réagir immédiatement quand la cible courante meurt, sans attendre le prochain tick.
	if _owner.auto_attack != null:
		_owner.auto_attack.target_dropped.connect(_on_target_dropped)


func _exit_tree() -> void:
	# Cleanup au cas où l'EntityController est détruit
	if _active:
		disable()
#endregion


#region ============================== Public API ==============================
func enable() -> void:
	if _active: return
	super.enable()
	if _owner.battle_callback_registry == null:
		Verbose.error("AIController.enable: no battle_callback_registry on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		return
	# Si on est déjà en combat, on autostart. Sinon le state machine s'en chargera
	# via start_timers() à la transition FIGHTING.
	var autostart: bool = _owner.fighting_state == Entity.FightingState.FIGHTING
	_owner.battle_callback_registry.register_periodic(
		DECISION_CALLBACK_ID,
		_decision_interval_seconds,
		_make_decision,
		autostart
	)


func disable() -> void:
	if not _active: return
	super.disable()
	if _owner.battle_callback_registry != null:
		_owner.battle_callback_registry.unregister(DECISION_CALLBACK_ID)
#endregion


#region ============================== Private functions ==============================
func _make_decision() -> void:
	# Décision = simulation : serveur uniquement. Le client ne choisit aucune cible,
	# il rejoue les actions de combat via le BattleReader.
	if not multiplayer.is_server(): return
	if _owner.auto_attack == null or _owner.target == null:
		return

	# Si la cible standing est encore valide, on ne switch pas — pas de targeting agressif.
	var current: Entity = _owner.auto_attack.get_current_target()
	if current != null and is_instance_valid(current) and not current.is_dead():
		return

	# Cible absente ou invalide : on en cherche une nouvelle.
	var picked: Entity = _owner.target.get_target(_strategy)
	if picked != null:
		_owner.auto_attack.set_target(picked)
#endregion


#region ============================== Callbacks ==============================
func _on_target_dropped(_reason: String) -> void:
	if _active:
		_make_decision()
#endregion
