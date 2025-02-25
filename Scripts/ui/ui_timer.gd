extends Control

@onready var timer_text : RichTextLabel = $texturetime/timer
@onready var time_texture : TextureProgressBar = $texturetime

@export var timer : Timer


func _ready() -> void:
	update_timer_text()


func _process(_delta: float) -> void:
	await get_tree().create_timer(0.05).timeout
	if timer.time_left > 0:
		update_timer_text()


func update_timer_text() -> void:
	# Met à jour la valeur affichée et la barre de progression
	var time_left = timer.time_left
	timer_text.text = "[pulse freq=1.0 color=#FFD700 ease=-2.0]%d[/pulse]" % (time_left as int)
	time_texture.value = (time_left / timer.wait_time) * time_texture.max_value
