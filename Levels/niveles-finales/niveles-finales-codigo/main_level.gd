extends Node2D
@export var primer_nivel: PackedScene #nivel cargado
var active_player: CharacterBody2D  # El personaje que actualmente controlas
var player1: CharacterBody2D
var player2: CharacterBody2D
var is_moved: bool = false
@onready var camera = $Camera2D
@onready var level_container = $Level_Container
var normal_zoom := Vector2(1.0, 1.0)
var zoomed_out := Vector2(0.5, 0.5) # ajustar
var zoom_speed := 5.0
var target_zoom := normal_zoom
var current_level: Node = null

func _ready() -> void:
	# Referencias a los personajes
	player1 = %Laura
	player2 = %Ramiro
	active_player = player1
	player1.is_active = true
	player2.is_active = false  # Inicia desactivado
	camera.position = active_player.global_position
	camera.zoom = normal_zoom
	load_level(primer_nivel) #PRIMER NIVEL OBLIGATORIO
	
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

####CARGAR NIVEL NUEVO
func load_level(proximo_nivel: PackedScene):
	if current_level:
		current_level.queue_free()
	current_level = proximo_nivel.instantiate()
	level_container.add_child(current_level)	
	await get_tree().process_frame
	var start = current_level.get_node_or_null("StartPosition")
	if start:
		active_player.global_position = start.global_position
