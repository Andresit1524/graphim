class_name NodeData extends RefCounted


## Señal que avisa de que el peso se ha actualizado
signal new_weight(new_value: float)
## Señal que avisa de que el color se ha actualizado
signal new_color(new_color: Color)


## Peso del nodo
var weight: float = 1.0:
	set(value):
		weight = value
		new_weight.emit(value)

## Color del nodo
# ! Tiene sentido que esté aca?
var color: Color = Color.WHITE:
	set(value):
		color = value
		new_color.emit(value)


## Refresca los datos
func refresh() -> void:
	new_weight.emit(weight)
	new_color.emit(color)
