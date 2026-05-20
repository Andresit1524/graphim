extends Label


func _physics_process(_delta) -> void:
	text = "FPS: %s" % Engine.get_frames_per_second()
