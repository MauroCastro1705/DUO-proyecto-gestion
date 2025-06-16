class_name CharAle
extends CharacterBody2D

@export var speed: float = 300.0     # Velocidad horizontal
@export var speed_empuja_fraccion: float = 0.75     # Reduccion velocidad al empujar
@export var jump_force: float = 850.0   # Fuerza del salto
@export var max_fall_speed: float = 1000.0
@export var fast_fall_multiplier: float = 2.0
@export var dist_grande_enojado: float = 500.0 #distancia de seguridad a bruno enojado
@export var dist_seguridad_altura: float = 200.0 # dif de altura de seguridad a bruno enojado
var rayo_enojo: Line2D = null # rayo de peligro si ale esta cerca de bruno enojado
const rayo_enojo_ancho: float = 1.0
@onready var sprite = $LauraSprites
@export var raycast_down: RayCast2D  # arrastrá tu RayCast2D en el editor aquí
var gravity = Global.gravity
var is_active: bool = false  #variable para controlar si se recibe input
###para empujar cajas####
@onready var push_area = $empujarCajas
var joint: PinJoint2D = null
var current_box: RigidBody2D = null
var mirando_a_la_derecha := true

var esta_empujando:bool = false
var esta_empujando_pesado:bool = false
#plataforma
var is_on_big_character = false
var big_character_velocity := Vector2.ZERO
var is_jumping := false
var played_apex = false
@onready var flecha = %Flecha_UI
@onready var flecha_timer = $Flecha_UI/Timer_flecha
var estaba_activo = false
var empujando = false #esta empujando o no el personaje

@onready var objetivo = get_tree().get_nodes_in_group("grupo-ramiro")
@onready var bruno = objetivo[0]

func _ready() -> void:

	Global.lauraOnTop = false
	flecha.visible = false


	
func _physics_process(delta: float) -> void:
	if raycast_down.is_colliding() and Emociones.gordo_mood_bobo:
		var collider = raycast_down.get_collider()
		_colision_sobre_ramiro(collider)
	var direction = Vector2.ZERO
	if is_active:
		direction = _procesar_input_movimiento()
		_aplicar_gravedad(delta)
	
	if Emociones.e_grande_quiere_birra:
		_handle_velocity_cauto(direction, delta)
	else:
		_handle_velocity(direction, delta)
	
	update_animation(direction)
	move_and_slide()
	_update_flechita()
	

func _procesar_input_movimiento() -> Vector2:
	var dir = Vector2.ZERO
	if Input.is_action_pressed("derecha"):
		dir.x += 1
		mirando_a_la_derecha = true
	if Input.is_action_pressed("izquierda"):
		dir.x -= 1
		mirando_a_la_derecha = false
	if Input.is_action_just_pressed("salto") and is_on_floor():  #and not empujando 
		#puede saltar si esta en el piso y no esta empujando
		velocity.y = -jump_force
		is_jumping = true #para animacion
		played_apex = false
		sprite.play("pre_salto")
	if Input.is_action_just_pressed("empujar") and joint == null:
		empujar_caja()
		speed = speed*speed_empuja_fraccion
		empujando = true 
		
	if Input.is_action_just_released("empujar"):
		speed = 400
		empujando = false
		remove_joint()
	return dir
	
func _handle_velocity(direction: Vector2, delta):
	velocity.x = direction.x * speed # Aplica movimiento horizontal
	velocity.y += gravity * delta# Aplicar gravedad al personaje

func _handle_velocity_cauto(direction: Vector2, delta):
	var direccion_a_bruno = sign(bruno.global_position.x - global_position.x) # 1 si bruno a la derecha
	var vector_a_bruno: Vector2 = (bruno.global_position + Vector2(0, -110.0)) - self.global_position
	var dist_a_bruno: float = vector_a_bruno.length()
	#var altura_a_bruno: float = abs(bruno.global_position.y - self.global_position.y)
	var freezar_a_ale: bool = dist_a_bruno <= dist_grande_enojado and (direccion_a_bruno == sign(direction.x)) and _bruno_a_la_vista()# and altura_a_bruno < dist_seguridad_altura
		
	if freezar_a_ale: #and altura_a_bruno < dist_seguridad_altura:
		velocity.x = 0 #direction.x * speed * -1 # Aplica movimiento horizontal
		print("En el limite y yendo a Bruno")
	else:
		velocity.x = direction.x * speed # Aplica movimiento horizontal
	velocity.y += gravity * delta# Aplicar gravedad al personaje


func _aplicar_gravedad( delta):
	if velocity.y > 0:  # Está cayendo
		velocity.y += gravity * fast_fall_multiplier * delta
	else:# NO Está cayendo
		velocity.y += gravity * delta

func _colision_sobre_ramiro(collider):
	if Emociones.gordo_mood_bobo == false:
		if collider.name == "plataforma-hombros":
			is_on_big_character = true
			big_character_velocity = collider.velocity
			Global.lauraOnTop = true
			velocity.x += big_character_velocity.x
		else:
			_no_esta_sobre_personaje()

func _no_esta_sobre_personaje():
		is_on_big_character = false
		Global.lauraOnTop = false
		big_character_velocity = Vector2.ZERO

