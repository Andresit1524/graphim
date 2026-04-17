class_name GraphimNode extends DraggableObject


func _physics_process(_delta) -> void:
	# Necesario para que funcione el arrastre con el mouse
	handle_dragging()
