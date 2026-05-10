## [code]DragInstancer[/code] almacena un objeto y permite arrastrarlo para que se cree una instancia
## en el nodo dado. Al implementar, la escena debe tener una propiedad que permita desactivar su
## interacción con otros objetos, de forma recomendada.
class_name DragInstancer extends PanelContainer


## Escena a crear en el instanciador
@export var scene: PackedScene
## Nodo objetivo para albergar las instancias
@export var instances_node: Node
## Nombre de la propiedad que desactiva - deja quieto el objeto
@export var disable_property_name: StringName = &"disable"
## Invierte el valor de la propiedad para desactivar. Útil si la propiedad funciona a la inversa a como se requiere
@export var inverse_disable_value: bool = false

@export_group("Ajustes de instancia")
## Escala para mostrar el objeto en el panel
@export var instance_size: float = 1.0
## Decide si usar el tamaño original al instanciar o no
@export var reset_instance_size: bool = false


var is_dragging := false
## Nodo para la versión temporal al instanciar
var preview_node: Node = null


func _ready() -> void:
	if not scene:
		push_error("[DragInstancer] No tienes una escena definida para instanciar")
		return

	if not instances_node:
		push_warning("[DragInstancer] No hay nodo asignado para las instancias. Usando la escena actual")
		instances_node = get_tree().current_scene

	# Instancia una versión del objeto para mostrar en el panel
	var instance: Node = scene.instantiate()
	add_child(instance)

	# Posiciona la instancia en el centro automáticamente cuando se redimensiona el panel
	if instance is Node2D:
		instance.position = size / 2
		instance.scale = Vector2(1, 1) * instance_size

		# Actualización automática de la posición
		resized.connect(func(): instance.position = size / 2)

	# Desactiva el objeto dentro del panel
	instance.set(disable_property_name, true != inverse_disable_value)


#region Drag and drop


func _gui_input(event: InputEvent) -> void:
	if not scene: return
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT): return

	## Inicia y finaliza el arrastre dependiendo de si se presiona o suelta el mouse
	if event.pressed: _start_drag()
	elif is_dragging: _end_drag()


func _input(event: InputEvent) -> void:
	if not is_dragging or not event is InputEventMouseMotion: return
	if not preview_node or not preview_node is Node2D: return

	# Mueve el objeto mientras lo sigamos arrastrando
	preview_node.global_position = preview_node.get_global_mouse_position()


## Inicia al arrastre creando una instancia del objeto para mostrar temporalmente
func _start_drag() -> void:
	is_dragging = true

	# Instancia temporal
	preview_node = scene.instantiate()
	if not preview_node is Node2D: return

	# Desactiva y le da aspecto fantasma al objeto
	if reset_instance_size: preview_node.scale = Vector2(1, 1)
	else: preview_node.scale = Vector2(instance_size, instance_size)
	preview_node.modulate.a = 0.5
	preview_node.set(disable_property_name, true != inverse_disable_value)

	# Añadir a la raíz para evitar recortes de contenedores UI
	get_tree().root.add_child(preview_node)
	preview_node.global_position = preview_node.get_global_mouse_position()


## Finaliza el arrastre creando el objeto definitivo y poniéndole en su sitio
func _end_drag() -> void:
	is_dragging = false
	var mouse_pos = get_global_mouse_position()

	# Elimina la instancia temporal
	if preview_node:
		preview_node.queue_free()
		preview_node = null

	# Aborta el proceso si soltamos el mouse dentro del panel
	if get_global_rect().has_point(mouse_pos): return

	# Instancia de forma definitiva y añade al nodo indicado
	var final_instance = scene.instantiate()
	if not final_instance is Node2D: return

	instances_node.add_child(final_instance)

	# Configura el objeto final
	final_instance.global_position = final_instance.get_global_mouse_position()
	final_instance.scale = Vector2(1, 1)
	final_instance.set(disable_property_name, false != inverse_disable_value)


#endregion
