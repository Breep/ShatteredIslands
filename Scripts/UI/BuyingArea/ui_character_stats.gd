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

# ============================== Public functions ==============================

func connect_character_stats(new_character_stats: CharacterStats):
	_character_stats = new_character_stats
	_setup_local_nodes()

# ============================== Node base functions ==============================

func _ready() -> void:
	_setup_local_nodes()

# ============================== Private functions ==============================

func _setup_local_nodes() -> void:
	if not is_node_ready() or _character_stats == null: return
	_update_local_nodes()
	_character_stats.health_max_changed.connect(_on_character_stats_health_max_changed)
	_character_stats.health_changed.connect(_on_character_stats_health_changed)
	
	_character_stats.mana_max_changed.connect(_on_character_stats_mana_max_changed)
	_character_stats.mana_changed.connect(_on_character_stats_mana_changed)
	
	_character_stats.energy_max_changed.connect(_on_character_stats_energy_max_changed)
	_character_stats.energy_changed.connect(_on_character_stats_energy_changed)


func _update_local_nodes() -> void:
	if not is_node_ready() or _character_stats == null: return
	_health_bar.max_value = _character_stats.health_max
	_health_bar.value = _character_stats.health
	_health_label.text = str(_character_stats.health) + "/" + str(_character_stats.health_max)
	
	_mana_bar.max_value = _character_stats.mana_max
	_mana_bar.value = _character_stats.mana
	_mana_label.text = str(_character_stats.mana) + "/" + str(_character_stats.mana_max)
	
	_energy_bar.max_value = _character_stats.energy_max
	_energy_bar.value = _character_stats.energy
	_energy_label.text = str(_character_stats.energy as int) + "/" + str(_character_stats.energy_max)

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


func _on_character_stats_energy_max_changed(new_energy_max: int) -> void:
	_energy_bar.max_value = new_energy_max
	_energy_label.text = str(_character_stats.energy) + "/" + str(new_energy_max)


func _on_character_stats_energy_changed(new_energy: int) -> void:
	_energy_bar.value = new_energy
	_energy_label.text = str(new_energy) + "/" + str(_character_stats.energy_max)

















 
