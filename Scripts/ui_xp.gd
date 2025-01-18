extends Control

@onready var xpbar : TextureProgressBar = %XPbar
@onready var xplabel : RichTextLabel = $XPbar/Xplabel

func _ready() -> void:
	pass # Replace with function body.


func _on_xpbutton_pressed() -> void:
	print("bouton appuyé")
	xpbar.value += 4
	xplabel.text = "[pulse freq=1.0 color=#00BFFF ease=-2.0]" + str(xpbar.value) + "/100 XP[/pulse]"
