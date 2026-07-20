class_name UI extends Control


## Lista de botones
@onready var action_buttons: Buttons = %Actions
## Texto de la lista de objetos
@onready var count_text: RichTextLabel = %Count
## Etiqueta de FPS
@onready var fps_label = %FPS
## Etiqueta de archivo actual
@onready var current_file: Label = $CurrentFile

## Lista de nodos del grafo
@onready var nodes: Node2D = %Nodes
## Lista de aristas
@onready var edges: Node2D = %Edges


## Nombres de los nodos
var nodes_names: String:
	set(value):
		nodes_names = value
		update_objects_count()
## Nombres de las aristas
var edges_names: String:
	set(value):
		edges_names = value
		update_objects_count()


func _physics_process(_delta) -> void:
	# Actualiza los FPS
	fps_label.text = "FPS: %s" % Engine.get_frames_per_second()


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


func _unhandled_input(event: InputEvent) -> void:
	# Resetea el botón de borrar si se clica por fuera
	if event is InputEventMouseButton and event.is_pressed():
		action_buttons.has_delete_button_pressed = false
