# character_punk_base.gd v4.4
extends CharacterBody2D
class_name CharacterPunkBase

@export_group("Settings Movimiento")
@export var speed: float = 200.0
@export var jump_velocity: float = 450.0
@export var friction: float = 4000.0 # Used for grounded deceleration
@export var fall_gravity_multiplier: float = 2.0 # Multiplier for gravity when falling (e.g., 1.5, 2.0)

@export_group("Node References")
@export var sprite_node_path: NodePath = ^""

@onready var sprite: Sprite2D = get_node_or_null(sprite_node_path) as Sprite2D

var base_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_active: bool = false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not is_instance_valid(sprite):
		printerr("Sprite node is not valid in _ready for ", self.name)
	
	is_active = false # Start inactive



func _physics_process(delta: float) -> void:
	 # Calculate effective gravity for this frame
	var effective_gravity = base_gravity
	
	# Apply higher gravity if falling (and not on floor already)
	if velocity.y > 0 and not is_on_floor():
		effective_gravity = base_gravity * fall_gravity_multiplier
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += effective_gravity * delta
	
	if is_active:
		# Basic Horizontal Movement (can be overridden or extended)
		var direction: float = _get_movement_input_direction()
		velocity.x = direction * speed
		
		# Basic Jump (can be overridden or extended)
		if _should_jump():
			velocity.y = -jump_velocity
		
		#Otras funciones de cuando esta activo
	else:
		# Only apply friction to slow down if grounded
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, friction * delta)
		# If not is_on_floor(), velocity.x retains its value (momentum preserved)
	
	# Apply movement
	move_and_slide()
	
	# Update sprite facing direction
	_update_sprite_facing_direction()
	
	
# --- Helper methods


# Separated input reading for potential overrides
func _get_movement_input_direction() -> float:
	# Default implementation - can be overridden if a character has unique movement input
	return Input.get_axis("izquierda", "derecha") # Use generic action names


# Separated jump condition check
func _should_jump() -> bool:
	# Default implementation - can be overridden
	return Input.is_action_just_pressed("salto") and is_on_floor() # Use generic action name


func _update_sprite_facing_direction() -> void:
	if sprite and velocity.x != 0:
		var base_scale_x_magnitude: float = abs(sprite.scale.x) # lee X scale en editor
		var target_direction: float = sign(velocity.x) # Direccion sign() returns -1.0, 0.0, or 1.0
		var target_scale_x: float = base_scale_x_magnitude * target_direction * -1 # 3. Calculate the new target scale.x value. Multiply by target direction and -1 because base sprite faces LEFT
		
		if not is_equal_approx(sprite.scale.x, target_scale_x): # 4. Apply the new scale.x only if it actually needs to change
			sprite.scale.x = target_scale_x
	
	# else: # Optional: If velocity.x is 0, you might want to preserve the last scale
		# pass # Keep current scale.x if stationary


# --- Placeholder for actions (can be implemented/overridden by children) ---
func perform_special_action() -> void:
	# Base implementation does nothing, or provides a default behavior
	pass


# FUNCIONES DE SWITCHEO
# Public method for the CharacterManager
func set_active(active: bool) -> void:
	if is_active == active: return # Avoid redundant calls

	is_active = active
	print(self.name, " active: ", is_active) # Debug message

	if not is_active:
		_on_deactivated()
	else:
		_on_activated()

# Protected hooks for subclasses to override
func _on_deactivated() -> void:
	# Base class can leave this empty or reset common things
	pass

func _on_activated() -> void:
	# Base class can leave this empty
	pass
