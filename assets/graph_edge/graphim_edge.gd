## Nodo de arista que une grafos en línea recta con el color y grosor dados
class_name GraphimEdge extends Area2D


const LABEL_OFFSET = 20.0


## Se emite cuando se clica el objeto
signal clicked(edge: GraphimEdge)
## Se emite cuando se elimina la arista
signal deleted(edge: GraphimEdge)


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
## Etiqueta para el peso
@onready var weight_label: Label = $Weight

## Datos de la arista
@onready var data: EdgeData = EdgeData.new()


# Posiciones globales
var last_start_global: Vector2
var last_end_global: Vector2


func _ready() -> void:
	data.directed_changed.connect(queue_redraw)
	data.color_changed.connect(_set_color)
	data.weight_changed.connect(_change_weight)

	# Refresca los datos
	data.refresh()

	Sounds.play_sound(&"pencil")


func _physics_process(_delta: float) -> void:
	# Omite el procesamiento si no es relevante
	if not data.has_valid_extremes(): return
	if not data.has_significant_movement(last_start_global, last_end_global): return

	last_start_global = data.start_node.global_position
	last_end_global = data.end_node.global_position
	global_position = (last_end_global + last_start_global) / 2

	# Actualiza con los puntos (locales por las necesidades de Curve2D)
	curve.points = PackedVector2Array([
		to_local(last_start_global), to_local(last_end_global)
	])

	# Dibujado de la punta de la flecha
	if data.directed: queue_redraw()

	# Actualización de la posición del peso
	_update_label_pos()


#region Visuales


## Dibuja una cabeza de flecha para la arista dirigida
func _draw() -> void:
	if curve.points.is_empty(): return

	# Extremos de la recta
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
		weight_label.label_settings.font_color = _color
		queue_redraw()
		return

	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_parallel()
	tween.tween_property(curve, ^"default_color", _color, Constants.EFFECT_TIME)
	tween.tween_property(weight_label.label_settings, ^"font_color", _color, Constants.EFFECT_TIME)
	tween.finished.connect(queue_redraw, CONNECT_ONE_SHOT)


## Establace el peso de la arista
func _change_weight(weight: float) -> void:
	weight_label.text = str(weight)


## Cambia la posición de la etiqueta si es necesario
func _update_label_pos() -> void:
	var rotation_index := _get_rotation_index()
	var new_label_pos := Vector2.ZERO

	# > 0.5: Arista hacia arriba, etiqueta a la derecha
	if rotation_index > 0.5: new_label_pos = Vector2.RIGHT
	# < 0.5: Arista en lateral, etiqueta arriba
	if rotation_index < 0.5: new_label_pos = Vector2.UP
	# < -0.5: Arsita hacia abajo, etiqueta a la izquierda
	if rotation_index < -0.5: new_label_pos = Vector2.LEFT

	weight_label.position = new_label_pos * LABEL_OFFSET - weight_label.size / 2


## Obtiene un índice de rotación en base al producto punto con el vector hacia arriba
func _get_rotation_index() -> float:
	var direction := (data.end_node.position - data.start_node.position).normalized()
	return Vector2.UP.dot(direction)


#endregion


#region Grosor de la arista


## Establece el grosor de la arista
func _set_thickness(value: float, tweened := false) -> void:
	if not tweened:
		curve.width = value
		return

	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(curve, ^"width", value, Constants.EFFECT_TIME)


## Aumenta el tamaño del nodo y lo deja como antes
func _bump() -> void:
	await _expand().finished
	_contract()


## Expande el nodo
func _expand() -> Tween:
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(curve, ^"width", thickness * Constants.BUMP_SCALE, Constants.EFFECT_TIME)
	return tween


## Contrae el nodo a su tamaño original
func _contract() -> Tween:
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(curve, ^"width", thickness, Constants.EFFECT_TIME)
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


## Maneja los clics sobre la arista
func _input_event(_viewport, event: InputEvent, _shape_idx) -> void:
	if event.is_action_pressed(&"left_click"): clicked.emit(self)

	if event.is_action_pressed(&"right_click"): deleted.emit(self)
