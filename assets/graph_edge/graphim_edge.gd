## Nodo de arista que une grafos en línea recta con el color y grosor dados
class_name GraphimEdge extends Node2D


@export_group("Visualización")
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
@onready var data: EdgeData = $Data


var last_start_pos: Vector2
var last_end_pos: Vector2


func _ready() -> void:
	data.directed_changed.connect(queue_redraw)
	data.color_changed.connect(_set_color)

	# Refresca los datos
	data.refresh()


func _physics_process(_delta: float) -> void:
	if not data.has_valid_extremes(): return

	# Añade los puntos entre los nodos para conectarlos
	var points := []
	var start_pos := to_local(data.start_node.global_position)
	var end_pos := to_local(data.end_node.global_position)

	# Omite el procesamiento si el punto no es suficientemente lejos
	if not data.has_significant_movement(last_start_pos, last_end_pos): return

	last_start_pos = start_pos
	last_end_pos = end_pos

	curve.points = PackedVector2Array([start_pos, end_pos])

	# Exije el dibujado de las cabezas de flecha si es el caso
	if data.directed: queue_redraw()


#region Visuales


## Dibuja una cabeza de flecha para la arista dirigida
func _draw() -> void:
	# No dibujar si no es dirigida o si no hay puntos válidos
	if not data.directed or last_start_pos == last_end_pos: return

	# Dirección unitaria de la arista (vector director)
	var director := (last_end_pos - last_start_pos).normalized()

	# Longitud de la flecha (lado del triángulo)
	var actual_size := thickness * arrowhead_size * 2

	# Mueve el triángulo hacia atras dependiendo del radio del nodo objetivo
	var node_radius := data.get_node_radius()
	var radius := director * node_radius

	# Omite el dibujo si el punto no está suficientemente lejos
	if (last_end_pos - last_start_pos).length() < actual_size: return
	var actual_position := last_end_pos - radius

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
func _change_color(_color: Color, tweened := false) -> void:
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


#region Setters


## Establece el color de la arista
func _set_color(_color: Color) -> void:
	_bump()
	_change_color(_color, true)


#endregion
