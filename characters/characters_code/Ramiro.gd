class_name CharBruno
extends CharacterBody2D

###para empujar cajas####
@onready var push_area = $empujarCajas
var joint: PinJoint2D = null
var current_box: RigidBody2D = null
var esta_empujando:bool = false

#raycast bobo
@onready var raycast_detecta_arista_der: RayCast2D = $RayCast2D_arista_der # para filo de aristas
@onready var raycast_detecta_arista_izq: RayCast2D = $RayCast2D_arista_izq
@onready var plat_hombros = $"plataforma-hombros/colision_hombros"
var posicion_anterior: Vector2

#emociones
@onready var zona_cauta = $zona_cauta

##movimiento##
@export var speed: float = 100.0 #Velocidad horizontal
@export var speedLauraOnTop:float = 90.0 #velocidad con laura encima
@export var jump_force: float = 350.0 #Fuerza del salto
@export var dist_chico_enojado: float = 200.0 #distancia a que sigue a chico cuando Bobo
var paso_timer := 0.0 # para reiniciar cuando no se mueve mas
var intervalo_pasos := 0.4  # Tiempo entre los pasos
@onready var sprite = $AnimatedSprite2D
var is_active: bool = false  #variable para controlarjugador activo
var gravity = Global.gravity
var is_jumping := false
var played_apex = false
@onready var flecha = %Flecha_UI
@onready var timer_flecha = $Flecha_UI/Timer_flecha
var estaba_activo = false

#distancia de ale
@export var dist_grande_enojado: float = 500.0 #distancia de seguridad a bruno enojado
@export var dist_seguridad_altura: float = 200.0 # dif de altura de seguridad a bruno enojado
var rayo_enojo: Line2D = null # rayo de peligro si ale esta cerca de bruno enojado
const rayo_enojo_ancho: float = 1.0

@onready var objetivo = get_tree().get_nodes_in_group("grupo-laura")
@onready var ale = objetivo[0]

func _ready() -> void:
	flecha.visible = true
	zona_cauta.disable_mode = true
	posicion_anterior = global_position
	


func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO
	#SI cambio de pj esta desabilitado#
	if Input.is_action_pressed("cambiar") and Global.can_swap == false:			
		_cambiar_esta_desabilitado()
	#MOVER PERSONAJE#
	if Emociones.seguir_a_laura:
		_seguir_a_laura()
		self.is_active = false
		Global.can_swap = false
	if is_active :
		direction = _procesar_input_movimiento()

	if Emociones.e_grande_quiere_birra:
		_handle_velocity_enojado(direction, delta)
	else:
		_handle_velocity(direction, delta)
		
	move_and_slide()
	update_animation(direction)
	_update_flechita()
	_ale_zona_cauta()
	
	if is_on_floor() and velocity.length() > 10: #sistema para el sonido de pasos
		paso_timer -= delta
		if paso_timer <= 0:
			$SonidoPasos_bruno.play()
			paso_timer = intervalo_pasos
	else:
		$SonidoPasos_bruno.stop()
		paso_timer = 0 
		
	
	
func _procesar_input_movimiento() -> Vector2:
	var dir = Vector2.ZERO
	if Input.is_action_pressed("derecha"):
		dir.x += 1
	if Input.is_action_pressed("izquierda"):
		dir.x -= 1
	if Input.is_action_just_pressed("salto") and is_on_floor():
		velocity.y = -jump_force
		is_jumping = true #para animacion
		played_apex = false
		sprite.play("pre_salto")
	if Input.is_action_just_pressed("empujar") and joint == null:
		empujar_caja()
	if Input.is_action_just_released("empujar"):
		remove_joint()
	return dir

func _handle_velocity(direction: Vector2, delta):
	velocity.x = direction.x * speed # Aplica movimiento horizontal
	velocity.y += gravity * delta# Aplicar gravedad al personaje

func _handle_velocity_enojado(direction: Vector2, delta):
	var direccion_a_ale = sign(ale.global_position.x - global_position.x) # 1 si bruno a la derecha
	var vector_a_ale: Vector2 = (ale.global_position + Vector2(0, -60.0)) - self.global_position
	var dist_a_ale: float = vector_a_ale.length()
	#var altura_a_ale: float = abs(ale.global_position.y - self.global_position.y)
	var freezar_a_bruno: bool = dist_a_ale <= dist_grande_enojado and (direccion_a_ale == sign(direction.x)) and _bruno_a_la_vista()# and altura_a_ale < dist_seguridad_altura
		
	if freezar_a_bruno: #and altura_a_bruno < dist_seguridad_altura:
		velocity.x = 0 #direction.x * speed * -1 # Aplica movimiento horizontal
		print("En el limite y yendo a Bruno")
	else:
		velocity.x = direction.x * speed # Aplica movimiento horizontal
	velocity.y += gravity * delta# Aplicar gravedad al personaje

