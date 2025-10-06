class_name UIEntityStats
extends Control

# ============================== Private variables ==============================

var _entity: Entity

# ============================== Local nodes ==============================

@onready var _ui_health_bar: UIHealthBar = %HealthBar

@onready var _mana_bar: ProgressBar = %ManaBar
@onready var _mana_label: Label = %ManaLabel
@onready var _xp_bar: ProgressBar = %XPBar
@onready var _no_xp_color_rect: ColorRect = %NoXPColorRect

@onready var _max_health_label: Label = %MaxHealthLabel
@onready var _mana_regen_label: Label = %ManaRegenLabel
@onready var _dodge_label: Label = %DodgeLabel
@onready var _attack_label: Label = %AttackLabel
@onready var _attack_speed_label: Label = %AttackSpeedLabel
@onready var _crit_chance_label: Label = %CriticLabel

@onready var _armor_label: Label = %ArmorLabel
@onready var _poison_label: Label = %PoisonLabel
@onready var _ignite_label: Label = %IgniteLabel

@onready var _entity_name_label: Label = %EntityNameLabel

@onready var _stats_panel: Panel = %StatsPanel

# ============================== Public functions ==============================

func connect_entity_stats(new_entity: Entity):
	_disconnect_all_entity_stats_signals()
	
	_entity = new_entity
	
	_update_local_nodes()
	_connect_all_entity_stats_signals()
	show()

# ============================== Node base functions ==============================

func _ready() -> void:
	hide()
	_stats_panel.hide()

# ============================== Private functions ==============================

func _update_local_nodes() -> void:
	if not is_node_ready() or _entity == null: return
	_update_entity_name_label()
	_ui_health_bar.reset(_entity.stats.health, _entity.stats.health_max)
	_update_mana_bar(_entity.stats.mana, _entity.stats.mana_max)
	if _entity is Character and _entity.player != null:
		_no_xp_color_rect.hide()
		_update_xp_bar(_entity.player.xp, GameManager.game_rules.xp_per_levels[_entity.player.lvl])
	else:
		_no_xp_color_rect.show()
	_update_armor_label(_entity.stats.armor_stacks)
	_update_poison_label(_entity.stats.poison_stacks)
	_update_ignite_label(_entity.stats.ignite_stacks)
	_attack_label.text = str(_entity.stats.attack_damage)
	_attack_speed_label.text = str(_entity.stats.attack_speed)
	_crit_chance_label.text = str(_entity.stats.physical_critical_chance)


func _connect_all_entity_stats_signals() -> void:
	_entity.stats.health_max_changed.connect(_on_entity_stats_health_max_changed)
	_entity.stats.health_changed.connect(_on_entity_stats_health_changed)
	_entity.stats.mana_max_changed.connect(_on_entity_stats_mana_max_changed)
	_entity.stats.mana_changed.connect(_on_entity_stats_mana_changed)
	_entity.stats.attack_damage_changed.connect(_on_entity_stats_attack_damage_changed)
	_entity.stats.attack_speed_changed.connect(_on_entity_stats_attack_speed_changed)
	_entity.stats.physical_critical_chance_changed.connect(_on_entity_stats_physical_critical_chance_changed)
	_entity.stats.armor_stacks_changed.connect(_on_entity_stats_armor_stacks_changed)
	_entity.stats.poison_stacks_changed.connect(_on_entity_stats_poison_stacks_changed)
	_entity.stats.ignite_stacks_changed.connect(_on_entity_stats_ignite_stacks_changed)
	if _entity is Character:
		_entity.player.xp_changed.connect(_on_entity_player_xp_changed)


func _disconnect_all_entity_stats_signals() -> void:
	if _entity == null or _entity.is_queued_for_deletion(): return
	_entity.stats.health_max_changed.disconnect(_on_entity_stats_health_max_changed)
	_entity.stats.health_changed.disconnect(_on_entity_stats_health_changed)
	_entity.stats.mana_max_changed.disconnect(_on_entity_stats_mana_max_changed)
	_entity.stats.mana_changed.disconnect(_on_entity_stats_mana_changed)
	_entity.stats.attack_damage_changed.disconnect(_on_entity_stats_attack_damage_changed)
	_entity.stats.attack_speed_changed.disconnect(_on_entity_stats_attack_speed_changed)
	_entity.stats.physical_critical_chance_changed.disconnect(_on_entity_stats_physical_critical_chance_changed)
	_entity.stats.armor_stacks_changed.disconnect(_on_entity_stats_armor_stacks_changed)
	_entity.stats.poison_stacks_changed.disconnect(_on_entity_stats_poison_stacks_changed)
	_entity.stats.ignite_stacks_changed.disconnect(_on_entity_stats_ignite_stacks_changed)
	if _entity is Character:
		_entity.player.xp_changed.disconnect(_on_entity_player_xp_changed)

# ============================== Update local nodes ==============================

func _update_entity_name_label() -> void:
	if _entity != null:
		_entity_name_label.text = _entity.player.name


func _update_mana_bar(current_mana: int, max_mana: int = 100) -> void:
	_mana_bar.value = current_mana
	_mana_bar.max_value = max_mana
	_mana_label.text = str(current_mana)


func _update_xp_bar(current_xp: int, max_xp: int) -> void:
	_xp_bar.value = current_xp
	_xp_bar.max_value = max_xp


func _update_armor_label(armor_stacks: int) -> void:
	_armor_label.text = str(armor_stacks)


func _update_poison_label(poison_stacks: int) -> void:
	_poison_label.text = str(poison_stacks)


func _update_ignite_label(ignite_stacks: int) -> void:
	_ignite_label.text = str(ignite_stacks)

# ============================== Entity Callbacks ==============================

func _on_entity_stats_health_max_changed(new_max_health: int) -> void:
	_ui_health_bar.update_max_health(new_max_health)


func _on_entity_stats_health_changed(new_health: int) -> void:
	_ui_health_bar.update_current_health(new_health)


func _on_entity_stats_mana_max_changed(new_mana_max: int) -> void:
	_update_mana_bar(_entity.stats.mana, new_mana_max)


func _on_entity_stats_mana_changed(new_mana: float) -> void:
	_update_mana_bar(new_mana, _entity.stats.mana_max)


func _on_entity_stats_attack_damage_changed(new_attack_damage: int) -> void:
	_attack_label.text = str(new_attack_damage)


func _on_entity_stats_attack_speed_changed(new_attack_speed: float) -> void:
	_attack_speed_label.text = str("%.2f" % new_attack_speed)


func _on_entity_stats_physical_critical_chance_changed(new_physical_critical_chance: float) -> void:
	_crit_chance_label.text = str(new_physical_critical_chance)


func _on_entity_stats_armor_stacks_changed(armor_stacks: int) -> void:
	_update_armor_label(armor_stacks)


func _on_entity_stats_poison_stacks_changed(poison_stacks: int) -> void:
	_update_poison_label(poison_stacks)


func _on_entity_stats_ignite_stacks_changed(ignite_stacks: int) -> void:
	_update_ignite_label(ignite_stacks)


func _on_entity_player_xp_changed(_self_ref: Player, new_xp: int) -> void:
	_update_xp_bar(new_xp, GameManager.game_rules.xp_per_levels[_entity.player.lvl])

# ============================== Local Callbacks ==============================

func _on_right_show_stats_button_toggled(toggled_on: bool) -> void:
	_stats_panel.show() if toggled_on else _stats_panel.hide()


func _on_left_show_stats_button_toggled(toggled_on: bool) -> void:
	_stats_panel.show() if toggled_on else _stats_panel.hide()
