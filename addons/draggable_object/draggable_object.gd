## [code]DraggableObject[/code] es una clase que almacena la lógica para que un objeto sea
## arrastable con el mouse. Asegúrate de incluir el método [code]handle_dragging[/code] en el
## [code]physics_process[/code] y activar [code]input_pickable[/code] para que funcione. [br]
##
## DraggableObject no incluye las formas de colisión para el funcionamiento de las entradas.
class_name DraggableObject extends PhysicsBody2D


## Velocidad a la que se mueve el objeto
const DRAG_LERP_TIME: float = 0.1


## Permite que el objeto sea arrastable con el mouse
@export var draggable: bool = true

## Indica si se esta arrastrando el objeto actualmente
var is_dragging: bool = false:
	set(value):
		is_dragging = value
		print("[DraggableObject] Dragging is %s" % value)


## Maneja el arrastre del objeto con el mouse. Debes incluirlo en el método [code]physics_process[/code]
func handle_dragging() -> void:
	if not draggable or not is_dragging: return

	# Suaviza el movimiento del objeto
	var tween := create_tween()
	tween.tween_property(self, "global_position", get_global_mouse_position(), DRAG_LERP_TIME)
	global_position = get_global_mouse_position()


func _input_event(_viewport, event: InputEvent, _shape_idx) -> void:
	if not event is InputEventMouseButton: return
	event = event as InputEventMouseButton

	is_dragging = event.pressed


func _notification(what: int) -> void:
	# Desactiva el arrastre si el mouse sale de pantalla
	if what == NOTIFICATION_WM_MOUSE_EXIT: is_dragging = false
