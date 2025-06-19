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
@onready var bondi_de_frente = $Parallaxes/Parallax2D_FONDO_vereda/BondiFrenteMotor

var bruno_puede_cambio_automatico:bool = true

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
	_resetar_dialogos()
	bruno_puede_cambio_automatico = true


	

func _process(delta: float) -> void:
	##ANIMACION CAMARA ENTRE PERSONAJES
	if active_player:
		camera.global_position = camera.global_position.lerp(to_local(active_player.global_position), delta * 8.0)
	camera.zoom = camera.zoom.lerp(target_zoom, delta * zoom_speed)
	_chequear_estado_juego()

func _chequear_estado_juego():
	if Global.game_over:
		_game_over()
	if Global.primer_nivel_win:
		_victoria()
		
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
	
	
#CAMBIAR A PANTALLA DE GAME OVER
func _game_over():
	Dialogic.end_timeline()
	var escena = load("res://Levels/escenas_utiles/pantalla_muerte.tscn") as PackedScene
	if escena:
		get_tree().change_scene_to_packed(escena)
	else:
		push_error("No se pudo cargar la escena Game Over")

func _victoria():
	Dialogic.end_timeline()
	var escena = load("res://Levels/escenas_utiles/pantalla_de_victoria.tscn")
	if escena:
		get_tree().change_scene_to_packed(escena)
	else:
		push_error("No se pudo cargar la escena victoria")

#DIALOGOS EN EL ESCENARIO
func _on_primer_dialogo_body_entered(body: Node2D) -> void:
	if body.is_in_group("grupo-laura") and !Dialogos.inicio_ambos_pj_bool:
		Dialogos.inicio_ambos_pj($Laura/Marker2D2,$Ramiro/Marker2D2)
		Dialogos.inicio_ambos_pj_bool = true
		
func _on_dialogo_bondi_body_entered(body: Node2D) -> void:
	if body.is_in_group("grupo-laura") and !Dialogos.colectivero_inicio_bool:
		Dialogos.colectivero_inicio($Laura/Marker2D2,$Ramiro/Marker2D2,$Marker2D_colectivero)
		Dialogos.colectivero_inicio_bool = true
		
	bondi_de_frente.apagar_bondi_anim("bondi_apagado")
	
func _on_dialogo_cables_pelados_body_entered(body: Node2D) -> void:
	if body.is_in_group("grupo-laura") and !Dialogos.cables_pelados_bool:
		Dialogos.cables_pelados($Laura/Marker2D2,$Ramiro/Marker2D2)
		Dialogos.cables_pelados_bool = true

func _on_dialogo_mas_cables_pelados_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("grupo-laura") and !Dialogos.mas_cables_pelados_bool:
		Dialogos.mas_cables_pelados($Laura/Marker2D2,$Ramiro/Marker2D2)
		Dialogos.mas_cables_pelados_bool = true

func _resetar_dialogos():
	Dialogos.inicio_ambos_pj_bool = false
	Dialogos.colectivero_inicio_bool = false
	Dialogos.cables_pelados_bool = false
	Dialogos.mas_cables_pelados_bool = false
	
#CAMBIAR A BRUNO CUANDO PASA POR EL AREA

func _on_cambiar_emocion_bruno_automatico_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador") and bruno_puede_cambio_automatico:
		print("deberia cambiar")
		swap_characters()
		bruno_puede_cambio_automatico = false
	if body.has_method("check_emocion"):
		body.check_emocion("normal")
