## Clase que gestiona los algoritmos y su interfaz
class_name Algorithms extends Node


@onready var world: Node2D = get_tree().current_scene
## Botones para los algoritmos
@onready var algoritm_buttons: VBoxContainer = %AlgoritmButtons


func _ready() -> void:
	for algorithm: BaseAlgorithm in get_children():
		# Crea el botón
		var alg_button := Button.new()
		algoritm_buttons.add_child(alg_button)
		alg_button.pressed.connect(algorithm.start)

		alg_button.text = algorithm.button_name
		alg_button.autowrap_mode = TextServer.AUTOWRAP_WORD
