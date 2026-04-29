## Nodo de arista que une grafos en línea recta con el color y grosor dados
class_name GraphimEdge extends Node2D


## Primer nodo a unir
@export var node_a: GraphimNode
## Segundo nodo a unir
@export var node_b: GraphimNode
## Hace la arista dirigida
@export var directed: bool = false:
	set(value):
		directed = value
		queue_redraw()

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
## Tamaño de la cabeza de flecha
@export var arrowhead_size: float = 5:
	set(value):
		if not is_node_ready(): await ready
		arrowhead_size = value
		if value: queue_redraw()


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
	if ((a_pos - last_a_pos).length_squared() < Constants.EPSILON
	and (b_pos - last_b_pos).length_squared() < Constants.EPSILON): return

	last_a_pos = a_pos
	last_b_pos = b_pos

	curve.points = PackedVector2Array([a_pos, b_pos])
	if directed: queue_redraw()


#region Visuales


## Dibuja una cabeza de flecha para la arista dirigida
func _draw() -> void:
	# No dibujar si no es dirigida o si no hay puntos válidos
	if not directed or last_a_pos == last_b_pos: return

	# Dirección unitaria de la arista (vector director)
	var director := (last_b_pos - last_a_pos).normalized()

	# Longitud de la flecha (lado del triángulo)
	var actual_size := thickness * arrowhead_size * 2

	# Mueve el triángulo hacia atras dependiendo del radio del nodo objetivo
	var node_size := node_b.sprite.get_rect().size.x * node_b.scale.x
	var radius := director * node_size / 2

	# Omite el dibujo si el punto no está suficientemente lejos
	if (last_b_pos - last_a_pos).length() < actual_size: return
	var actual_position := last_b_pos - radius

	draw_polygon(
		# Rota 30 grados en ambas direcciones para armar el triángulo
		PackedVector2Array([
			actual_position,
			actual_position - director.rotated(PI / 6) * actual_size,
			actual_position - director.rotated(-PI / 6) * actual_size
		]),
		PackedColorArray([curve.default_color, curve.default_color, curve.default_color])
	)


## Establece el color de la arista
func _set_color(_color: Color, tweened := false) -> void:
	if not tweened:
		curve.default_color = _color
		queue_redraw()
		return

	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(curve, "default_color", _color, Constants.EFFECT_TIME)
	tween.finished.connect(queue_redraw, CONNECT_ONE_SHOT)


## Establece el grosor de la arista
func _set_thickness(value: float, tweened := false) -> void:
	if not tweened:
		curve.width = value
		return

	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(curve, "width", value, Constants.EFFECT_TIME)


#endregion


#region Grosor de la arista


## Aumenta el tamaño del nodo y lo deja como antes
func _bump() -> void:
	await _expand().finished
	_contract()


## Expande el nodo
func _expand() -> Tween:
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(curve, "width", thickness * Constants.BUMP_SCALE, Constants.EFFECT_TIME)
	return tween


## Contrae el nodo a su tamaño original
func _contract() -> Tween:
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(curve, "width", thickness, Constants.EFFECT_TIME)
	return tween


#endregion
