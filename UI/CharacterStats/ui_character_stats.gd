class_name UICharacterStats
extends Control

# ============================== Private variables ==============================

var _entity_stats: EntityStats

# ============================== Local nodes ==============================

@onready var _health_bar: ProgressBar = %HealthBar
@onready var _health_label: Label = %HealthLabel
@onready var _mana_bar: ProgressBar = %ManaBar
@onready var _mana_label: Label = %ManaLabel
@onready var _attack_label: Label = %AttackLabel
@onready var _attack_speed_label: Label = %AttackSpeedLabel
@onready var _crit_chance_label: Label = %CritChanceLabel

@onready var _armor_container: CenterContainer = %ArmorCenter
@onready var _armor_label: Label = %ArmorLabel

@onready var _poison_container: CenterContainer = %PoisonCenter
@onready var _poison_label: Label = %PoisonLabel

@onready var _ignite_container: CenterContainer = %IgniteCenter
@onready var _ignite_label: Label = %IgniteLabel

@onready var _player_name_label: Label = %PlayerName

# ============================== Public functions ==============================

func connect_entity_stats(new_entity_stats: EntityStats, entity_name: String = ""):
	if not (_entity_stats == null or _entity_stats.is_queued_for_deletion()):
		_disconnect_all_entity_stats_signals(_entity_stats)
	_entity_stats = new_entity_stats
	_setup_local_nodes()
	_player_name_label.text = entity_name
	show()

# ============================== Node base functions ==============================

func _ready() -> void:
	hide()
	_setup_local_nodes()
	
	Events.nothing_clicked.connect(_on_events_nothing_clicked)

# ============================== Private functions ==============================

func _setup_local_nodes() -> void:
	if not is_node_ready() or _entity_stats == null: return
	_update_local_nodes()
	_connect_all_entity_stats_signals(_entity_stats)


func _update_local_nodes() -> void:
	if not is_node_ready() or _entity_stats == null: return
	_health_bar.max_value = _entity_stats.health_max
	_health_bar.value = _entity_stats.health
	_health_label.text = str(_entity_stats.health) + "/" + str(_entity_stats.health_max)
	_mana_bar.max_value = _entity_stats.mana_max
	_mana_bar.value = _entity_stats.mana
	_mana_label.text = str(_entity_stats.mana as int) + "/" + str(_entity_stats.mana_max as int)
	_attack_label.text = str(_entity_stats.attack_damage)
	_attack_speed_label.text = str(_entity_stats.attack_speed)
	_crit_chance_label.text = str(_entity_stats.physical_critical_chance)
	_update_optional_value(_armor_container, _armor_label, _entity_stats.armor_stacks)
	_update_optional_value(_poison_container, _poison_label, _entity_stats.poison_stacks)
	_update_optional_value(_ignite_container, _ignite_label, _entity_stats.ignite_stacks)
	#_update_optional_value(_instability_container, _instability_label, _entity_stats.instability_stacks)


func _connect_all_entity_stats_signals(entity_stats: EntityStats) -> void:
	entity_stats.health_max_changed.connect(_on_entity_stats_health_max_changed)
	entity_stats.health_changed.connect(_on_entity_stats_health_changed)
	entity_stats.mana_max_changed.connect(_on_entity_stats_mana_max_changed)
	entity_stats.mana_changed.connect(_on_entity_stats_mana_changed)
	entity_stats.attack_damage_changed.connect(_on_entity_stats_attack_damage_changed)
	entity_stats.attack_speed_changed.connect(_on_entity_stats_attack_speed_changed)
	entity_stats.physical_critical_chance_changed.connect(_on_entity_stats_physical_critical_chance_changed)
	entity_stats.armor_stacks_changed.connect(_on_entity_stats_armor_stacks_changed)
	entity_stats.poison_stacks_changed.connect(_on_entity_stats_poison_stacks_changed)
	entity_stats.ignite_stacks_changed.connect(_on_entity_stats_ignite_stacks_changed)


func _disconnect_all_entity_stats_signals(entity_stats: EntityStats) -> void:
	if entity_stats == null: return
	entity_stats.health_max_changed.disconnect(_on_entity_stats_health_max_changed)
	entity_stats.health_changed.disconnect(_on_entity_stats_health_changed)
	entity_stats.mana_max_changed.disconnect(_on_entity_stats_mana_max_changed)
	entity_stats.mana_changed.disconnect(_on_entity_stats_mana_changed)
	entity_stats.attack_damage_changed.disconnect(_on_entity_stats_attack_damage_changed)
	entity_stats.attack_speed_changed.disconnect(_on_entity_stats_attack_speed_changed)
	entity_stats.physical_critical_chance_changed.disconnect(_on_entity_stats_physical_critical_chance_changed)
	entity_stats.armor_stacks_changed.disconnect(_on_entity_stats_armor_stacks_changed)
	entity_stats.poison_stacks_changed.disconnect(_on_entity_stats_poison_stacks_changed)
	entity_stats.ignite_stacks_changed.disconnect(_on_entity_stats_ignite_stacks_changed)


func _update_optional_value(optional_container: CenterContainer, optional_label: Label, value: int) -> void:
	if value <= 0:
		optional_container.hide()
	else:
		optional_container.show()
		optional_label.text = str(value)

# ============================== Callbacks ==============================

func _on_entity_stats_health_max_changed(new_max_health: int) -> void:
	_health_bar.max_value = new_max_health
	_health_label.text = str(_entity_stats.health) + "/" + str(new_max_health)


func _on_entity_stats_health_changed(new_health: int) -> void:
	_health_bar.value = new_health
	_health_label.text = str(new_health) + "/" + str(_entity_stats.health_max)


func _on_entity_stats_mana_max_changed(new_mana_max: int) -> void:
	_mana_bar.max_value = new_mana_max
	_mana_label.text = str(_entity_stats.mana) + "/" + str(new_mana_max)


func _on_entity_stats_mana_changed(new_mana: float) -> void:
	_mana_bar.value = new_mana
	_mana_label.text = str(new_mana as int) + "/" + str(_entity_stats.mana_max as int)


func _on_entity_stats_attack_damage_changed(new_attack_damage: int) -> void:
	_attack_label.text = str(new_attack_damage)


func _on_entity_stats_attack_speed_changed(new_attack_speed: float) -> void:
	_attack_speed_label.text = str("%.2f" % new_attack_speed)


func _on_entity_stats_physical_critical_chance_changed(new_physical_critical_chance: float) -> void:
	_crit_chance_label.text = str(new_physical_critical_chance)


func _on_entity_stats_armor_stacks_changed(armor_stacks: int) -> void:
	_update_optional_value(_armor_container, _armor_label, armor_stacks)


func _on_entity_stats_poison_stacks_changed(poison_stacks: int) -> void:
	_update_optional_value(_poison_container, _poison_label, poison_stacks)


func _on_entity_stats_ignite_stacks_changed(ignite_stacks: int) -> void:
	_update_optional_value(_ignite_container, _ignite_label, ignite_stacks)


func _on_events_nothing_clicked() -> void:
	hide()

 
