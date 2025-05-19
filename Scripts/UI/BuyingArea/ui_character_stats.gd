class_name UICharacterStats
extends Control

# ============================== Private variables ==============================

var _character_stats: CharacterStats

# ============================== Local nodes ==============================

@onready var _health_bar: ProgressBar = %HealthBar
@onready var _health_label: Label = %HealthLabel
@onready var _mana_bar: ProgressBar = %ManaBar
@onready var _mana_label: Label = %ManaLabel
@onready var _energy_bar: ProgressBar = %EnergyBar
@onready var _energy_label: Label = %EnergyLabel
@onready var _attack_label: Label = %AttackLabel
@onready var _attack_speed_label: Label = %AttackSpeedLabel
@onready var _crit_chance_label: Label = %CritChanceLabel
@onready var _move_speed_label: Label = %MoveSpeedLabel
@onready var _poison_label: Label = %PoisonLabel
@onready var _armor_label: Label = %ArmorLabel

# ============================== Public functions ==============================

func connect_character_stats(new_character_stats: CharacterStats):
	_disconnect_all_character_stats_signals(_character_stats)
	_character_stats = new_character_stats
	_setup_local_nodes()

# ============================== Node base functions ==============================

func _ready() -> void:
	_setup_local_nodes()

# ============================== Private functions ==============================

func _setup_local_nodes() -> void:
	if not is_node_ready() or _character_stats == null: return
	_update_local_nodes()
	_connect_all_character_stats_signals(_character_stats)


func _update_local_nodes() -> void:
	if not is_node_ready() or _character_stats == null: return
	_health_bar.max_value = _character_stats.health_max
	_health_bar.value = _character_stats.health
	_health_label.text = str(_character_stats.health) + "/" + str(_character_stats.health_max)
	_mana_bar.max_value = _character_stats.mana_max
	_mana_bar.value = _character_stats.mana
	_mana_label.text = str(_character_stats.mana) + "/" + str(_character_stats.mana_max)
	_attack_label.text = str(_character_stats.attack_damage)
	_attack_speed_label.text = str(_character_stats.attack_speed)
	_crit_chance_label.text = str(_character_stats.physical_critical_chance)
	_armor_label.text = str(_character_stats.defense.armor_stacks)
	_poison_label.text = str(_character_stats.poison.poison_stacks)


func _connect_all_character_stats_signals(character_stats: CharacterStats) -> void:
	character_stats.health_max_changed.connect(_on_character_stats_health_max_changed)
	character_stats.health_changed.connect(_on_character_stats_health_changed)
	character_stats.mana_max_changed.connect(_on_character_stats_mana_max_changed)
	character_stats.mana_changed.connect(_on_character_stats_mana_changed)
	character_stats.attack_damage_changed.connect(_on_character_stats_attack_damage_changed)
	character_stats.attack_speed_changed.connect(_on_character_stats_attack_speed_changed)
	character_stats.physical_critical_chance_changed.connect(_on_character_stats_physical_critical_chance_changed)
	character_stats.defense.armor_stacks_changed.connect(_on_character_stats_defense_armor_stacks_changed)
	character_stats.poison.poison_stacks_changed.connect(_on_character_stats_poison_poison_stacks_changed)


func _disconnect_all_character_stats_signals(character_stats: CharacterStats) -> void:
	if character_stats == null: return
	character_stats.health_max_changed.disconnect(_on_character_stats_health_max_changed)
	character_stats.health_changed.disconnect(_on_character_stats_health_changed)
	character_stats.mana_max_changed.disconnect(_on_character_stats_mana_max_changed)
	character_stats.mana_changed.disconnect(_on_character_stats_mana_changed)
	character_stats.attack_damage_changed.disconnect(_on_character_stats_attack_damage_changed)
	character_stats.attack_speed_changed.disconnect(_on_character_stats_attack_speed_changed)
	character_stats.physical_critical_chance_changed.disconnect(_on_character_stats_physical_critical_chance_changed)
	character_stats.defense.armor_stacks_changed.disconnect(_on_character_stats_defense_armor_stacks_changed)
	character_stats.poison.poison_stacks_changed.disconnect(_on_character_stats_poison_poison_stacks_changed)

# ============================== Callbacks ==============================

func _on_character_stats_health_max_changed(new_max_health: int) -> void:
	_health_bar.max_value = new_max_health
	_health_label.text = str(_character_stats.health) + "/" + str(new_max_health)


func _on_character_stats_health_changed(new_health: int) -> void:
	_health_bar.value = new_health
	_health_label.text = str(new_health) + "/" + str(_character_stats.health_max)


func _on_character_stats_mana_max_changed(new_mana_max: int) -> void:
	_mana_bar.max_value = new_mana_max
	_mana_label.text = str(_character_stats.mana) + "/" + str(new_mana_max)


func _on_character_stats_mana_changed(new_mana: int) -> void:
	_mana_bar.value = new_mana
	_mana_label.text = str(new_mana) + "/" + str(_character_stats.mana_max)


func _on_character_stats_attack_damage_changed(new_attack_damage: int) -> void:
	_attack_label.text = str(new_attack_damage)


func _on_character_stats_attack_speed_changed(new_attack_speed: float) -> void:
	_attack_speed_label.text = str(new_attack_speed)


func _on_character_stats_physical_critical_chance_changed(new_physical_critical_chance: float) -> void:
	_crit_chance_label.text = str(new_physical_critical_chance)


func _on_character_stats_defense_armor_stacks_changed(new_armor_stacks: int) -> void:
	_armor_label.text = str(new_armor_stacks)


func _on_character_stats_poison_poison_stacks_changed(new_poison_stacks: int) -> void:
	_poison_label.text = str(new_poison_stacks)




 
