# complex_jump_varios.gd (Version 4.6 - Advanced Jump)
extends CharacterBody2D
#class_name CharacterPunkBase

@export_group("Salto Complejo")
#@export var speed: float = 200.0
##########-------------------------------------------------------------------------------Change START---------------------##########
# Renamed for clarity, keep the value you liked (e.g., 450.0)
@export var initial_jump_velocity: float = 450.0
@export var friction: float = 4000.0 # Used for grounded deceleration

#@export_group("Settings Salto Avanzado")
# New jump settings from example
@export var coyote_time: float = 0.1 # Time in seconds to allow jump after leaving ledge
@export var jump_buffer_time: float = 0.1 # Time in seconds to buffer jump before landing
@export var apex_gravity_scale: float = 0.5 # Gravity multiplier near jump peak (must be < 1.0)
@export var apex_threshold: float = 50.0 # Vertical velocity range (+/-) considered near apex
@export var fall_gravity_scale: float = 2.0 # Gravity multiplier when falling fast (replaces fall_gravity_multiplier)
# Removed fall_gravity_multiplier export
##########-------------------------------------------------------------------------------Change ENDT----------------------##########

#@export_group("Node References")
#@export var sprite_node_path: NodePath = ^""
#@export var anim_sprite_node_path: NodePath = ^""

#@onready var sprite: Sprite2D = get_node_or_null(sprite_node_path) as Sprite2D
#@onready var anim_sprite: AnimatedSprite2D = get_node_or_null(anim_sprite_node_path) as AnimatedSprite2D

# Renamed base_gravity for clarity, value from project settings
var normal_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
#var is_active: bool = false

##########-------------------------------------------------------------------------------Change START---------------------##########
# New state variables for advanced jump
var coyote_timer: float = 0.0 # Tracks time since leaving ground
var can_coyote_jump: bool = false # Flag if coyote jump is allowed
var buffer_timer: float = 0.0 # Tracks time since jump was pressed mid-air
var is_buffered_jump: bool = false # Flag if a jump press is buffered
var is_jumping: bool = false # Flag to track if currently in ascending jump phase
##########-------------------------------------------------------------------------------Change ENDT----------------------##########


func _ready() -> void:
	if not is_instance_valid(sprite):
		printerr("Sprite node is not valid in _ready for ", self.name)
	is_active = false

func _physics_process(delta: float) -> void:

	##########-------------------------------------------------------------------------------Change START---------------------##########
	# Calculate effective gravity based on state (apex/falling)
	var effective_gravity = normal_gravity
	# Check if falling significantly OR if past apex after initiating jump
	if not is_on_floor():
		if velocity.y > apex_threshold:
			effective_gravity *= fall_gravity_scale
			is_jumping = false # No longer considered in ascending jump phase
		# Check if near apex (small positive or negative velocity) AFTER initiating a jump
		elif is_jumping and abs(velocity.y) < apex_threshold :
			 effective_gravity *= apex_gravity_scale
		# If moving upwards strongly, use normal gravity (implicit else)

	# Apply gravity force
	velocity.y += effective_gravity * delta

	# Coyote Time Logic
	if is_on_floor():
		coyote_timer = 0.0
		can_coyote_jump = true
		is_jumping = false # Reset jump state on ground
	else:
		coyote_timer += delta
		if coyote_timer > coyote_time:
			can_coyote_jump = false

	# Jump Buffering Logic
	# Check for jump press input THIS frame (only if active)
	var jump_input_pressed_this_frame = false
	if is_active and Input.is_action_just_pressed("salto"):
		jump_input_pressed_this_frame = true
		buffer_timer = 0.0 # Start buffer timer on press
		is_buffered_jump = true # Set buffer flag

	# Update buffer timer if jump is buffered but not yet executed
	if is_buffered_jump:
		buffer_timer += delta
		if buffer_timer > jump_buffer_time:
			is_buffered_jump = false # Buffer expires

	##########-------------------------------------------------------------------------------Change ENDT----------------------##########


	if is_active:
		# --- Movement Input ---
		var direction: float = _get_movement_input_direction()
		velocity.x = direction * speed

		##########-------------------------------------------------------------------------------Change START---------------------##########
		# --- Jump Execution Logic ---
		# Check conditions for executing a jump (normal, coyote, or buffered)
		var should_execute_jump = false
		# Condition 1: Jump pressed now AND (on floor OR can coyote jump)
		if jump_input_pressed_this_frame and (is_on_floor() or can_coyote_jump):
			should_execute_jump = true
		# Condition 2: Jump was buffered AND now on floor
		elif is_buffered_jump and is_on_floor():
			should_execute_jump = true

		# Execute the jump if conditions met
		if should_execute_jump:
			velocity.y = -initial_jump_velocity # Apply upward velocity
			is_jumping = true # Mark that we are in the jump state
			can_coyote_jump = false # Consume coyote jump window
			is_buffered_jump = false # Consume buffered jump
			buffer_timer = jump_buffer_time + 1.0 # Ensure buffer expires immediately
			print("JUMP!") # Debug message
		##########-------------------------------------------------------------------------------Change ENDT----------------------##########

	else: # If inactive
		# Conditional Deceleration
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, friction * delta)


	# Apply final movement
	move_and_slide()

	# Update sprite facing direction (no changes needed here)
	_update_sprite_facing_direction()


# --- Helper methods ---
func _get_movement_input_direction() -> float:
	# Using user's action names
	return Input.get_axis("izquierda", "derecha")

##########-------------------------------------------------------------------------------Change START---------------------##########
# REMOVED the simple _should_jump() function as logic is now inline
# func _should_jump() -> bool:
#    return Input.is_action_just_pressed("salto") and is_on_floor()
##########-------------------------------------------------------------------------------Change ENDT----------------------##########

func _update_sprite_facing_direction() -> void:
	# (Logic remains the same as Version 4.4 - Correct for left-facing sprites)
	if not is_instance_valid(sprite): return
	if velocity.x != 0:
		var base_scale_x_magnitude: float = abs(sprite.scale.x)
		var target_direction: float = sign(velocity.x)
		# Multiply by target direction and -1 because base sprite faces LEFT
		var target_scale_x: float = base_scale_x_magnitude * target_direction * -1.0
		if not is_equal_approx(sprite.scale.x, target_scale_x):
			sprite.scale.x = target_scale_x

# --- Placeholder ---
func perform_special_action() -> void: pass

# --- Switching Functions ---
# (set_active, _on_deactivated, _on_activated remain the same)
func set_active(active: bool) -> void:
	if is_active == active: return
	is_active = active
	print(self.name, " active: ", is_active)
	if not is_active:
		 _on_deactivated()
	else:
		_on_activated()

func _on_deactivated() -> void: pass
func _on_activated() -> void: pass
