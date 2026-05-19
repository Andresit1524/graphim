class_name EdgeData extends Node


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
@export var start_node: GraphimNode:
	set(value):
		start_node = value
		extremes_changed.emit(value, end_node)
## Nodo del final de la arista
@export var end_node: GraphimNode:
	set(value):
		end_node = value
		extremes_changed.emit(start_node, value)

## Define si la arista es dirigida o no
@export var directed: bool = false:
	set(value):
		directed = value
		directed_changed.emit()
## Peso de la arista
@export var weight: float = 1.0:
	set(value):
		weight = value
		weight_changed.emit(value)
## Color de la arista
@export var color: Color = Color.WHITE:
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
	if not is_instance_valid(end_node): return 0

	# Asumimos un sprite cuadrado que toca a los bordes de su espacio
	return end_node.sprite.get_rect().size.x * end_node.scale.x / 2


#endregion


#region Validaciones


## Determina si la arista tiene extremos válidos, es decir, que existan y tengan buen largo
func has_valid_extremes() -> bool:
	if not start_node or not end_node: return false

	return (
		(end_node.global_position - start_node.global_position).length_squared() > Constants.EPSILON
	)


## Determina si la arista ha cambiado de posición de forma significativa dadas las posiciones anteriores (en global)
func has_significant_movement(last_start_global: Vector2, last_end_global: Vector2) -> bool:
	return (
		(start_node.global_position - last_start_global).length_squared() > Constants.EPSILON
		or (end_node.global_position - last_end_global).length_squared() > Constants.EPSILON
	)


#endregion
