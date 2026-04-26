## Nodo de arista que une grafos en línea recta con el color y grosor dados
class_name GraphimEdge extends Node2D


# TODO: recomendado mover estas constantes a un autoload

## Escala al rebotar el nodo
const BUMP_SCALE := 2
## Tiempo de rebote
const EFFECT_TIME := 0.2
## Epsilon para optimizaciones
const EPSILON := 1


## Primer nodo a unir
@export var node_a: GraphimNode
## Segundo nodo a unir
@export var node_b: GraphimNode

@export_group("Visualización")
## Color del trazo
@export var color: Color = Color.WHITE:
	set(value):
		if not is_node_ready(): await ready
		color = value
		_bump()
		_set_color(value, true)
## Grosor del trazo
@export var thickness: float = 5.0:
	set(value):
		if not is_node_ready(): await ready
		thickness = value
		_set_thickness(value, true)


@onready var curve: Line2D = $Curve


var last_a_pos: Vector2
var last_b_pos: Vector2


func _physics_process(_delta: float) -> void:
	if not node_a or not node_b: return

	# Añade los puntos entre los nodos para conectarlos
	var points := []
	var a_pos := to_local(node_a.global_position)
	var b_pos := to_local(node_b.global_position)

	# Omite el procesamiento si el punto no es suficientemente lejos
	if ((a_pos - last_a_pos).length_squared() < EPSILON
	and (b_pos - last_b_pos).length_squared() < EPSILON): return

	last_a_pos = to_local(a_pos)
	last_b_pos = to_local(b_pos)

	curve.points = PackedVector2Array([a_pos, b_pos])


#region Visuales


## Establece el color de la arista
func _set_color(_color: Color, tweened := false) -> void:
	if not tweened:
		curve.default_color = _color
		return

	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(curve, "default_color", _color, EFFECT_TIME)


## Establece el grosor de la arista
func _set_thickness(value: float, tweened := false) -> void:
	if not tweened:
		curve.width = value
		return

	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(curve, "width", value, EFFECT_TIME)


#endregion


#region Grosor de la arista


## Aumenta el tamaño del nodo y lo deja como antes
func _bump() -> void:
	await _expand().finished
	_contract()


## Expande el nodo
func _expand() -> Tween:
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(curve, "width", thickness * BUMP_SCALE, EFFECT_TIME)
	return tween


## Contrae el nodo a su tamaño original
func _contract() -> Tween:
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(curve, "width", thickness, EFFECT_TIME)
	return tween


#endregion
