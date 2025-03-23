class_name UICharacterStats
extends Control

@onready var _health_bar: ProgressBar = %HealthBar
@onready var _health_label: Label = %HealthLabel
@onready var _mana_bar: ProgressBar = %ManaBar
@onready var _mana_label: Label = %ManaLabel
@onready var _energy_bar: ProgressBar = %EnergyBar
@onready var _energy_label: Label = %EnergyLabel

var _character: Character
