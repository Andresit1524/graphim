class_name EdgeData extends RefCounted


#region Variables y señales


## Emitida cuando alguno de los dos extremos cambia
# TODO: implementar este
signal extremes_changed(new_start: GraphimNode, new_end: GraphimNode)
## Emitida cuando cambia el caracter de arista dirigida
signal directed_changed()
## Emitida cuando el peso cambia
# TODO: implementar este
signal weight_changed(new_weight: float)

## Emitida cuando el color cambia
signal color_changed(new_color: Color)


## Nodo del inicio de la arista
var start_node: GraphimNode:
	set(value):
		start_node = value
		extremes_changed.emit(value, end_node)
## Nodo del final de la arista
var end_node: GraphimNode:
	set(value):
		end_node = value
		extremes_changed.emit(start_node, value)

## Define si la arista es dirigida o no
var directed: bool = false:
	set(value):
		directed = value
		directed_changed.emit()
## Define el peso de la arista
var weight: float = 1.0:
	set(value):
		weight = value
		weight_changed.emit(value)

## Color de la arista
# ! Tiene sentido que esté acá?
var color: Color = Color.WHITE:
	set(value):
		color = value
		color_changed.emit(value)


#endregion


#region Manejo de datos externos


## Refresca los datos
func refresh() -> void:
	extremes_changed.emit(start_node, end_node)
	directed_changed.emit()
	color_changed.emit(color)


## Obtiene el radio del sprite del nodo. Asumimos que los nodos son del mismo tamaño, y calculamos
## sobre el extremo final
func get_node_radius() -> float:
	return end_node.sprite.get_rect().size.x * end_node.scale.x / 2


#endregion


#region Validaciones


## Determina si la arista tiene extremos válidos
func has_valid_extremes() -> bool:
	return start_node and end_node


## Determina si la arista ha cambiado de posición de forma significativa dadas las posiciones anteriores
func has_significant_movement(last_start: Vector2, last_end: Vector2) -> bool:
	return (
		(start_node.global_position - last_start).length_squared() > Constants.EPSILON
		and (end_node.global_position - last_end).length_squared() > Constants.EPSILON
	)


#endregion
