extends Node2D


var active_player: CharacterBody2D  # El personaje que actualmente controlas
signal swap_characters_signal
var player1: CharacterBody2D
var player2: CharacterBody2D
var is_moved: bool = false

var normal_zoom := Vector2(1.5, 1.5)
var zoomed_out := Vector2(0.5, 0.5) # ajustar
var zoom_speed := 5.0
var target_zoom := normal_zoom


func _ready() -> void:
	# Referencias a los personajes
	player1 = $Ramiro
	player2 = $Laura
	active_player = player2 #alejandra
	Global.active_player_bruno = false
	Global.active_player_alejandra = true
	player1.is_active = false
	player2.is_active = true  # Inicia desactivado


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cambiar") and Global.can_swap:
		swap_characters()


func swap_characters() -> void:
	if active_player == player1:
		active_player = player2
		player1.is_active = false
		player2.is_active = true
		Global.active_player_alejandra = true
		Global.active_player_bruno = false
		print("señal player 2")
	else:
		active_player = player1
		player1.is_active = true
		player2.is_active = false
		Global.active_player_bruno = true
		Global.active_player_alejandra = false
		print("señal player 1")
	swap_characters_signal.emit()
	
	
