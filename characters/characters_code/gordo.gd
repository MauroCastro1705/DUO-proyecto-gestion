extends CharacterBody2D

###para empujar cajas####
@onready var push_area = $empujarCajas
var joint: PinJoint2D = null
var current_box: RigidBody2D = null
@onready var empujando = $Label_empujando
##movimiento##
@export var speed: float = 180.0        # Velocidad horizontal
@export var jump_force: float = 200.0   # Fuerza del salto
var gravity = Global.gravity

var is_active: bool = false  #variable para controlar si se recibe input

func _ready() -> void:
	empujando.visible = false
	
func _process(delta: float) -> void:
	var direction = Vector2.ZERO
	if is_active:
		if Input.is_action_pressed("derecha"):
			direction.x += 1
		if Input.is_action_pressed("izquierda"):
			direction.x -= 1
		if Input.is_action_just_pressed("salto") and is_on_floor():
			velocity.y = -jump_force  # La fuerza del salto va hacia arriba, por eso es negativa
		###LOGICA EMPUJAR CAJAS###
		if Input.is_action_just_pressed("empujar") and joint == null:
			print("empujando")
			empujando.visible = true
			for body in push_area.get_overlapping_bodies():
				if body is RigidBody2D:
					current_box = body
					create_joint_with_box(current_box)
					break
		if Input.is_action_just_released("empujar"):
			empujando.visible = false
			remove_joint()
			
			
	velocity.x = direction.x * speed     # Aplica movimiento horizontal
	velocity.y += gravity * delta    # Aplicar gravedad al personaje
	move_and_slide()
	
func hacer_accion():
	pass
	

###collision con cajas####
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("arrastrables"):
		body.collision_layer = 1
		body.collision_mask = 1

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("arrastrables"):
		body.collision_layer = 2
		body.collision_mask = 2

### EMPUJAR CAJAS CON BOTON
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
