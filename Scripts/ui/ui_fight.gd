extends Control

@export var player1_ui : CharacterStats
@export var player2_ui : CharacterStats

@onready var healthbar1: ProgressBar = %HealthBar1
@onready var manabar1: ProgressBar = %ManaBAr1
@onready var movebar1: ProgressBar = %MoveBar1

@onready var healthtext1: Label = %Health1
@onready var manatext1: Label = %Mana1
@onready var movetext1: Label = %move1

#============================ A CONNECTER SUR CHARACTERS STATS ====================
#signal health_changed(new_health: int)
#signal mana_changed(new_mana: int)
#signal move_changed(new_move: int)

#signal max_health_changed(new_max_health: int)
#signal max_mana_changed(new_max_mana: int)
#signal max_move_changed(new_max_move: int)

#health_changed.emit(current_health)
#mana_changed.emit(current_mana)
#move_changed.emit(current_move_points)
#
#max_health_changed.emit(max_health)
#max_mana_changed.emit(max_mana)
#max_move_changed.emit(max_move_points)

#============================ A CONNECTER SUR CHARACTERS STATS ====================



func _ready() -> void:
	##_update_ui()
	#player1_ui.health_changed.connect(_on_player1_health_changed)
	#player1_ui.mana_changed.connect(_on_player1_mana_changed)
	#player1_ui.move_changed.connect(_on_player1_move_changed)
	#
	#player1_ui.max_health_changed.connect(_on_player1_max_health_changed)
	#player1_ui.max_mana_changed.connect(_on_player1_max_mana_changed)
	#player1_ui.max_move_changed.connect(_on_player1_max_move_changed)
	pass

func _update_ui() -> void:
	healthbar1.max_value = player1_ui.max_health
	healthbar1.value = player1_ui.current_health
	healthtext1.text = str(player1_ui.current_health) + "/" + str(player1_ui.max_health)
	
	manabar1.max_value = player1_ui.max_mana
	manabar1.value = player1_ui.current_mana
	manatext1.text = str(player1_ui.current_mana) + "/" + str(player1_ui.max_mana)
	
	movebar1.max_value = player1_ui.max_move_points
	movebar1.value = player1_ui.current_move_points
	movetext1.text = str(player1_ui.current_move_points) + "/" + str(player1_ui.max_move_points)


func _on_player1_health_changed(new_health: int) -> void:
	healthbar1.value = new_health
	healthtext1.text = str(new_health) + "/" + str(player1_ui.max_health)

func _on_player1_mana_changed(new_mana: int) -> void:
	manabar1.value = new_mana
	manatext1.text = str(new_mana) + "/" + str(player1_ui.max_mana)

func _on_player1_move_changed(new_move: int) -> void:
	movebar1.value = new_move
	movetext1.text = str(new_move) + "/" + str(player1_ui.max_move_points)
	
func _on_player1_max_health_changed(new_max_health: int) -> void:
	healthbar1.max_value = new_max_health
	healthtext1.text = str(player1_ui.current_health) + "/" + str(new_max_health)

func _on_player1_max_mana_changed(new_max_mana: int) -> void:
	manabar1.max_value = new_max_mana
	manatext1.text = str(player1_ui.current_mana) + "/" + str(new_max_mana)

func _on_player1_max_move_changed(new_max_move: int) -> void:
	movebar1.max_value = new_max_move
	movetext1.text = str(player1_ui.current_move_points) + "/" + str(new_max_move)
