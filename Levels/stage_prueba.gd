extends Node2D

var active_player: CharacterBody2D  # El personaje que actualmente controlas
var player1: CharacterBody2D
var player2: CharacterBody2D

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
