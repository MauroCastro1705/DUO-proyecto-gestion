extends CharacterBody2D

###para empujar cajas####
@onready var push_area = $empujarCajas
var joint: PinJoint2D = null
var current_box: RigidBody2D = null

#raycast bobo
@onready var raycast_detecta_arista_der: RayCast2D = $RayCast2D_arista_der # para filo de aristas
@onready var raycast_detecta_arista_izq: RayCast2D = $RayCast2D_arista_izq
@onready var plat_hombros = $"plataforma-hombros/colision_hombros"

#emociones
@onready var zona_cauta = $zona_cauta

##movimiento##
@export var speed: float = 130.0 #Velocidad horizontal
@export var speedLauraOnTop:float = 90.0 #velocidad con laura encima
@export var jump_force: float = 350.0 #Fuerza del salto
@export var dist_chico_enojado: float = 200.0 #distancia a que sigue a chico cuando Bobo
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
	zona_cauta.disable_mode = true

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
	if Global.lauraOnTop:
		velocity.x = direction.x * speedLauraOnTop
	else:
		velocity.x = direction.x * speed     # Aplica movimiento horizontal
	velocity.y += gravity * delta    # Aplicar gravedad al personaje
	move_and_slide()
	update_animation(direction)
	_update_flechita()
	_ale_zona_cauta()
	
	
	
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
		plat_hombros.disabled = true
		var objetivo = get_tree().get_nodes_in_group("grupo-laura")
		var laura = objetivo[0]
		var direccion_x = sign(laura.global_position.x - global_position.x)
		var dist_a_chico: float = abs(laura.global_position.x - self.global_position.x)
		raycast_detecta_arista_der.force_raycast_update()
		raycast_detecta_arista_izq.force_raycast_update()
		var hay_arista_a_der: bool = not raycast_detecta_arista_der.is_colliding()
		var hay_arista_a_izq: bool = not raycast_detecta_arista_izq.is_colliding()
		
		#print("Bruno arista a derecha:",hay_arista_a_der)
		#print("Bruno arista a izquierda:",hay_arista_a_izq)
		
		if dist_a_chico > abs(dist_chico_enojado): #se le acerca hasta dist_chico_enojado
			if (hay_arista_a_der and direccion_x==1) or (hay_arista_a_izq and direccion_x==-1):
				velocity.x = 0
			else:
				velocity.x = direccion_x * speed
		move_and_slide()
		texto_character.text = "Estoy bobo y sigo a Ale"
		texto_character.visible = true
		var direction = Vector2(sign(velocity.x), 0)
		update_animation(direction)
		
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
	elif Emociones.gordo_mood_normal:
		_animacion_normal(direction)
		texto_character.text = "Estoy normal"
		texto_character.visible = true
	elif Emociones.gordo_mood_enojado:
		_animacion_enojado(direction)
		texto_character.text = "Estoy enojado"
		texto_character.visible = true
	elif Emociones.gordo_mood_bobo:
		_animacion_embobado(direction)
		
		
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
func _animacion_embobado(direction : Vector2):
	if direction.x != 0:
		sprite.play("bobo_walk")
		sprite.flip_h = direction.x > 0
	else:
		sprite.play("bobo_walk")

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
			texto_character.visible = false #desactivamos cartel
			Emociones.seguir_a_laura = false#desactiva el seguimiento a alejandra
			Global.can_swap = true #revisar
			plat_hombros.disabled = false


		"enojado":
			print("emocion enojado")
			Emociones.gordo_mood_normal = false
			Emociones.gordo_mood_enojado= true#ESTE
			Emociones.gordo_mood_rockeando = false
			Emociones.gordo_mood_triste= false
			Emociones.gordo_mood_bobo= false
			Emociones.seguir_a_laura = false#desactiva el seguimiento a alejandra
			plat_hombros.disabled = false


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
