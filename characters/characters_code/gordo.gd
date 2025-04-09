extends CharacterBody2D
###LANZAR COMPAÑERO##
@export var projectile_scene: PackedScene
@export var launch_power := 800.0  # fuerza de la parabola
@onready var line := %Trayectoria
var aim_dir := Vector2.LEFT  # Dirección inicial (puede ser cualquier)
var angle_speed := 2.0  # Velocidad de rotación de la dirección
###para empujar cajas####
@onready var push_area = $empujarCajas
var joint: PinJoint2D = null
var current_box: RigidBody2D = null
@onready var empujando = $Label_empujando
var modo_disparo:bool = false
##movimiento##
@export var speed: float = 180.0 #Velocidad horizontal
@export var jump_force: float = 300.0 #Fuerza del salto
var gravity = Global.gravity

var is_active: bool = false  #variable para controlarjugador activo

func _ready() -> void:
	empujando.visible = false
	
func _process(delta: float) -> void:
	var direction = Vector2.ZERO
	#MODO DISPARO#
	if Input.is_action_just_pressed("modo-disparo") and modo_disparo == false:
		modo_disparo=true
		print("modo disparo true")
	elif Input.is_action_just_pressed("modo-disparo") and modo_disparo == true:
		modo_disparo=false
		line.clear_points()
		print("modo disparo false")
	if modo_disparo == true:
		if Input.is_action_pressed("abajo"):
			aim_dir = aim_dir.rotated(-angle_speed * delta)
		if Input.is_action_pressed("arriba"):
			aim_dir = aim_dir.rotated(angle_speed * delta)
		draw_trajectory()
		if Input.is_action_just_pressed("disparar"):  # ctrl
			launch_projectile()	
			
	#MOVER PERSONAJE#
	if is_active and modo_disparo==false:
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
	if velocity.x != 0:#flip sprite
		$CharacterSprite.flip_h = velocity.x > 0



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

### EMPUJAR CAJAS apretando BOTON
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

###DISPARAR
func launch_projectile():
	var projectile = projectile_scene.instantiate()
	projectile.global_position = $Marker2D.global_position + aim_dir.normalized() * 8.0
	get_tree().current_scene.add_child(projectile)
	projectile.linear_velocity = aim_dir.normalized() * launch_power

func draw_trajectory():
	line.clear_points()
	var points = []
	var pos = Vector2.ZERO
	var velocitys = aim_dir.normalized() * launch_power
	var timestep = 0.1
	for i in range(30):
		var t = i * timestep
		var point = pos + velocitys * t + Vector2(0, gravity) * t * t * 0.5
		points.append(point)		
		line.points = points
