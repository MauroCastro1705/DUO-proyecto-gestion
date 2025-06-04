extends CharacterBody2D

@export var speed: float = 400.0        # Velocidad horizontal
@export var jump_force: float = 850.0   # Fuerza del salto
@export var max_fall_speed: float = 1000.0
@export var fast_fall_multiplier: float = 2.0
@onready var sprite = $LauraSprites
@export var raycast_down: RayCast2D  # arrastrá tu RayCast2D en el editor aquí
var gravity = Global.gravity
var is_active: bool = false  #variable para controlar si se recibe input
###para empujar cajas####
@onready var push_area = $empujarCajas
var joint: PinJoint2D = null
var current_box: RigidBody2D = null
@onready var texto_character = $Label_empujando
#plataforma
var is_on_big_character = false
var big_character_velocity := Vector2.ZERO
var is_jumping := false
var played_apex = false
@onready var flecha = %Flecha_UI
@onready var flecha_timer = $Flecha_UI/Timer_flecha
var estaba_activo = false
var empujando = false #esta empujando o no el personaje

func _ready() -> void:
	Global.lauraOnTop = false
	flecha.visible = false
	texto_character.visible = false
	Emociones.laura_mood_cauta = true
	
func _physics_process(delta: float) -> void:
	if raycast_down.is_colliding() and Emociones.gordo_mood_bobo:
		var collider = raycast_down.get_collider()
		_colision_sobre_ramiro(collider)
	var direction = Vector2.ZERO
	if is_active:
		direction = _procesar_input_movimiento()
		_aplicar_gravedad(delta)
	_handle_velocity(direction, delta)
	update_animation(direction)
	move_and_slide()
	_update_flechita()

func _procesar_input_movimiento() -> Vector2:
	var dir = Vector2.ZERO
	if Input.is_action_pressed("derecha"):
		dir.x += 1
	if Input.is_action_pressed("izquierda"):
		dir.x -= 1
	if Input.is_action_just_pressed("salto") and is_on_floor() and not empujando: 
		#puede saltar si esta en el piso y no esta empujando
		velocity.y = -jump_force
		is_jumping = true #para animacion
		played_apex = false
		sprite.play("pre_salto")
	if Input.is_action_just_pressed("empujar") and joint == null:
		empujar_caja()
		speed = 150
		empujando = true 
		
	if Input.is_action_just_released("empujar"):
		texto_character.visible = false
		speed = 400
		empujando = false
		remove_joint()
	return dir
	
func _handle_velocity(direction: Vector2, delta):
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

#func hacer_accion():
#	Emociones.seguir_a_laura = true

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
	if Emociones.laura_mood_enojado:
		_animacion_enojado(direction)
	else:#laura estado normal
		_animacion_normal(direction)

func _animacion_enojado(direction: Vector2):
	if direction.x != 0:
		sprite.play("walk_enojado")
		sprite.flip_h = direction.x > 0
	else:
		sprite.play("idle")
		
func _animacion_normal(direction: Vector2):
	if direction.x != 0:
		sprite.play("walk")
		sprite.flip_h = direction.x > 0
	else:
		sprite.play("idle")
##---------ANIMACIONEs-----------S##

### EMPUJAR CAJAS apretando BOTON
func empujar_caja():
	print("empujando")
	texto_character.visible = true
	texto_character.text = "Empujando"
	for body in push_area.get_overlapping_bodies():
		if body is RigidBody2D and body.is_in_group("liviano"):
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
			Emociones.laura_mood_cauto = false
			Emociones.laura_mood_ignorando= false
			Emociones.laura_mood_rockeando= false
			Dialogic.start("timeline_test2")
			get_viewport().set_input_as_handled()
		"enojada":
			print("emocion enojada")
			Emociones.laura_mood_normal = false
			Emociones.laura_mood_enojado= true #ESTE
			Emociones.laura_mood_cauto = false
			Emociones.laura_mood_ignorando= false
			Emociones.laura_mood_rockeando= false
			Dialogic.start("timeline_test")
			get_viewport().set_input_as_handled()
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
