## Clase que almacena una instancia de un objeto y permite arrastrarlo para que se cree una instancia
## en la escena actual. Al implementar, la escena debe tener una propiedad que permita desactivar su
## interacción con otros objetos
class_name Instancer extends PanelContainer


# TODO: Comentarios


## Escena a crear en el instanciador
@export var scene: PackedScene
## Escala para mostrar el objeto
@export var instance_size: float = 1.0
## Nombre de la propiedad que desactiva - deja quieto el objeto
@export var disable_property_name: StringName = &"disable"
## Nodo objetivo para albergar las instancias
@export var instances_node: Node


var is_dragging := false
var preview_node: Node = null


func _ready() -> void:
	if not scene: return

	# Instancia una versión del objeto para mostrar en el panel
	var instance: Node = scene.instantiate()
	add_child(instance)
	instance.position = size / 2
	instance.scale = Vector2(instance_size, instance_size)

	# Desactiva el objeto dentro del panel
	instance.set(disable_property_name, true)


func _gui_input(event: InputEvent) -> void:
	if not scene: return
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT): return

	if event.pressed: _start_drag()
	elif is_dragging: _end_drag()


func _input(event: InputEvent) -> void:
	if is_dragging and event is InputEventMouseMotion and preview_node and preview_node is Node2D:
		preview_node.global_position = get_global_mouse_position()


func _start_drag() -> void:
	is_dragging = true

	preview_node = scene.instantiate()
	if not preview_node is Node2D: return

	preview_node.scale = Vector2(instance_size, instance_size)
	preview_node.modulate.a = 0.5
	preview_node.set(disable_property_name, true)

	# Añadir a la raíz para evitar recortes de contenedores UI
	get_tree().root.add_child(preview_node)
	preview_node.global_position = get_global_mouse_position()


func _end_drag() -> void:
	is_dragging = false
	var final_pos = get_global_mouse_position()

	if preview_node:
		preview_node.queue_free()
		preview_node = null

	# Instancia de forma definitiva y añade al nodo indicado
	var final_instance = scene.instantiate()
	var location = instances_node if instances_node else get_tree().current_scene
	if not final_instance is Node2D: return

	location.add_child(final_instance)
	final_instance.global_position = final_pos
	final_instance.scale = Vector2(1, 1)
	final_instance.set(disable_property_name, false)
