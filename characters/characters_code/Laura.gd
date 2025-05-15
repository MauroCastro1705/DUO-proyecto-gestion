extends CharacterBody2D

# Velocidad del personaje (pixeles por segundo)
@export var speed: float = 200.0        # Velocidad horizontal
@export var jump_force: float = 400.0   # Fuerza del salto
var gravity = Global.gravity
var is_active: bool = false  #variable para controlar si se recibe input
#plataforma
@export var raycast_down: RayCast2D  # arrastrá tu RayCast2D en el editor aquí
var is_on_big_character = false
var big_character_velocity := Vector2.ZERO
@export var max_fall_speed: float = 1000.0
@export var fast_fall_multiplier: float = 2.0
@onready var sprite = $LauraSprites



func _ready() -> void:
	Global.lauraOnTop = false

func _process(delta: float) -> void:
		# Detectar si estamos sobre el personaje grande
	if raycast_down.is_colliding():
		var collider = raycast_down.get_collider()
		if collider.name == "plataforma-hombros":
			is_on_big_character = true
			big_character_velocity = collider.velocity
			Global.lauraOnTop = true
		else:
			is_on_big_character = false
			Global.lauraOnTop = false
			big_character_velocity = Vector2.ZERO
	else:
		is_on_big_character = false
		Global.lauraOnTop = false
		big_character_velocity = Vector2.ZERO
		
	var direction = Vector2.ZERO
	if is_active:
		if Input.is_action_pressed("derecha"):
			direction.x += 1
		if Input.is_action_pressed("izquierda"):
			direction.x -= 1
		if Input.is_action_just_pressed("salto") and is_on_floor():
			velocity.y = -jump_force  # La fuerza del salto va hacia arriba, por eso es negativa
		else:
		# Aplicar gravedad
			if velocity.y > 0:  # Está cayendo
				velocity.y += gravity * fast_fall_multiplier * delta
			else:
				velocity.y += gravity * delta
			
		if Input.is_action_pressed("empujar"):
			hacer_accion()
			
	velocity.x = direction.x * speed     # Aplica movimiento horizontal
	velocity.y += gravity * delta    # Aplicar gravedad al personaje
	if is_on_big_character:
		velocity.x += big_character_velocity.x
	move_and_slide()
	update_animation(direction)
	

func hacer_accion():
	pass
	
func update_animation(direction: Vector2):
	if Emociones.laura_mood_enojado:
		if direction.x != 0:
			sprite.play("walk_enojado")
			sprite.flip_h = direction.x > 0
		else:
			sprite.play("idle")
	else:
		if direction.x != 0:
			sprite.play("walk")
			sprite.flip_h = direction.x > 0
		else:
			sprite.play("idle")


#·····VARIABLES EN GLOBAL.gd···
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
