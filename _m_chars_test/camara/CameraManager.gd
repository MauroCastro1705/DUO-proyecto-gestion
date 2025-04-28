# CameraManager.gd
extends Camera2D
class_name CameraManager

@export_group("Dependencies")
@export var character_manager_path: NodePath

@export_group("Following")
@export var follow_smoothness: float = 5.0 # How quickly the camera catches up to the target (higher = faster)
# Optional: Define limits for the camera's position if needed
# Use the Camera2D node's built-in Limit properties in the Inspector instead

@export_group("Zooming")
@export var playing_zoom: Vector2 = Vector2(1.0, 1.0) # The default zoom level during gameplay
@export var overview_zoom: Vector2 = Vector2(2.0, 2.0) # The zoom level for the overview mode
@export var zoom_smoothness: float = 4.0 # How quickly the camera interpolates to the target zoom (higher = faster)

# --- Internal Variables ---
@onready var _character_manager: Node = get_node_or_null(character_manager_path) # Reference to the CharacterManager node
var _target_node: Node2D = null # The node the camera is currently trying to follow
var _target_zoom: Vector2 = Vector2.ONE # The desired zoom level based on current mode

#var playing_zoom_vector: Vector2 = Vector2(playing_zoom, playing_zoom)
#var overview_zoom_vector: Vector2 = Vector2(overview_zoom, overview_zoom)


func _ready() -> void:
	
		# Validate CharacterManager reference
	if not is_instance_valid(_character_manager) or not _character_manager.has_method("get_active_character"):
		printerr("PlayerCamera: CharacterManager node not found, invalid, or doesn't have get_active_character() method at path:", character_manager_path)
		set_process(false) # Disable processing if manager is missing/invalid
		return

	# Set initial zoom state (always starts at playing zoom)
	_target_zoom = playing_zoom
	self.zoom = _target_zoom # Start at the correct zoom instantly

	# Get the initial target and snap camera position instantly
	var initial_target = _character_manager.get_active_character()
	if initial_target is Node2D:
		_target_node = initial_target
		self.global_position = _target_node.global_position
	else:
		printerr("PlayerCamera: No valid initial target (Node2D) found from CharacterManager.")


func _process(delta: float) -> void:
	# 1. Determine the intended target (the currently active character)
	if is_instance_valid(_character_manager): # si linkee el character manager
		var current_target = _character_manager.get_active_character()
		if current_target is Node2D: # si lo linkeado es un nodo
			_target_node = current_target



	# 2. Determine the target zoom level based on *current* input state
	#    Define an action like "zoom_out" in Project Settings -> Input Map
	if Input.is_action_pressed("zoom_out"):
		_target_zoom = overview_zoom
	else:
		_target_zoom = playing_zoom

	# 3. INTERPOLACIONES accion
	# Smoothly interpolate the camera's actual zoom towards the target zoom
	self.zoom = self.zoom.lerp(_target_zoom, 1.0 - exp(-zoom_smoothness * delta))

	# 4. Smoothly interpolate the camera's position towards the target node's position
	if is_instance_valid(_target_node):
		var target_position: Vector2 = _target_node.global_position
		var previous_camera_pos = self.global_position
		self.global_position = previous_camera_pos.lerp(target_position, 1.0 - exp(-follow_smoothness * delta))
