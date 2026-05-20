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


## Curva (para la arista)
@onready var curve: Line2D = $Curve

## Datos de la arista
@onready var data: EdgeData = EdgeData.new()


# Variables para optimizar el redibujado (en coordenadas globales)
var last_start_global: Vector2
var last_end_global: Vector2


func _ready() -> void:
	data.directed_changed.connect(queue_redraw)
	data.color_changed.connect(_set_color)

	# Refresca los datos
	data.refresh()

	# ! Debug: conectarse al azar a otro nodo
	var available_nodes := get_tree().get_nodes_in_group(&"nodes")
	data.end_node = available_nodes.pick_random()
	available_nodes.erase(data.end_node)
	data.start_node = get_tree().get_nodes_in_group(&"nodes").pick_random()
	data.directed = [true, false].pick_random()


func _physics_process(_delta: float) -> void:
	# Omite el procesamiento si no se puede o si hubo movimiento significativo
	if not data.has_valid_extremes(): return
	if not data.has_significant_movement(last_start_global, last_end_global): return

	last_start_global = data.start_node.global_position
	last_end_global = data.end_node.global_position

	# Actualiza con los puntos (locales por las necesidades de Curve2D)
	curve.points = PackedVector2Array([
		to_local(last_start_global), to_local(last_end_global)
	])

	# Exije el dibujado de las cabezas de flecha si es el caso
	if data.directed: queue_redraw()


#region Visuales


## Dibuja una cabeza de flecha para la arista dirigida
func _draw() -> void:
	if curve.points.is_empty(): return

	# Extremos de la recta
	# ? Importante: Usa las posiciones LOCALES para dibujar
	var start_pos := curve.points[0]
	var end_pos := curve.points[1]

	# No dibujar si no es dirigida o si no hay puntos válidos
	if not data.directed or start_pos.is_equal_approx(end_pos): return

	# Dirección unitaria de la arista (vector director)
	var director := (end_pos - start_pos).normalized()

	# Longitud de la flecha (lado del triángulo)
	var actual_size := thickness * arrowhead_size * 2

	# Mueve el triángulo hacia atras dependiendo del radio del nodo objetivo
	var node_radius := data.get_node_radius()
	var radius := director * node_radius

	# Omite el dibujo si el punto no está suficientemente lejos
	if (end_pos - start_pos).length() < actual_size: return
	var actual_position := end_pos - radius

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


#endregion


#region Grosor de la arista


## Establece el grosor de la arista
func _set_thickness(value: float, tweened := false) -> void:
	if not tweened:
		curve.width = value
		return

	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(curve, "width", value, Constants.EFFECT_TIME)


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


#region Setters y getters


## Establece el color de la arista
func _set_color(_color: Color) -> void:
	_bump()
	_change_color(_color, true)


## Crea una copia de los datos de la arista para su almacenamiento
func get_data_copy() -> EdgeData:
	return data.duplicate()


#endregion
