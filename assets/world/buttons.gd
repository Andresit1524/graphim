class_name Buttons extends VBoxContainer


# Señales para los botones de acciones
signal delete
signal save
signal save_as
signal load


## Botón de borrar
@onready var delete_button: Button = %DeleteButton


## Bandera que determina si el botón de borrar está presionado
var is_delete_button_pressed := false:
	set(value):
		is_delete_button_pressed = value
		delete_button.text = "Borrar todo" if not value else "¿Seguro?"


## Guarda el grafo en el archivo actual
func _on_save_button_pressed() -> void:
	save.emit()
	is_delete_button_pressed = false


## Guarda en grafo en un archivo nuevo
func _on_save_as_button_pressed() -> void:
	save_as.emit()
	is_delete_button_pressed = false


## Borra el grafo actual (con una verificación primero)
func _on_delete_button_pressed() -> void:
	if not is_delete_button_pressed:
		is_delete_button_pressed = true
		return

	delete.emit()
	is_delete_button_pressed = false


## Carga un grafo desde un archivo
func _on_load_button_pressed() -> void:
	load.emit()
	is_delete_button_pressed = false
