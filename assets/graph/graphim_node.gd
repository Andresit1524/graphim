## Nodo de grafo con comportamientos de arrastre
class_name GraphimNode extends DraggableObject


## Escala al rebotar el nodo
const BUMP_SCALE := 1.1
## Tiempo de rebote
const BUMP_TIME := 0.2


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


## Establece el color del nodo
func _set_color(_color: Color) -> void:
	_bump()
	sprite.modulate = _color


#region Tamaño del nodo


## Aumenta el tamaño del nodo y lo deja como antes
func _bump() -> void:
	_expand()
	_contract()


## Expande el nodo
func _expand():
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "scale", Vector2(BUMP_SCALE, BUMP_SCALE), BUMP_TIME)


## Contrae el nodo a su tamaño original
func _contract():
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "scale", Vector2(1, 1), BUMP_TIME)


#endregion
