extends Node2D


var active_player: CharacterBody2D  # El personaje que actualmente controlas
signal swap_characters_signal
var player1: CharacterBody2D
var player2: CharacterBody2D
var is_moved: bool = false
@onready var camera = $Camera2D
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
	camera.position = active_player.global_position
	camera.zoom = normal_zoom
	# Activar la cámara del jugador activo
	#player1.get_node("Camera2D").enabled = true
	#player2.get_node("Camera2D").enabled = false
	

func _process(delta: float) -> void:
	##ANIMACION CAMARA ENTRE PERSONAJES
	if active_player:
		camera.global_position = camera.global_position.lerp(to_local(active_player.global_position), delta * 8.0)
	camera.zoom = camera.zoom.lerp(target_zoom, delta * zoom_speed)
	#AUDIO PLAYER
	if Global.game_over:
		_game_over()

	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cambiar") and Global.can_swap:
		swap_characters()
	elif event.is_action_pressed("zoom_out"):
		target_zoom = zoomed_out
	elif event.is_action_released("zoom_out"):
		target_zoom = normal_zoom

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
	
	
#CAMBIAR A PANTALLA DE GAME OVER
func _game_over():
	var escena = load("res://Levels/escenas_utiles/pantalla_muerte.tscn") as PackedScene
	if escena:
		get_tree().change_scene_to_packed(escena)
	else:
		push_error("No se pudo cargar la escena Game Over")
	



#DIALOGOS EN EL ESCENARIO

func _on_primer_dialogo_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		Dialogos.primer_dialogo($Laura/Marker2D,$Ramiro/Marker2D2)#funciona goddd
