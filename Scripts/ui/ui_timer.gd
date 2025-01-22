extends Control

@onready var timer_text : RichTextLabel = $texturetime/timer
@onready var time_texture : TextureProgressBar = $texturetime
@onready var timer = $"../Timer"


func _ready() -> void:
	update_timer_text()


func _process(_delta: float) -> void:
	# Met à jour le texte et la barre de progression en fonction du temps restant
	if timer.time_left > 0:
		update_timer_text()

func update_timer_text() -> void:
	# Met à jour la valeur affichée et la barre de progression
	var time_left = int(timer.time_left)
	timer_text.text = "[pulse freq=1.0 color=#FFD700 ease=-2.0]%d[/pulse]" % time_left
	time_texture.value = time_left / timer.wait_time * time_texture.max_value
