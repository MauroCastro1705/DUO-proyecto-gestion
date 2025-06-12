# character_maanager.gd v4.3
# Attach it to a empty Node named CharacterManager in your main scene
extends Node

@export_group("Asigno Personajes")
@export var character_chico_path: NodePath
@export var character_grande_path: NodePath

var characters: Array[CharacterPunkBase] = [] # Crea array para recorrer chars switcheables
var active_character: CharacterPunkBase = null

func _ready() -> void:
	# Link characters (ensure paths are set in Inspector!)
	var chico = get_node_or_null(character_chico_path) as CharacterPunkChico
	var grande = get_node_or_null(character_grande_path) as CharacterPunkGrande
	
	# Agrego chars al array, el primero sera el activo por default, en este caso Chico
	if is_instance_valid(chico): characters.append(chico) # Si linkee a Chico lo agrega al array de switcheables
	else: printerr("CM: Chico not found:", character_chico_path)
	if is_instance_valid(grande): characters.append(grande) # Si linkee a Grande lo agrega al array de switcheables
	else: printerr("CM: Grande not found:", character_grande_path)
	
	# Control de errores si no hay chars asignados
	if characters.is_empty():
		printerr("CM: No characters valid assigned. Disabling input.")
		set_process(false)
		return

	# Set initial active character . solo se ejecutaria si characters no esta vacio
	active_character = characters[0]
	
	await get_tree().physics_frame # Para que se carguen ambos personajes antes de activarlos
	
	_update_character_active_states() # Recorre array y setea activo al igual a active_character, desactiva los otros

#FUNCION ANTERIOR > FALLABA A ALTISIMOS FPS
#func _unhandled_input(event: InputEvent) -> void: 
	#if event.is_action_pressed("cambio_manager"): # Use your switch action name
		#_switch_to_next_character()
		#get_viewport().set_input_as_handled() # Consume el input

func _process(_delta: float) -> void: # Or _physics_process
	# Check ONCE per frame if the action was JUST pressed down
	if Input.is_action_just_pressed("cambio_manager"):
		# Optional: Check if switching is allowed (e.g., Global.can_swap)
		# if Global.can_swap:
		_switch_to_next_character()
		# Note: No need for set_input_as_handled() here,
		# as is_action_just_pressed only returns true for one frame per press.

func _switch_to_next_character() -> void: #switchea en la logica del manager
	if characters.size() < 2: return	# No cambia de char si no hay al menos 2
	var current_index = characters.find(active_character)
	if current_index == -1: current_index = 0 # Fallback. Raro, no habria forma que diera -1 despues de varios controles
	var next_index = (current_index + 1) % characters.size() # itera al proximo elemento y vuelve a 0 al final
	active_character = characters[next_index]
	print("CM: Switched to:", active_character.name)
	_update_character_active_states()

func _update_character_active_states() -> void: # implementa el switcheo en los chars
	if not is_instance_valid(active_character): return
	
	# reccorro todos los chars
	for character in characters:
		if is_instance_valid(character):
			character.set_active(character == active_character) # Pasa el boolean resultado de comparar el personaje con el que deberia estar activo

func get_active_character() -> CharacterPunkBase:
	return active_character
