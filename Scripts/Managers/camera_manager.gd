extends Node

# ============================== Signals ==============================

signal camera_changed(camera_type: CameraType)

# ============================== Enums ==============================

enum CameraType {
	BUYING_AREA,
	FIGHTING_AREA_1,
	FIGHTING_AREA_2,
	FIGHTING_AREA_3,
	FIGHTING_AREA_4,
	FIGHTING_AREA_5,
	FIGHTING_AREA_6,
	FIGHTING_AREA_7,
	FIGHTING_AREA_8,
	FREE_FLY,
	UNDEF
}

# ============================== Base node functions ==============================

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if Input.is_action_pressed("change_camera_buying_area"):
			camera_changed.emit(CameraType.BUYING_AREA)
		if Input.is_action_pressed("change_camera_fighting_area_1"):
			camera_changed.emit(CameraType.FIGHTING_AREA_1)
		if Input.is_action_pressed("change_camera_fighting_area_2"):
			camera_changed.emit(CameraType.FIGHTING_AREA_2)
		if Input.is_action_pressed("change_camera_fighting_area_3"):
			camera_changed.emit(CameraType.FIGHTING_AREA_3)
		if Input.is_action_pressed("change_camera_fighting_area_4"):
			camera_changed.emit(CameraType.FIGHTING_AREA_4)
		if Input.is_action_pressed("change_camera_fighting_area_5"):
			camera_changed.emit(CameraType.FIGHTING_AREA_1)
		if Input.is_action_pressed("change_camera_fighting_area_6"):
			camera_changed.emit(CameraType.FIGHTING_AREA_2)
		if Input.is_action_pressed("change_camera_fighting_area_7"):
			camera_changed.emit(CameraType.FIGHTING_AREA_3)
		if Input.is_action_pressed("change_camera_fighting_area_8"):
			camera_changed.emit(CameraType.FIGHTING_AREA_4)
		if Input.is_action_pressed("change_camera_free_fly"):
			camera_changed.emit(CameraType.FREE_FLY)
