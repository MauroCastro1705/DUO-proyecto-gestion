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
		if Input.is_action_pressed("empujar"):
			hacer_accion()
	velocity.x = direction.x * speed     # Aplica movimiento horizontal
	velocity.y += gravity * delta    # Aplicar gravedad al personaje
	if is_on_big_character:
		velocity.x += big_character_velocity.x
	move_and_slide()
	
	##VOLTEAR SPRITE###
	if velocity.x != 0:
		$DefaultLaura.flip_h = velocity.x < 0
		
		
func hacer_accion():
	pass
	

###collision con cajas####
