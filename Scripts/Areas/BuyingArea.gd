extends Panel

# ============================== Local nodes ==============================

@onready var timer: Timer = $Timer

# ============================== Public ==============================

# ============================== Node base functions ==============================

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

# ============================== Signal callbacks ==============================

func _on_timer_timeout() -> void:
	GameManager.gameSwitchTo(GameManager.GameState.Fighting)
