extends Node2D

var active_player: CharacterBody2D  # El personaje que actualmente controlas
var player1: CharacterBody2D
var player2: CharacterBody2D
var is_moved: bool = false
@onready var camera = $Camera2D
var normal_zoom := Vector2(2.0, 2.0)
var zoomed_out := Vector2(0.9, 0.9) # ajustar
var zoom_speed := 5.0
var target_zoom := normal_zoom

func _ready() -> void:
	# Referencias a los personajes
	player1 = $Ramiro
	player2 = $Laura
	active_player = player1
	player1.is_active = true
	player2.is_active = false  # Inicia desactivado
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
	else:
		active_player = player1
		player1.is_active = true
		player2.is_active = false

####COLISIONES CON ZONAS QUE CAMBIAN EMOCIONES SEGUN JUGADOR

func _on_area_enojo_laura_body_entered2(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		print("Es personaje entro:", body)
		if body.has_method("check_emocion"):
			print("colision")
			body.check_emocion("enojada")


func _on_area_enojo_laura_body_exited2(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		print("Es personaje salio:", body)
		if body.has_method("check_emocion"):
			body.check_emocion("normal")
