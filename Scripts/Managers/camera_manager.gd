extends Node

signal camera_changed(camera_type: CameraType)

enum CameraType {
	BuyingArea,
	FightingArea1,
	FightingArea2,
	FightingArea3,
	FightingArea4,
	FreeFly
}


func _input(event):
	if event is InputEventKey and event.is_pressed():
		if Input.is_action_pressed("change_camera_buying_area"):
			camera_changed.emit(CameraType.BuyingArea)
		if Input.is_action_pressed("change_camera_fighting_area_1"):
			camera_changed.emit(CameraType.FightingArea1)
		if Input.is_action_pressed("change_camera_fighting_area_2"):
			camera_changed.emit(CameraType.FightingArea2)
		if Input.is_action_pressed("change_camera_fighting_area_3"):
			camera_changed.emit(CameraType.FightingArea3)
		if Input.is_action_pressed("change_camera_fighting_area_4"):
			camera_changed.emit(CameraType.FightingArea4)
		if Input.is_action_pressed("change_camera_free_fly"):
			camera_changed.emit(CameraType.FreeFly)