func _bruno_a_la_vista() -> bool:
	var space_state := get_world_2d().direct_space_state # Get de space state, permite queries de fisica.
	var ray_origin :Vector2= self.global_position + Vector2(0, -70.0) # calculo en 60 altura de ojos de ale
	var ray_target :Vector2= ale.global_position + Vector2(0, -60.0) # calculo altura pecho de bru
	var query := PhysicsRayQueryParameters2D.create(ray_origin, ray_target) # parametros del query 
	
	query.exclude = [self, ale] # excluir a ambos personajes del raycast
	query.collision_mask = 1 + 8 # fijarse que usa el value del bit, ver pop up en mask de la collision
	

	var result: Dictionary = space_state.intersect_ray(query) # ejecuta la query.
	print ("Bruno a la vista: ", result.is_empty())
	
	var rayo_enojo_color = Color.GREEN if result else Color.RED
	_update_rayo_enojo(self.global_position+Vector2(0,-140), ale.global_position+Vector2(0,-60) , rayo_enojo_color)
	
	return result.is_empty() # si no hay nada en el diccionario, no cruzo nada, Bruno esta a la vista
	
func _update_rayo_enojo(start_pos: Vector2, end_pos: Vector2, color: Color):
	if not is_instance_valid(rayo_enojo):
		rayo_enojo = Line2D.new()
		rayo_enojo.width = rayo_enojo_ancho
		add_child(rayo_enojo)
	
	rayo_enojo.points = [to_local(start_pos), to_local(end_pos)]
	rayo_enojo.default_color = color

func _remove_rayo_enojo() -> void: # saca linea de la escena
	if is_instance_valid(rayo_enojo):
		rayo_enojo.queue_free()
		# Set our reference back to null so we know to create a new one next time.
		rayo_enojo = null
		
		
func hacer_accion():
	pass
	
func _seguir_a_laura() -> Vector2:
	plat_hombros.disabled = true
	var objetivoLaura = get_tree().get_nodes_in_group("grupo-laura")
	var laura = objetivoLaura[0]
	var direccion_x = sign(laura.global_position.x - global_position.x)
	var dist_a_chico: float = abs(laura.global_position.x - self.global_position.x)
	raycast_detecta_arista_der.force_raycast_update()
	raycast_detecta_arista_izq.force_raycast_update()
	var hay_arista_a_der: bool = not raycast_detecta_arista_der.is_colliding()
	var hay_arista_a_izq: bool = not raycast_detecta_arista_izq.is_colliding()
	if dist_a_chico > abs(dist_chico_enojado): #se le acerca hasta dist_chico_enojado
		if (hay_arista_a_der and direccion_x == 1) or (hay_arista_a_izq and direccion_x == -1):
			velocity.x = 0
		else:
			velocity.x = direccion_x * speed
	else:
		velocity.x = 0  # Si ya está cerca, que no se mueva más
	move_and_slide()
	# Calcular cambio de posición real
	var delta_pos = global_position - posicion_anterior
	var direction = Vector2.ZERO
	if abs(delta_pos.x) > 0.5:
		direction.x = sign(delta_pos.x)
	posicion_anterior = global_position
	return direction

func _cambiar_esta_desabilitado():
	Dialogos.bruno_no_puede_cambiar($markerDialogos)

		
##---------ANIMACIONEs-----------S##
func update_animation(direction: Vector2):
	if not is_on_floor():#ANIMACION SALTO
		if velocity.y < 0:
			if sprite.animation != "salto":
				sprite.play("salto")  # Mientras sube
		elif velocity.y > 0:
			if sprite.animation != "caida":
				sprite.play("caida")  # Mientras cae
		return  # No seguir con animaciones normales
	elif Emociones.gordo_mood_normal:
		_animacion_normal(direction)

	elif Emociones.gordo_mood_enojado:
		_animacion_enojado(direction)

	elif Emociones.gordo_mood_bobo:
		var direccion_bobo = _seguir_a_laura()
		_animacion_embobado(direccion_bobo)
		
	elif esta_empujando:
		_animacion_empujar(direction)
		
	elif esta_empujando and Emociones.gordo_mood_enojado:
		_animacion_empujar_enojado(direction)
		
