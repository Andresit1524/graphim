## Clase que almacena una instancia de un objeto y permite arrastrarlo para que se cree una instancia
## en la escena actual. Al implementar, la escena debe tener una propiedad que permita desactivar su
## interacción con otros objetos
class_name Instancer extends PanelContainer


## Escena a crear en el instanciador
@export var scene: PackedScene
## Escala para mostrar el objeto
@export var instance_size: float = 1.0
## Nombre de la propiedad que desactiva - deja quieto el objeto
@export var disable_property_name: StringName = &"disable"


func _ready() -> void:
	# Instancia una versión del objeto en la escena
	var instance: Node = scene.instantiate()
	add_child(instance)
	instance.position = size / 2
	instance.scale = Vector2(instance_size, instance_size)

	# Desactiva el objeto. Si la propiedad no existe, set no genera errores
	instance.set(disable_property_name, false)
