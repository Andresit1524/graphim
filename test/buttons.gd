class_name Buttons extends VBoxContainer


signal delete_graph
signal save_graph_on_current
signal save_graph_as
signal load_graph


@onready var delete_button: Button = %DeleteButton
@onready var save_button: Button = %SaveButton


## Bandera que determina si el botón de borrar está presionado
var has_delete_button_pressed := false:
	set(value):
		has_delete_button_pressed = value
		delete_button.text = "Borrar todo" if not value else "¿Seguro?"


#region Botones


## Guarda el grafo en el archivo actual
func _on_save_button_pressed() -> void:
	save_graph_on_current.emit()
	mark_as_not_saved(false)
	has_delete_button_pressed = false


## Guarda en grafo en un archivo nuevo
func _on_save_as_button_pressed() -> void:
	push_warning("[Buttons] Función no implementada: Guardar como")
	save_graph_as.emit()
	mark_as_not_saved(false)
	has_delete_button_pressed = false


## Borra el grafo actual (con una verificación primero)
func _on_delete_button_pressed() -> void:
	if not has_delete_button_pressed:
		has_delete_button_pressed = true
		return

	delete_graph.emit()
	has_delete_button_pressed = false


## Carga un grafo desde un archivo
func _on_load_button_pressed() -> void:
	push_warning("[Buttons] Función no implementada: Cargar")
	load_graph.emit()
	has_delete_button_pressed = false


#endregion


#region Interfaz


## Marca el botón de guardar como cambios sin guardar
func mark_as_not_saved(value: bool) -> void:
	save_button.text = "%s Guardar" % ["(*) " if value else ""]


#endregion
