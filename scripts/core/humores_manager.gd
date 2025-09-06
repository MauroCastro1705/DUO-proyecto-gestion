# humores_manager.gd - v1.0

extends Node

signal humor_ha_cambiado(tipo_personaje: GlobalEnumIndices.Personaje, nuevo_tipo_humor: GlobalEnumIndices.Humor)

var personajes_dicc: Dictionary = {}
var humor_actual: Dictionary = {}
var humor_dicc_definiciones: Dictionary = {}
var definiciones_cargadas: bool = false # NEW: A flag to track if we've loaded.

func _ready():
	pass

func _verificar_carga_de_definiciones_de_humores():
	if definiciones_cargadas:
		return
	
	print("--- HumoresManager: Cargando definiciones por primera vez... ---")
	var dir = DirAccess.open("res://data/humores")
	if not dir: 
		printerr(" -> ERROR: No se pudo abrir res://data/humores")
		return
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var resource: HumorDefinicion = load(dir.get_current_dir() + "/" + file_name)
			if resource:
				var humor_index: int = resource.humor
				humor_dicc_definiciones[humor_index] = resource
				print(" -> Cargado: '%s' para el índice de humor %d" % [file_name, humor_index])
				#print(" -> Cargado: '%s' para el índice de humor %d" % [file_name, resource.humor])
				#humor_dicc_definiciones[resource.humor] = resource
		file_name = dir.get_next()
	
	# Set the flag to true so this code doesn't run again.
	definiciones_cargadas = true


func registrar_personaje(nodo_personaje: Node, tipo: GlobalEnumIndices.Personaje):
	personajes_dicc[tipo] = nodo_personaje
	humor_actual[tipo] = GlobalEnumIndices.Humor.INACTIVO


func set_humor_personaje(tipo_personaje: GlobalEnumIndices.Personaje, nuevo_tipo_humor: GlobalEnumIndices.Humor):
	_verificar_carga_de_definiciones_de_humores()

	if not personajes_dicc.has(tipo_personaje):
		printerr("HumoresManager Error: Personaje '%s' no registrado." % GlobalEnumIndices.Personaje.find_key(tipo_personaje))
		return
	
	if not humor_dicc_definiciones.has(nuevo_tipo_humor):
		printerr("HumoresManager Error: Humor '%s' no encontrado en el diccionario de definiciones." % GlobalEnumIndices.Humor.find_key(nuevo_tipo_humor))
		return
		
	if humor_actual.has(tipo_personaje) and humor_actual[tipo_personaje] == nuevo_tipo_humor: return

	humor_actual[tipo_personaje] = nuevo_tipo_humor
	var nodo_personaje = personajes_dicc[tipo_personaje]
	var humor_def = humor_dicc_definiciones[nuevo_tipo_humor]
	
	nodo_personaje.aplicar_humor_definicion(humor_def)
	emit_signal("humor_ha_cambiado", tipo_personaje, nuevo_tipo_humor)


func get_humor_definiciones(tipo_humor: GlobalEnumIndices.Humor) -> HumorDefinicion:
	# It's safer to also ensure definitions are loaded here.
	_verificar_carga_de_definiciones_de_humores()
	return humor_dicc_definiciones.get(tipo_humor)


func get_humores_todos_personajes() -> Dictionary:
	return humor_actual.duplicate()
