class_name GraphimNode extends DraggableObject


var velocity: Vector2
var last_global_pos := Vector2.ZERO


func _physics_process(delta: float) -> void:
	var distance := global_position - last_global_pos
	last_global_pos = global_position

	velocity = distance / delta

	# Necesario para que funcione el arrastre con el mouse
	handle_dragging()
