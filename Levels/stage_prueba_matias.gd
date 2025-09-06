extends Node2D


var active_player: CharacterBody2D  # El personaje que actualmente controlas
signal swap_characters_signal
var player1: CharacterBody2D
var player2: CharacterBody2D
var is_moved: bool = false

@onready var ale_marker: Marker2D = $Alejandra/AleMarker
@onready var bruno_marker: Marker2D = $Bruno/BrunoMarker

@onready var camera = $Camera2D
var normal_zoom := Vector2(1.5, 1.5)
var zoomed_out := Vector2(0.5, 0.5) # ajustar
var zoom_speed := 5.0
var target_zoom := normal_zoom
@onready var bondi_de_frente = $Parallaxes/Parallax2D_FONDO_vereda/BondiFrenteMotor

func _ready() -> void:
	# Referencias a los personajes
	player1 = $Bruno
	player2 = $Alejandra
	_resetar_dialogos()


func _process(delta: float) -> void:
	_chequear_estado_juego()

func _chequear_estado_juego():
	if Global.game_over:
		_game_over()
	if Global.primer_nivel_win:
		_victoria()
		


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
		Dialogos.inicio_ambos_pj(ale_marker,bruno_marker)
		Dialogos.inicio_ambos_pj_bool = true
		
func _on_dialogo_bondi_body_entered(body: Node2D) -> void:
	if body.is_in_group("grupo-laura") and !Dialogos.colectivero_inicio_bool:
		Dialogos.colectivero_inicio(ale_marker,bruno_marker,$Marker2D_colectivero)
		Dialogos.colectivero_inicio_bool = true
		
	bondi_de_frente.apagar_bondi_anim("bondi_apagado")
	
func _on_dialogo_cables_pelados_body_entered(body: Node2D) -> void:
	if body.is_in_group("grupo-laura") and !Dialogos.cables_pelados_bool:
		Dialogos.cables_pelados(ale_marker,bruno_marker)
		Dialogos.cables_pelados_bool = true

func _on_dialogo_mas_cables_pelados_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("grupo-laura") and !Dialogos.mas_cables_pelados_bool:
		Dialogos.mas_cables_pelados(ale_marker,bruno_marker)
		Dialogos.mas_cables_pelados_bool = true
		
func _on_ale_cuando_bruno_se_enoja_body_entered(body: Node2D) -> void:
	if body.is_in_group("grupo-ramiro") and !Dialogos.se_enojo_bruno_bool:
		Dialogos.se_enojo_bruno(ale_marker)
		Dialogos.se_enojo_bruno_bool = true

func _resetar_dialogos():
	Dialogos.inicio_ambos_pj_bool = false
	Dialogos.colectivero_inicio_bool = false
	Dialogos.cables_pelados_bool = false
	Dialogos.mas_cables_pelados_bool = false
	Dialogos.se_enojo_bruno_bool = false
	
