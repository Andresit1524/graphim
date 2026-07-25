class_name UI extends Control


## Lista de botones
@onready var action_buttons: Buttons = %Actions
## Texto de la lista de objetos
@onready var count_text: RichTextLabel = %Count
## Etiqueta de FPS
@onready var fps_label = %FPS
## Etiqueta de archivo actual
@onready var current_file: Label = $CurrentFile
## Etiqueta para instrucciones
@onready var instructions_label: Label = %InstructionsLabel

## Lista de nodos del grafo
@onready var nodes: Node2D = %Nodes
## Lista de aristas
@onready var edges: Node2D = %Edges


# Botones para dibujar en el grafo
@onready var draw_edges_button: Button = %DrawEdgesButton
@onready var directed_edges_checkbox: CheckBox = %DirectedEdgesCheckbox
@onready var randomize_button: Button = %RandomizeButton

# Botones de acciones
@onready var save_button: Button = %SaveButton
@onready var save_as_button: Button = %SaveAsButton
@onready var delete_button: Button = %DeleteButton
@onready var load_button: Button = %LoadButton


## Bandera que determina si el botón de aristas dirigidas está activado
var directed_edges_disabled := false


func _physics_process(_delta) -> void:
	# Actualiza los FPS
	fps_label.text = "FPS: %s" % Engine.get_frames_per_second()


#region Interfaz


## Actualiza la lista de textos
func update_objects_count() -> void:
	if not is_instance_valid(nodes) or not is_instance_valid(edges): return
	count_text.text = (
		"[b]Nodos[/b]: %d\n[b]Aristas[/b]: %d"
		% [nodes.get_child_count(), edges.get_child_count()]
	)

	mark_as_not_saved()


## Actualiza el nombre de archivo
func set_file_name(file_name := "") -> void:
	current_file.text = file_name if file_name else "Grafo en escena"


## Establece el grafo como no guardado
func mark_as_not_saved(value := true) -> void:
	if value and not current_file.text.begins_with("(*) "):
		current_file.text = "(*) %s" % current_file.text


## Imprime una instrucción en la parte inferior de la pantalla
func print_instruction(msg := "") -> void:
	instructions_label.text = msg


## Limpia la instrucción
func clear_instruction() -> void:
	instructions_label.text = ""


func _unhandled_input(event: InputEvent) -> void:
	# Resetea el botón de borrar si se clica por fuera
	if event is InputEventMouseButton and event.is_pressed():
		action_buttons.is_delete_button_pressed = false


#endregion


#region Botones


## Desactiva todos los botones
func disable_all() -> void:
	directed_edges_disabled = directed_edges_checkbox.disabled

	draw_edges_button.disabled = true
	directed_edges_checkbox.disabled = true
	randomize_button.disabled = true

	save_button.disabled = true
	save_as_button.disabled = true
	delete_button.disabled = true
	load_button.disabled = true


## Activa todos los botones
func enable_all() -> void:
	draw_edges_button.disabled = false
	directed_edges_checkbox.disabled = directed_edges_disabled
	randomize_button.disabled = false

	save_button.disabled = false
	save_as_button.disabled = false
	delete_button.disabled = false
	load_button.disabled = false


#endregion
