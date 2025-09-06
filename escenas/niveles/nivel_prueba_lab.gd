# nivel_prueba_lab.gd
extends Node2D

# The _ready() function is automatically called when this node enters the scene.
# We make the function itself asynchronous by using the 'await' keyword inside it.
func _ready():
	# This line pauses the function. The code below it will not run immediately.
	# The engine will continue to load other nodes and run their _ready() functions.
	await get_tree().process_frame
	
	# This line will only execute AFTER the first frame has been fully processed.
	# By now, we are sure that our character has registered itself with the managers.
	# It is now safe to force the initial game state.
	print("Nivel listo, forzando estado inicial.")
	EstadosManager.forzar_estado(GlobalEnumIndices.Estado.E_INICIO)
