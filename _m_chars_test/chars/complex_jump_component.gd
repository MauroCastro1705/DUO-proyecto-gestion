# player_controller.gd
extends CharacterBody2D

@export var initial_jump_force: float = 400.0 # Exported as positive value
@export var coyote_time: float = 0.1
@export var normal_gravity: float = 1200.0
@export var apex_gravity_scale: float = 0.4 # Reduced gravity at apex
@export var apex_threshold: float = 50.0 # Velocity considered near apex
@export var fall_gravity_scale: float = 1.8 # Increased gravity after apex
@onready var input_component = $"../InputComponent"

var coyote_timer: float = 0.0
var can_coyote_jump: bool = false
var is_buffered_jump: bool = false
var is_jumping: bool = false

func _physics_process(delta):
	var current_gravity = normal_gravity

	if !is_on_floor():
		if velocity.y > apex_threshold:
			current_gravity *= fall_gravity_scale
		elif velocity.y < apex_threshold and velocity.y > -apex_threshold and is_jumping:
			current_gravity *= apex_gravity_scale

	velocity.y += current_gravity * delta

	# Coyote Time
	if is_on_floor():
		coyote_timer = 0.0
		can_coyote_jump = true
		is_jumping = false # Reset jumping state on landing
	else:
		coyote_timer += delta
		if coyote_timer > coyote_time:
			can_coyote_jump = false

	# Jump Buffering
	if input_component.is_action_just_pressed("salto") and !is_on_floor():
		is_buffered_jump = true

	# Perform Jump
	if (is_on_floor() or can_coyote_jump) and input_component.is_action_just_pressed("salto"):
		velocity.y = -initial_jump_force # Invert to apply upward force
		can_coyote_jump = false
		is_jumping = true
		is_buffered_jump = false # Consume the buffered jump
	elif is_on_floor() and is_buffered_jump:
		velocity.y = -initial_jump_force # Invert to apply upward force
		is_buffered_jump = false
		is_jumping = true

	move_and_slide()

func set_initial_jump_force(new_force: float):
	initial_jump_force = new_force
	print("Initial jump force updated to:", initial_jump_force)

func set_coyote_time(new_time: float):
	coyote_time = new_time
	print("Coyote time updated to:", coyote_time)

func set_normal_gravity(new_gravity: float):
	normal_gravity = new_gravity
	print("Normal gravity updated to:", normal_gravity)

func set_apex_gravity_scale(new_scale: float):
	apex_gravity_scale = new_scale
	print("Apex gravity scale updated to:", apex_gravity_scale)

func set_fall_gravity_scale(new_scale: float):
	fall_gravity_scale = new_scale
	print("Fall gravity scale updated to:", fall_gravity_scale)
