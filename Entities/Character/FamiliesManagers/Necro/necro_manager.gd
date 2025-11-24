class_name NecroManager
extends FamilyManager

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _necro_stats: FamilyNecroStats # Ref to the owner necro stats

# ============================== Local nodes ==============================

# Timer optionnel si la Nécrose doit aussi faire des dégâts sur le temps (DoT) comme le feu/poison
@onready var _necro_tick_timer: Timer = %NecroTickTimer 

# ============================== Node base functions ==============================

func _ready() -> void:
	# Assure-toi que "necro" existe dans families_stats
	_necro_stats = _owner.families_stats.necro

# ============================== Public functions ==============================

func start() -> void:
	_create_optional_timers()
	_lanch_optional_spells()
	_on_battle_start()
	_add_stat_modifiers()
	_add_action_modifiers() # C'est ici qu'on branche la logique Necrosis sur le soin
	_add_stack_modifiers()
	
	# _necro_tick_timer.start() # Décommenter si la Nécrose fait aussi des dégâts périodiques


func stop() -> void:
	_clear_stack_modifiers()
	_clear_action_modifiers() # Nettoyage de la logique Necrosis
	for spell in _optional_spells:
		spell.queue_free()
	# _necro_tick_timer.stop()
	_clear_optional_timers()

# ============================== Private functions ==============================

#region on battle start
func _on_battle_start() -> void:
	# Exemple : Appliquer necrose au début du combat si un talent est actif
	pass
#endregion

#region optional timer
func _create_optional_timers() -> void:
	
	# [PUTRID TOUCH]
if _necro_stats.necro_putrid_touch_activated:
    _optional_timers.append(Utils.create_perpetual_timer(self, _necro_stats.necro_putrid_touch_period, _on_putrid_touch_timer_timeout, true))

func _clear_optional_timers() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()
#endregion

#region stats modifier
func _add_stat_modifiers() -> void:
	# Exemple : Peau de mort-vivant (Resistance physique)
	if _necro_stats.necro_undead_skin_activated:
		var mod := StatModifier.new()
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = _necro_stats.necro_undead_skin_value
		mod.stat_type = EntityStats.StatType.RESISTANCE
		mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
		mod.id = "Undead Skin"
		_owner.stats_manager.register_modifier(mod)
#endregion

#region actions modifier (NECROSIS LOGIC HERE)
func _add_action_modifiers() -> void:
	# [NECROSIS MECHANIC]
	# Toujours actif si c'est le passif de base de la famille
	if true: 
		var action_modifier := ActionModifier.new()
		# On écoute les soins reçus (HEAL)
		action_modifier.action_type = ActionModifier.ActionType.HEAL 
		action_modifier.id = "Necrosis Anti-Heal"
		action_modifier.tags = [ActionModifier.TagType.PASSIVE]
		action_modifier.is_one_time_effect = false
		# IMPORTANT : Utiliser 'before' pour réduire le soin AVANT qu'il ne s'applique
		action_modifier.before_action_logic_callback = _on_before_heal_necrosis
		_owner.action_modifiers_manager.register_modifier(action_modifier)


func _clear_action_modifiers() -> void:
	# [NECROSIS MECHANIC]
	if true:
		var action_modifier := ActionModifier.new()
		action_modifier.id = "Necrosis Anti-Heal"
		action_modifier.action_type = ActionModifier.ActionType.HEAL
		action_modifier.before_action_logic_callback = _on_before_heal_necrosis
		_owner.action_modifiers_manager.unregister_modifier(action_modifier)
#endregion

#region on inflict stacks modifier
func _add_stack_modifiers() -> void:
	# Ici tu pourrais ajouter des effets quand on INFLIGE la nécrose (ex: dégâts immédiats)
	pass

func _clear_stack_modifiers() -> void:
	pass
#endregion

#region others cards
func _lanch_optional_spells() -> void:
	# [BONE SPIKE]
	if _necro_stats.necro_bone_spike_activated:
		var spell_modifier: Dictionary = {
			Spell.BoneSpikeModifier.DAMAGE: _necro_stats.necro_bone_spike_damage,
			Spell.BoneSpikeModifier.STUN_DURATION: _necro_stats.necro_bone_spike_stun
		}
		_owner.cast_spell(_owner, Spell.Type.BONE_SPIKE, spell_modifier)
#endregion

# ============================== Callbacks functions ==============================

#region ===== NECROSIS LOGIC =====
# [NECROSIS] - Passif : Réduit le soin reçu
func _on_before_heal_necrosis(cb_vars: Dictionary) -> void:
	# 1. Vérifications de sécurité
	if not cb_vars.has(ActionModifier.VarType.TARGET): return
	var target: Entity = cb_vars[ActionModifier.VarType.TARGET]
	
	# On s'assure que c'est bien nous qui recevons le soin
	if target != _owner: return 
	
	# Vérifie si on a des stacks de nécrose
	if _owner.stats.necrosis_stacks <= 0: return

	# 2. Calcul de la réduction (10% par stack)
	var stack_count: int = _owner.stats.necrosis_stacks
	var reduction_percentage: float = float(stack_count) * 0.10
	
	# On cap à 100% pour ne pas avoir de soin négatif (dégâts) sauf si voulu
	if reduction_percentage > 1.0: reduction_percentage = 1.0

	# 3. Application de la réduction
	if cb_vars.has(ActionModifier.VarType.VALUE):
		var current_heal = cb_vars[ActionModifier.VarType.VALUE]

		# --- DEBUG PRINTS ---
		print("--------------------------------------------------")
		print("[NECROSIS DEBUG] Target: ", _owner.name)
		print("[NECROSIS DEBUG] Stacks count: ", stack_count)
		print("[NECROSIS DEBUG] Reduction: ", reduction_percentage * 100, "%")
		print("[NECROSIS DEBUG] Heal BEFORE: ", current_heal)
		print("[NECROSIS DEBUG] Heal AFTER: ", new_heal)
		print("--------------------------------------------------")

		# On modifie la valeur du soin dans le dictionnaire pour la suite de la chaîne
		cb_vars[ActionModifier.VarType.VALUE] = current_heal * (1.0 - reduction_percentage)
		
		# 4. Consommation d'un stack
		# Utilisation de dispell pour retirer proprement 1 stack de type NECROSIS
		_owner.dispell(_owner, 1, Utils.StackType.NECROSIS)
#endregion

#region ===== PUTRID TOUCH =====
func _on_putrid_touch_timer_timeout() -> void:
    var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
    if target == null: return
    _owner.inflict_condition_stacks(target, _necro_stats.necro_putrid_touch_stacks, Utils.StackType.NECROSIS)
#endregion

#region ===== RAISE DEAD =====
func _on_raise_dead_timer_timeout() -> void:
	# Logique pour invoquer un squelette ou autre
	pass
#endregion