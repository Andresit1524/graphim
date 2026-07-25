## Clase base para un algoritmo sobre un grafo. Forma de uso: método [start] para
@abstract class_name BaseAlgorithm extends Node


## Nombre del algoritmo para poner en el botón
@export var button_name: String = ""


## Mundo
@onready var world: Node2D = get_tree().current_scene


## Inicia a procesar el algoritmo al presionar su botón
@abstract func start() -> void