func _bruno_a_la_vista() -> bool:
	var space_state := get_world_2d().direct_space_state # Get de space state, permite queries de fisica.
	var ray_origin :Vector2= self.global_position + Vector2(0, -60.0) # calculo en 60 altura de ojos de ale
	var ray_target :Vector2= bruno.global_position + Vector2(0, -70.0) # calculo altura pecho de bru
	var query := PhysicsRayQueryParameters2D.create(ray_origin, ray_target) # parametros del query 
	
	query.exclude = [self, bruno] # excluir a ambos personajes del raycast
	query.collision_mask = 1 + 8 # fijarse que usa el value del bit, ver pop up en mask de la collision

	var result: Dictionary = space_state.intersect_ray(query) # ejecuta la query.
	print ("Bruno a la vista: ", result.is_empty())
	
	var rayo_enojo_color = Color.GREEN if result else Color.RED
	_update_rayo_enojo(self.global_position+Vector2(0,-60), bruno.global_position+Vector2(0,-140) , rayo_enojo_color)
	
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

##---------ANIMACIONEs-----------S##
func update_animation(direction: Vector2):
	if not is_on_floor():
		if velocity.y < 0:
			if sprite.animation != "salto":
				sprite.play("salto")  # Mientras sube
		elif velocity.y > 0:
			if sprite.animation != "caida":
				sprite.play("caida")  # Mientras cae
		return  # No seguir con animaciones normales
	elif Emociones.laura_mood_enojado:
		if esta_empujando:
			_animacion_empujar_enojado(direction)
		else:
			_animacion_enojado(direction)
			
	elif esta_empujando:
		if esta_empujando_pesado:
			_animacion_empujar_pesado()
		else:
			_animacion_empujar(direction)

	else:#laura estado normal
		_animacion_normal(direction)

func _animacion_enojado(direction: Vector2):
	if direction.x != 0:
		sprite.play("walk_enojado")
		sprite.flip_h = direction.x > 0
	else:
		sprite.play("idle_enojado")
		
func _animacion_normal(direction: Vector2):
	if direction.x != 0:
		sprite.play("walk")
		sprite.flip_h = direction.x > 0
	else:
		sprite.play("idle")
		sprite.flip_h = direction.x > 0
		
		
func _animacion_empujar(direction: Vector2):
	if direction.x != 0:
		sprite.play("empuja")
		#sprite.flip_h = direction.x > 0
	else:
		sprite.play("idle")

func _animacion_empujar_pesado():
	sprite.play("empuja_fail")
	Dialogos.alejandra_caja_pesada($Markerdialogo)#DIALOGO desde otro script.
	
func _animacion_empujar_enojado(direction: Vector2):
	if direction.x != 0:
		sprite.play("empuja_enojado")
		#sprite.flip_h = direction.x > 0
	else:
		sprite.play("idle_enojado")
##---------ANIMACIONEs-----------S##


### EMPUJAR CAJAS apretando BOTON
func empujar_caja():
	print("empujando")
	for body in push_area.get_overlapping_bodies():
		if body is RigidBody2D and body.is_in_group("liviano"):
			esta_empujando_pesado = false
			esta_empujando = true
			current_box = body
			create_joint_with_box(current_box)
			break
		if body is RigidBody2D and !body.is_in_group("liviano"):
			esta_empujando = true
			esta_empujando_pesado = true
			
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
	esta_empujando=false
	esta_empujando_pesado = false





#---------EMOCIONES----------------------
#·····VARIABLES EN EMOCIONES.gd···
# Emociones.laura_mood_enojado = false
# Emociones.laura_mood_cauto = false
# Emociones.laura_mood_ignorando = false
# Emociones.laura_mood_rockeando = false
# Emociones.laura_mood_normal = true
#······································

func check_emocion(emocion:String):
	match emocion:
		"normal":
			print("emocion normal")
			Emociones.laura_mood_normal = true#ESTE
			Emociones.laura_mood_enojado= false
			Emociones.laura_mood_cauta = false
			Emociones.laura_mood_ignorando= false
			Emociones.laura_mood_rockeando= false

		"enojada":
			print("emocion enojada")
			Emociones.laura_mood_normal = false
			Emociones.laura_mood_enojado= true #ESTE
			Emociones.laura_mood_cauta = false
			Emociones.laura_mood_ignorando= false
			Emociones.laura_mood_rockeando= false
		"cauta":
			print("emocion cauta")
			Emociones.laura_mood_normal = false
			Emociones.laura_mood_enojado= false
			Emociones.laura_mood_cauta = true #ESTE
			Emociones.laura_mood_ignorando= false
			Emociones.laura_mood_rockeando= false

#---------EMOCIONES----------------------





#---------- FLECHA SOBRE PERSONAJE-----------
func _update_flechita():
	if Global.active_player_alejandra and not estaba_activo:
		flecha.visible = true
		flecha_timer.start()
		estaba_activo = true
	elif not Global.active_player_alejandra:
		flecha.visible = false
		flecha_timer.stop()
		estaba_activo = false

func _on_timer_flecha_timeout() -> void:
	flecha.visible = false
	print("termino el timer")
#---------- FLECHA SOBRE PERSONAJE-----------

#SISTEMA DE DIALOGOS
