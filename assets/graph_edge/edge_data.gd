## Contiene los datos de una arista, listo para serializar
class_name EdgeData extends Resource

## Emitida cuando cambia el caracter de arista dirigida
signal directed_changed()
## Emitida cuando se cambia el peso del nodo
signal weight_changed(new_weight: float)
## Emitida cuando el color cambia
signal color_changed(new_color: Color)


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
@export var color: Color = GraphColors.BASE:
	set(value):
		color = value
		color_changed.emit(value)

## Identificador del nodo de inicio
@export var start_uid: int
## Identificador del nodo de final
@export var end_uid: int


## Nodo del inicio de la arista
var start_node: GraphimNode:
	set(value):
		start_node = value
		if is_instance_valid(value) and is_instance_valid(value.data):
			start_uid = value.data.uid
		else:
			start_uid = 0
## Nodo del final de la arista
var end_node: GraphimNode:
	set(value):
		end_node = value
		if is_instance_valid(value) and is_instance_valid(value.data):
			end_uid = value.data.uid
		else:
			end_uid = 0


func _ready() -> void:
	refresh()


#region Manejo de datos externos


## Refresca los datos
func refresh() -> void:
	directed_changed.emit()
	color_changed.emit(color)
	weight_changed.emit(weight)


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
