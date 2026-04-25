## Nodo de grafo con comportamientos de arrastre
class_name GraphimNode extends DraggableObject


## Escala al rebotar el nodo
const BUMP_SCALE := 1.1
## Tiempo de rebote
const EFFECT_TIME := 0.2


## Peso del nodo
@export var weight: float = 1:
	set(value):
		if not is_node_ready(): await ready
		weight = value
		_bump()
		_set_weight(value)
## Color del nodo
@export var color: Color = Color.WHITE:
	set(value):
		if not is_node_ready(): await ready
		color = value
		_bump()
		_set_color(value)


@onready var sprite: Sprite2D = $Sprite
@onready var label: Label = %Label


var velocity: Vector2
var last_global_pos := Vector2.ZERO


func _ready() -> void:
	dragging.connect(_set_drag_visuals)


func _physics_process(delta: float) -> void:
	var distance := global_position - last_global_pos
	last_global_pos = global_position

	velocity = distance / delta

	# Necesario para que funcione el arrastre con el mouse
	handle_dragging(delta)


#region Visuales


## Establece el color del nodo
func _set_color(_color: Color, tweened := false) -> void:
	if not tweened:
		sprite.modulate = _color
		return

	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", _color, EFFECT_TIME)


## Resalta un objeto
func _highlight(value: bool, tweened := false) -> void:
	var _color := Color.GRAY if value else Color.WHITE

	if not tweened:
		modulate = _color
		return

	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", _color, EFFECT_TIME)


## Establece el efecto visual al arrastrar el objeto
func _set_drag_visuals(value: bool) -> void:
	_highlight(value, true)

	if value: _expand()
	else: _contract()


#endregion


#region Tamaño del nodo


## Aumenta el tamaño del nodo y lo deja como antes
func _bump() -> void:
	await _expand().finished
	_contract()


## Expande el nodo
func _expand() -> Tween:
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "scale", Vector2(BUMP_SCALE, BUMP_SCALE), EFFECT_TIME)
	return tween


## Contrae el nodo a su tamaño original
func _contract() -> Tween:
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "scale", Vector2(1, 1), EFFECT_TIME)
	return tween


#endregion


#region Peso del nodo


## Cambia el peso del nodo
func _set_weight(value: float) -> void:
	label.text = str(value)


#endregion
