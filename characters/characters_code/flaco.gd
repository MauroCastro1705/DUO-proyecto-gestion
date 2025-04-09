extends CharacterBody2D
# Velocidad del personaje (pixeles por segundo)
@export var speed: float = 200.0        # Velocidad horizontal
@export var jump_force: float = 400.0   # Fuerza del salto
var gravity = Global.gravity
var is_active: bool = false  #variable para controlar si se recibe input

func _ready() -> void:
	pass

func _process(delta: float) -> void:
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
	move_and_slide()
	##VOLTEAR SPRITE###
	if velocity.x != 0:
		$CharacterSprite.flip_h = velocity.x > 0
		
		
func hacer_accion():
	pass
	

###collision con cajas####
