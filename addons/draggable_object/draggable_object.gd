## [code]DraggableObject[/code] es una clase que almacena la lógica para que un objeto sea
## arrastable con el mouse. Asegúrate de incluir el método [code]handle_dragging[/code] en el
## [code]physics_process[/code] y activar [code]input_pickable[/code] para que funcione. [br]
##
## DraggableObject no incluye las formas de colisión para el funcionamiento de las entradas.
class_name DraggableObject extends PhysicsBody2D


## Indica que el objeto inicia o termina su arrastre
signal dragging(value: bool)


## Velocidad a la que se mueve el objeto
const DRAG_LERP_SPEED: float = 10


## Permite que el objeto sea arrastable con el mouse
@export var draggable: bool = true


## Indica si se esta arrastrando el objeto actualmente
var is_dragging: bool = false:
	set(value):
		if is_dragging == value: return
		is_dragging = value
		dragging.emit(value) # Emitimos solo cuando el estado cambia
		print("[DraggableObject] Dragging is %s" % value)


## Maneja el arrastre del objeto con el mouse. Debes incluirlo en el método [code]physics_process[/code]
func handle_dragging(delta: float) -> void:
	if not draggable or not is_dragging: return
	if global_position.distance_squared_to(get_global_mouse_position()) < 0.1: return

	# Para un arrastre suave, lerp es más eficiente
	global_position = global_position.lerp(get_global_mouse_position(), DRAG_LERP_SPEED * delta)


func _input(event: InputEvent) -> void:
	if not is_dragging or not event is InputEventMouseButton: return

	# Desactiva el arrastre cuando se suelta el mouse, incluso si es fuera del objeto
	var mb_event := event as InputEventMouseButton
	if not mb_event.pressed: is_dragging = false


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if not event is InputEventMouseButton: return
	var mb_event := event as InputEventMouseButton

	# Activa el arrastre si se clica en el objeto
	if mb_event.pressed:
		is_dragging = true
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	# Desactiva el arrastre si el mouse sale de pantalla
	if what == NOTIFICATION_WM_MOUSE_EXIT: is_dragging = false
