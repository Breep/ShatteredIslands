extends SceneTree

func _init() -> void:
	var library := ResourceLoader.load("res://02_Entities/_Data/DragonSkeleton/dragonskeleton.res")
	print("library_class=", library.get_class())
	print("animation_count=", library.get_animation_list().size())
	for animation_name in library.get_animation_list():
		print("animation=", animation_name)
		if String(animation_name).to_lower().contains("ultimate") or String(animation_name).to_lower().contains("ground"):
			var animation: Animation = library.get_animation(animation_name)
			print(" target_animation=", animation_name, " length=", animation.length, " tracks=", animation.get_track_count())
			for track_index in animation.get_track_count():
				var path := str(animation.track_get_path(track_index))
				if path.to_lower().contains("head") or path.to_lower().contains("neck"):
					print("  track=", track_index, " type=", animation.track_get_type(track_index), " keys=", animation.track_get_key_count(track_index), " path=", path)
					var key_limit := min(animation.track_get_key_count(track_index), 10)
					for key_index in key_limit:
						print("   key=", key_index, " time=", animation.track_get_key_time(track_index, key_index), " value=", animation.track_get_key_value(track_index, key_index))
	quit()
