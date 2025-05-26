extends CharacterBody2D

###para empujar cajas####
@onready var push_area = $empujarCajas
var joint: PinJoint2D = null
var current_box: RigidBody2D = null

##movimiento##
@export var speed: float = 130.0 #Velocidad horizontal
@export var speedLauraOnTop:float = 90.0 #velocidad con laura encima
@export var jump_force: float = 350.0 #Fuerza del salto
@onready var sprite = $AnimatedSprite2D
@onready var texto_character = %TextoGordo
@onready var TimerLabel = $TimerLabel
var is_active: bool = false  #variable para controlarjugador activo
var gravity = Global.gravity
var is_jumping := false
var played_apex = false
@onready var flecha = %Flecha_UI
@onready var timer_flecha = $Flecha_UI/Timer_flecha
var estaba_activo = false

func _ready() -> void:
	texto_character.visible = false
	flecha.visible = true
	
func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO
	#SI cambio de pj esta desabilitado#
	if Input.is_action_pressed("cambiar") and Global.can_swap == false:			
		_cambiar_esta_desabilitado()

	#MOVER PERSONAJE#
	if Emociones.seguir_a_laura and not is_active:
		_seguir_a_laura()
	if is_active :
		direction = _procesar_input_movimiento()
	if Global.lauraOnTop:
		velocity.x = direction.x * speedLauraOnTop
	else:
		velocity.x = direction.x * speed     # Aplica movimiento horizontal
	velocity.y += gravity * delta    # Aplicar gravedad al personaje
	move_and_slide()
	update_animation(direction)
	_update_flechita()
	
	
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
		texto_character.visible = false
		remove_joint()
	return dir

func hacer_accion():
	pass
	
func _seguir_a_laura():
		var objetivo = get_tree().get_nodes_in_group("grupo-laura")
		var laura = objetivo[0]
		print(laura)
		var direccion_x = sign(laura.global_position.x - global_position.x)
		velocity.x = direccion_x * speed
		move_and_slide()
		
func _cambiar_esta_desabilitado():
		texto_character.text = "No se puede cambiar de personaje ahora"
		texto_character.visible = true
		TimerLabel.start()
		
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
	if Emociones.gordo_mood_normal:
		_animacion_normal(direction)
	if Emociones.gordo_mood_enojado:
		_animacion_enojado(direction)
		
		
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
#MAS ANIMACIONES DE HUMOR
##---------ANIMACIONEs-----------S##



### EMPUJAR CAJAS apretando BOTON
func empujar_caja():
	print("empujando")
	texto_character.visible = true
	texto_character.text = "Empujando"
	for body in push_area.get_overlapping_bodies():
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


#timer para texto sobre el personaje
func _on_timer_label_timeout() -> void:
	texto_character.visible = false

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
		"enojado":
			print("emocion enojada")
			Emociones.gordo_mood_normal = false
			Emociones.gordo_mood_enojado= true#ESTE
			Emociones.gordo_mood_rockeando = false
			Emociones.gordo_mood_triste= false
			Emociones.gordo_mood_bobo= false
##---------EMCIONES-----------S##

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
