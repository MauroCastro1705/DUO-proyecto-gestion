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

var modo_disparo:bool = false
##movimiento##
@export var speed: float = 180.0 #Velocidad horizontal
@export var jump_force: float = 200.0 #Fuerza del salto
var gravity = Global.gravity
@onready var texto_character = %TextoGordo
@onready var TimerLabel = $TimerLabel
var is_active: bool = false  #variable para controlarjugador activo

func _ready() -> void:
	texto_character.visible = false
	
func _process(delta: float) -> void:
	var direction = Vector2.ZERO
	#MODO DISPARO#
	if Input.is_action_pressed("cambiar") and Global.can_swap == false:			
		texto_character.text = "No se puede cambiar de personaje ahora"
		texto_character.visible = true
		TimerLabel.start()
	if Input.is_action_just_pressed("modo-disparo") and modo_disparo == false:
		modo_disparo=true
		Global.can_swap=false
		print("modo disparo true")

	elif Input.is_action_just_pressed("modo-disparo") and modo_disparo == true:
		modo_disparo=false
		line.clear_points()
		Global.can_swap=true
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
			texto_character.visible = true
			texto_character.text = "Empujando"
			for body in push_area.get_overlapping_bodies():
				if body is RigidBody2D:
					current_box = body
					create_joint_with_box(current_box)
					break
		if Input.is_action_just_released("empujar"):
			texto_character.visible = false
			remove_joint()
			
	velocity.x = direction.x * speed     # Aplica movimiento horizontal
	velocity.y += gravity * delta    # Aplicar gravedad al personaje
	move_and_slide()
	if velocity.x != 0:#flip sprite
		$CharacterSprite.flip_h = velocity.x > 0



func hacer_accion():
	pass
	

###collision con cajas####

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

#timer para texto sobre el personaje
func _on_timer_label_timeout() -> void:
	texto_character.visible = false
