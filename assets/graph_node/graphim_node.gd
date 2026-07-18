## Nodo de grafo con comportamientos de arrastre
class_name GraphimNode extends DraggableObject


## Emitida cuando se le hace clic al nodo. Útil para dibujar aristas
signal clicked(graphim_node: GraphimNode)


## Sprite del nodo
@onready var sprite: Sprite2D = $Sprite
## Forma de colisión del nodo
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
## Etiqueta del nodo para el peso
@onready var label: Label = %Label

## Datos del nodo
@onready var data: NodeData = NodeData.new()

## Última posición del nodo (para Verlet)
@onready var last_global_pos := global_position


## Desactiva el nodo y sus físicas. Usado para el DragInstancer
var disabled := false:
	set(value):
		if not is_node_ready(): await ready
		disabled = value
		_disable(value)

## Fuerza aplicada sobre el nodo
var force: Vector2


func _ready() -> void:
	# Conecta las señales para el arrastre y la actualización de datos
	dragging.connect(_set_drag_visuals)
	data.weight_changed.connect(_set_weight)
	data.color_changed.connect(_set_color)

	# Fuerza a actualiizar los datos
	data.refresh()


func _physics_process(delta: float) -> void:
	var current_pos := global_position

	# Actualiza la última posición
	last_global_pos = current_pos

	# Necesario para que funcione el arrastre con el mouse
	handle_dragging(delta)


## Activa o desactiva el nodo
func _disable(value: bool) -> void:
	input_pickable = not value
	collision_shape.disabled = value

	if value:
		remove_from_group(&"nodes")
	else:
		add_to_group(&"nodes")
		_reset_physics()


#region Visuales


## Establece el efecto visual al arrastrar el objeto
func _set_drag_visuals(value: bool) -> void:
	_highlight(value, true)

	if value: _expand()
	else: _contract()


## Cambia el color del nodo con posibilidad de tween para suavizado
func _change_color(_color: Color, tweened := false) -> void:
	if not tweened:
		sprite.modulate = _color
		return

	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, ^"modulate", _color, Constants.EFFECT_TIME)


## Resalta un objeto
func _highlight(value: bool, tweened := false) -> void:
	var _color := Color.GRAY if value else Color.WHITE

	if not tweened:
		modulate = _color
		return

	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, ^"modulate", _color, Constants.EFFECT_TIME)


#endregion


#region Tamaño del nodo


## Aumenta el tamaño del nodo y lo deja como antes
func _bump() -> void:
	await _expand().finished
	_contract()


## Expande el nodo
func _expand() -> Tween:
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, ^"scale", Vector2(1, 1) * Constants.BUMP_SCALE, Constants.EFFECT_TIME)
	return tween


## Contrae el nodo a su tamaño original
func _contract() -> Tween:
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, ^"scale", Vector2(1, 1), Constants.EFFECT_TIME)
	return tween


#endregion


#region Físicas


## Resetea la física del objeto (util al instanciar)
func _reset_physics() -> void:
	last_global_pos = global_position


## Aplica las fuerzas sobre el objeto dada la fricción a usar. Se usa desde afuera
func apply_forces(delta: float, damping: float) -> void:
	if disabled: return

	# Aplica Verlet con fricción sobre la velocidad (el desplazamiento)
	var inertia := (global_position - last_global_pos) * (1.0 - damping)
	var displacement := inertia + (force * delta * delta)

	# Usamos el motor de Godot para mover y detenernos si hay colisión
	move_and_collide(displacement)


#endregion


#region Setters y getters


## Cambia el peso del nodo
func _set_weight(value: float) -> void:
	label.text = str(value)


## Cambia el color del nodo
func _set_color(new_color: Color) -> void:
	_bump()
	_change_color(new_color, true)


## Crea una copia de los datos del nodo para su almacenamiento
func get_data_copy() -> NodeData:
	return data.duplicate()


#endregion


# Procesa los eventos (filtrando clics) para el dibujado de aristas
func _on_input_event(_viewport, event: InputEvent, _shape_idx) -> void:
	# Filtra los clics izquierdos
	if not (
		event is InputEventMouseButton
		and event.is_pressed()
		and event.button_index == MOUSE_BUTTON_LEFT
	): return

	clicked.emit(self)
