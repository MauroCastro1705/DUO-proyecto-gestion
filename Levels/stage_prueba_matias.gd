extends Node2D


var active_player: CharacterBody2D  # El personaje que actualmente controlas
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
# --- NUEVO: parámetros de seguimiento/transition ---
var follow_speed := 8.0             # cuán rápido sigue al activo (más alto = más pegado)
var switch_snap_time := 0.25        # duración del tween inicial al cambiar
var cam_offset := Vector2(0, -16)   # pequeño offset para no centrar exacto en los pies

# Referencia al singleton del autoload (AJUSTAR si tu nombre difiere)
var _switch_mgr

@onready var bondi_de_frente = $Parallaxes/Parallax2D_FONDO_vereda/BondiFrenteMotor

func _ready() -> void:
	# Referencias a los personajes
	player1 = $Bruno
	player2 = $Alejandra
	_resetar_dialogos()
# --- NUEVO: referenciar el singleton del autoload y conectar señal ---
	# Si tu autoload se llama 'personajes_switch_manager', usá ese nombre aquí:
	_switch_mgr = PersonajesSwitchManager
	_switch_mgr.personaje_activo_ha_cambiado.connect(_on_personaje_activo_cambio)

	# Tomar el personaje activo inicial (si ya fue seteado por el manager)
	active_player = _switch_mgr.get_personaje_activo()
	if is_instance_valid(active_player):
		# Posicionar cámara directamente al empezar (sin tween al inicio)
		camera.global_position = active_player.global_position + cam_offset
	else:
		# Fallback (por si todavía no hay activo): podés elegir uno
		active_player = player1
		camera.global_position = active_player.global_position + cam_offset

	# Asegurar zoom inicial
	camera.zoom = normal_zoom
	target_zoom = normal_zoom
	
	# Llama estado inicial para este nivel
	#call_deferred("_set_estado_inicial_del_nivel")
	
	#recordar CAMBIE COLLISION MASKS de A yB


func _process(delta: float) -> void:
	_chequear_estado_juego()
	# Interpolación de zoom continua hacia target_zoom
	camera.zoom = camera.zoom.lerp(target_zoom, min(1.0, zoom_speed * delta))
	
func _physics_process(delta: float) -> void:
	# --- NUEVO: seguimiento suave continuo del personaje activo ---
	if is_instance_valid(active_player):
		var desired := active_player.global_position + cam_offset
		camera.global_position = camera.global_position.lerp(desired, min(1.0, follow_speed * delta))

func _set_estado_inicial_del_nivel():
	var estados = get_node("/root/EstadosManager")
	if estados:
		estados.forzar_estado(GlobalEnumIndices.Estado.E_CHICO_ENOJO_INICIAL)
	else:
		push_error("EstadosManager no encontrado")

func _on_personaje_activo_cambio(nuevo_personaje: Node) -> void:
	# Callback de la señal del manager cuando cambia el activo
	if not is_instance_valid(nuevo_personaje):
		return

	active_player = nuevo_personaje

	# (Opcional) un pequeño “pop” de zoom al cambiar para hacerlo más visible:
	target_zoom = zoomed_out
	create_tween().tween_callback(func(): target_zoom = normal_zoom).set_delay(0.15)

	# Tween de “enganche” inicial hacia el nuevo personaje (rápido) antes del follow continuo.
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(camera, "global_position", active_player.global_position + cam_offset, switch_snap_time)

	# Si además querés retocar el zoom en el cambio:
	tw.parallel().tween_property(camera, "zoom", normal_zoom, switch_snap_time)
	
	
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
	
