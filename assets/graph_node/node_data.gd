class_name NodeData extends Node


## Señal que avisa de que el peso se ha actualizado
signal weight_changed(new_value: float)
## Señal que avisa de que el color se ha actualizado
signal color_changed(new_color: Color)


## Peso del nodo
@export var weight: float = 1.0:
	set(value):
		weight = value
		weight_changed.emit(value)
## Color del nodo
@export var color: Color = Color.WHITE:
	set(value):
		color = value
		color_changed.emit(value)


## Refresca los datos
func refresh() -> void:
	weight_changed.emit(weight)
	color_changed.emit(color)
