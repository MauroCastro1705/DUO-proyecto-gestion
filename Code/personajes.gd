# personajes.gd - v1.1 - para Autoload Personajes
# sigue el estado global de ambos personajes. crea referencias a ambos y calcula todas sus relaciones
extends Node

### variables para las referencias a las actuales instancias del nivel de ale y bru
var ale_instance: CharAle = null
var bruno_instance: CharBruno = null

### funciones de registro. las llaman ambos personajes en el _ready
func register_ale(character_node: CharAle) -> void:
	# Check if we are accidentally overwriting a valid reference.
	if is_instance_valid(ale_instance):
		print("GlobalState: Overwriting an existing Ale reference. This may happen on rapid scene reloads but could indicate an issue.")
	
	ale_instance = character_node
	print("GlobalState: Ale instance registered.")
	
func register_bruno(character_node: CharBruno) -> void:
	if is_instance_valid(bruno_instance):
		print("GlobalState: Overwriting an existing Bruno reference.")
	
	bruno_instance = character_node
	print("GlobalState: Bruno instance registered.")


### funciones de desregistro. las llaman ambos personajes en el _exit_tree
func unregister_ale() -> void:
	ale_instance = null
	print("GlobalState: Ale instance unregistered.")

func unregister_bruno() -> void:
	bruno_instance = null
	print("GlobalState: Bruno instance unregistered.")

# --- Safety Check Function (Used by any other script) --- Any function using these references MUST check for validity first.
func hay_personajes() -> bool:
	return is_instance_valid(ale_instance) and is_instance_valid(bruno_instance)



# --- Centralized Logic Function ---

# Returns:
#	Dictionary: A dictionary containing relationship data, or null if characters are missing.
func get_ale_bruno_relationship() -> Dictionary:
	# First, ensure both characters are currently registered and valid in the scene.
	#if not is_instance_valid(ale_instance) or not is_instance_valid(bruno_instance):
		#return null # Return null to signal that the data is not available.

	# --- Calculate Data ---
	var vector_between: Vector2 = bruno_instance.global_position - ale_instance.global_position
	var distance_sq: float = vector_between.length_squared()
	var is_occluded: bool = _is_line_of_sight_blocked(ale_instance, bruno_instance)

	# --- Package and Return Data ---
	# Using a dictionary is a great way to return multiple related values.
	return {
		"vector": vector_between,
		"distance_squared": distance_sq,
		"is_occluded": is_occluded
	}

# This is the same LOS check as before, but now as a private helper
# function within the global script.
func _is_line_of_sight_blocked(source: Node2D, target: Node2D) -> bool:
	var space_state := source.get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(source.global_position, target.global_position)
	query.exclude = [source, target]
	query.collision_mask = 1 # Assumes layer 1 is for "world" geometry
	
	var result: Dictionary = space_state.intersect_ray(query)
	return not result.is_empty()





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
