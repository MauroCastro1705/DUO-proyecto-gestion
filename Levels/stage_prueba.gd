extends Node2D

var active_player: CharacterBody2D  # El personaje que actualmente controlas
var player1: CharacterBody2D
var player2: CharacterBody2D
@onready var posicionPuertaInicial = %puerta.global_position.y
var posicionPuertaFinal = -102
var is_moved: bool = false
func _ready() -> void:
	# Referencias a los personajes
	player1 = %Gordo
	player2 = %Flaco	
	active_player = player1
	player1.is_active = true
	player2.is_active = false  # Inicia desactivado
	


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cambiar"):
		swap_characters()

func swap_characters() -> void:
	if active_player == player1:
		active_player = player2
		player1.is_active = false
		player2.is_active = true
	else:
		active_player = player1
		player1.is_active = true
		player2.is_active = false


func _on_boton_boton_pulsado() -> void:		
	if is_moved:
		%puerta.global_position.y = posicionPuertaInicial
		is_moved = false
	else:
		%puerta.global_position.y = posicionPuertaFinal
		is_moved=true