func _animacion_normal(direction : Vector2):
	if direction.x != 0:
		sprite.play("walk")
		sprite.flip_h = direction.x > 0
	else:
		sprite.play("idle")
		
func _animacion_enojado(direction : Vector2):
	if direction.x != 0:
		sprite.play("enojado_walk")
		sprite.flip_h = direction.x > 0
	else:
		sprite.play("enojado_idle")
		
func _animacion_enojado_in():
	
	sprite.play("enojado_in")
	
func _animacion_empujar(direction : Vector2):
	if direction.x != 0:
		sprite.play("empuja")
		sprite.flip_h = direction.x > 0
	else:
		sprite.play("idle")

func _animacion_empujar_enojado(direction : Vector2):
	if direction.x != 0:
		sprite.play("empuja_enojado")
		sprite.flip_h = direction.x > 0
	else:
		sprite.play("idle")	

var posicion_anterior_bobo := Vector2.ZERO

func _animacion_embobado(_direction: Vector2):
	var movimiento = global_position - posicion_anterior_bobo
	var esta_caminando = abs(movimiento.x) > 0.5  # Ajustá el umbral si hace falta

	if esta_caminando:
		if sprite.animation != "bobo_walk":
			sprite.play("bobo_walk")
		sprite.flip_h = movimiento.x > 0
	else:
		if sprite.animation != "bobo_idle":
			sprite.play("bobo_idle")
	
	posicion_anterior_bobo = global_position

##---------ANIMACIONEs-----------S##



### EMPUJAR CAJAS apretando BOTON
func empujar_caja():
	print("bruno empujando")
	for body in push_area.get_overlapping_bodies():
		esta_empujando = true
		if body is RigidBody2D:
			current_box = body
			create_joint_with_box(current_box)
			break

func create_joint_with_box(box: RigidBody2D):
	joint = PinJoint2D.new()
	joint.node_a = get_path()  # Personaje
	joint.node_b = box.get_path()  # Caja	
	joint.position = global_position.lerp(box.global_position, 0.5)	
	get_parent().add_child(joint)
	
func remove_joint():
	if joint and joint.get_parent():
		joint.queue_free()
	joint = null
	current_box = null
	esta_empujando = false



##---------EMCIONES-----------S##
func check_emocion(emocion:String):
	match emocion:
		"normal":
			print("emocion normal")
			Emociones.gordo_mood_normal = true#ESTE
			Emociones.gordo_mood_enojado= false
			Emociones.gordo_mood_rockeando = false
			Emociones.gordo_mood_triste= false
			Emociones.gordo_mood_bobo= false
			Emociones.seguir_a_laura = false#desactiva el seguimiento a alejandra
			Global.can_swap = true #revisar
			plat_hombros.disabled = false


		"enojado":
			print("emocion enojado")
			Emociones.gordo_mood_normal = false
			Emociones.gordo_mood_enojado= true#ESTE
			_animacion_enojado_in()
			Emociones.gordo_mood_rockeando = false
			Emociones.gordo_mood_triste= false
			Emociones.gordo_mood_bobo= false
			Emociones.seguir_a_laura = false#desactiva el seguimiento a alejandra
			plat_hombros.disabled = true


		"bobo":
			print("emocion bobo")
			Emociones.gordo_mood_normal = false
			Emociones.gordo_mood_enojado= false
			Emociones.gordo_mood_rockeando = false
			Emociones.gordo_mood_triste= false
			Emociones.gordo_mood_bobo= true#ESTE
			Emociones.seguir_a_laura = true#activa el seguimiento a alejandra
			Global.can_swap = false

func _ale_zona_cauta():
	if Emociones.laura_mood_cauta:
		zona_cauta.disable_mode = false
	else:
		zona_cauta.disable_mode = true	
##---------EMCIONES-----------S##

enum GordoMood { NORMAL, ENOJADO, BOBO, TRISTE }
var mood: GordoMood = GordoMood.NORMAL



#---------- FLECHA SOBRE PERSONAJE-----------
func _update_flechita():
	if Global.active_player_bruno and not estaba_activo:
		flecha.visible = true
		timer_flecha.start()
		estaba_activo = true
	elif not Global.active_player_bruno:
		flecha.visible = false
		timer_flecha.stop()
		estaba_activo = false

func _on_timer_flecha_timeout() -> void:
	print("termino el timer")
	flecha.visible = false
#---------- FLECHA SOBRE PERSONAJE-----------
