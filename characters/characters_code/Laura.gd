extends CharacterBody2D

@export var speed: float = 200.0        # Velocidad horizontal
@export var jump_force: float = 850.0   # Fuerza del salto
@export var max_fall_speed: float = 1000.0
@export var fast_fall_multiplier: float = 2.0
@onready var sprite = $LauraSprites
@export var raycast_down: RayCast2D  # arrastrá tu RayCast2D en el editor aquí
var gravity = Global.gravity
var is_active: bool = false  #variable para controlar si se recibe input
#plataforma
var is_on_big_character = false
var big_character_velocity := Vector2.ZERO

func _ready() -> void:
	Global.lauraOnTop = false

func _physics_process(delta: float) -> void:
	if raycast_down.is_colliding():		# Detectar si estamos sobre el personaje grande
		var collider = raycast_down.get_collider()
		_colision_sobre_ramiro(collider)
	var direction = Vector2.ZERO
	if is_active:
		direction = _procesar_input_movimiento()
		_aplicar_gravedad(delta)

	_handle_velocity(direction, delta)
	update_animation(direction)
	move_and_slide()

func _procesar_input_movimiento() -> Vector2:
	var dir = Vector2.ZERO
	if Input.is_action_pressed("derecha"):
		dir.x += 1
	if Input.is_action_pressed("izquierda"):
		dir.x -= 1
	if Input.is_action_just_pressed("salto") and is_on_floor():
		velocity.y = -jump_force
	if Input.is_action_pressed("empujar"):
		hacer_accion()
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

func hacer_accion():
	Emociones.seguir_a_laura = true

##ANIMACIONES##
func update_animation(direction: Vector2):
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
