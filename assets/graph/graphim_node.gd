## Nodo de grafo con comportamientos de arrastre
class_name GraphimNode extends DraggableObject


## Color del nodo
@export var color: Color = Color.WHITE:
	set(value):
		if not is_node_ready(): await ready
		color = value
		_set_color(value)


@onready var sprite: Sprite2D = $Sprite


var velocity: Vector2
var last_global_pos := Vector2.ZERO


func _physics_process(delta: float) -> void:
	var distance := global_position - last_global_pos
	last_global_pos = global_position

	velocity = distance / delta

	# Necesario para que funcione el arrastre con el mouse
	handle_dragging()


## EStablece el color del nodo
func _set_color(_color: Color) -> void:
	sprite.modulate = _color
