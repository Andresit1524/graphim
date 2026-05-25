class_name Buttons extends VBoxContainer


signal delete
signal save
signal save_as
signal load


@onready var delete_button: Button = %DeleteButton
@onready var save_button: Button = %SaveButton


## Bandera que determina si el botón de borrar está presionado
var has_delete_button_pressed := false:
	set(value):
		has_delete_button_pressed = value
		delete_button.text = "Borrar todo" if not value else "¿Seguro?"


## Guarda el grafo en el archivo actual
func _on_save_button_pressed() -> void:
	save.emit()
	has_delete_button_pressed = false


## Guarda en grafo en un archivo nuevo
func _on_save_as_button_pressed() -> void:
	save_as.emit()
	has_delete_button_pressed = false


## Borra el grafo actual (con una verificación primero)
func _on_delete_button_pressed() -> void:
	if not has_delete_button_pressed:
		has_delete_button_pressed = true
		return

	delete.emit()
	has_delete_button_pressed = false


## Carga un grafo desde un archivo
func _on_load_button_pressed() -> void:
	load.emit()
	has_delete_button_pressed = false
