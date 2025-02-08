extends Control

@onready var _timer_label = %TimerLabel
@onready var _timer = %TimerCountdown
@onready var _tween = Tween.new() 

var _sec_timer: int
var _end_timer_word : String

func _ready() -> void:
	_timer_label.show()
	start(5,"end")

func start(countdown_sec: int, endword: String) -> void:
	_sec_timer = countdown_sec
	_end_timer_word = endword
	_timer.wait_time = 1.0  
	_timer.one_shot = false 
	_timer.start()  
	_update_label() 


func _update_label() -> void:
	_timer_label.text = str(_sec_timer)  

func _animate_label() -> void:
	_tween.kill()  
	_tween = get_tree().create_tween()  
	_tween.tween_property(_timer_label, "scale", Vector2(1.5, 1.5), 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_timer_label, "scale", Vector2(1, 1), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _animate_fight_effect() -> void:
	_tween.kill()
	_tween = get_tree().create_tween()
	_tween.tween_property(_timer_label, "scale", Vector2(2, 2), 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_timer_label, "modulate", Color.RED, 0.3).set_trans(Tween.TRANS_LINEAR)


func _on_timer_countdown_timeout() -> void:
	_sec_timer -= 1  
	_animate_label() 
	_update_label()  

	if _sec_timer <= 0:
		_timer.stop()  
		_timer_label.text = _end_timer_word 
		_animate_fight_effect()  
		await get_tree().create_timer(1).timeout
		_timer_label.hide()
