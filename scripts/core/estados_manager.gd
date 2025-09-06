# estados_manager.gd - v1.0

extends Node

signal estado_ha_cambiado(nuevo_estado: GlobalEnumIndices.Estado, viejo_estado: GlobalEnumIndices.Estado)

var estado_dicc_definiciones: Dictionary = {}
var estado_actual: EstadoDefinicion = null

func _ready():
	_load_todas_definiciones_de_estado()
	HumoresManager.humor_ha_cambiado.connect(_cambiar_estado_por_humores)

func _load_todas_definiciones_de_estado():
	var dir = DirAccess.open("res://data/estados")
	if not dir: return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var resource: EstadoDefinicion = load(dir.get_current_dir() + "/" + file_name)
			if resource: estado_dicc_definiciones[resource.estado] = resource
		file_name = dir.get_next()

func forzar_estado(nuevo_estado_tipo: GlobalEnumIndices.Estado):
	print("--- DEBUG: EstadosManager.forzar_estado() llamado con: %s ---" % GlobalEnumIndices.Estado.find_key(nuevo_estado_tipo))
	
	if not estado_dicc_definiciones.has(nuevo_estado_tipo):
		printerr(" -> ERROR: Definición de estado no encontrada.")
		return
	
	var nuevo_estado = estado_dicc_definiciones[nuevo_estado_tipo]
	if nuevo_estado == estado_actual: return
	var viejo_estado_tipo = GlobalEnumIndices.Estado.NONE
	if estado_actual: viejo_estado_tipo = estado_actual.estado
	estado_actual = nuevo_estado
	_aplicar_reglas_de_estado()
	
	# si el estado debe forzar personaje activo, lo switcheo a la fuerza
	if estado_actual.personaje_activo_forzado != GlobalEnumIndices.Personaje.NONE:
		var personaje_a_activar = estado_actual.personaje_activo_forzado
		var personaje_nodo = PersonajesSwitchManager.get_personaje_por_tipo(personaje_a_activar)
		if personaje_nodo and not personaje_nodo._es_personaje_activo:
			PersonajesSwitchManager.forzar_personaje_activo(personaje_a_activar)
			print("FORZADO cambio personaje ACTIVO a: ", personaje_a_activar)
	emit_signal("estado_ha_cambiado", nuevo_estado.estado, viejo_estado_tipo)

func mecanica_global_habilitada(nombre_mecanica: String) -> bool:
	if not estado_actual: return true
	return not nombre_mecanica in estado_actual.mecanicas_globales_deshabilitadas

func _aplicar_reglas_de_estado():
	if not estado_actual: return
	
	print("--- DEBUG: EstadosManager._aplicar_reglas_de_estado() ejecutándose. ---")
	
	for tipo_personaje in estado_actual.humores_forzados:
		var tipo_humor = estado_actual.humores_forzados[tipo_personaje]
		
		print(" -> Forzando humor '%s' en personaje '%s'" % [GlobalEnumIndices.Humor.find_key(tipo_humor), GlobalEnumIndices.Personaje.find_key(tipo_personaje)])
		
		HumoresManager.set_humor_personaje(tipo_personaje, tipo_humor)




func _cambiar_estado_por_humores(_tipo_personaje, _nuevo_tipo_humor):
	var humores_actuales = HumoresManager.get_humores_todos_personajes()
	for estado_tipo in estado_dicc_definiciones:
		var estado_def: EstadoDefinicion = estado_dicc_definiciones[estado_tipo]
		if estado_def.humores_gatillo.is_empty(): continue
		
		var combinacion_coincide = true
		for char_tipo_necesario in estado_def.humores_gatillo:
			var humor_necesario = estado_def.humores_gatillo[char_tipo_necesario]
			if not humores_actuales.has(char_tipo_necesario) or humores_actuales[char_tipo_necesario] != humor_necesario:
				combinacion_coincide = false
				break
		
		if combinacion_coincide:
			if not estado_actual or estado_actual.estado != estado_def.estado:
				forzar_estado(estado_def.estado)
			return


func restriccion_movimiento_actual() -> GlobalEnumIndices.RestriccionMovimiento:
	if estado_actual and estado_actual.restriccion_movimiento != GlobalEnumIndices.RestriccionMovimiento.MOVIMIENTO_LIBRE:
		return estado_actual.restriccion_movimiento
	# Optionally, check humor restriction here as well
	return GlobalEnumIndices.RestriccionMovimiento.MOVIMIENTO_LIBRE


func aplicar_restriccion_movimiento(personaje, otro_personaje, input_dir_x):
	if estado_actual and estado_actual.script_de_restriccion_movimiento:
		var script_instance = estado_actual.script_de_restriccion_movimiento.new()
		return script_instance.aplicar_restriccion_movimiento(personaje, otro_personaje, input_dir_x)
	return true  # Default: mov libre


func restriccion_distancia_a_grande_activa() -> bool:
	if estado_actual and estado_actual.limite_distancia_a_grande:
		return true
	return false
