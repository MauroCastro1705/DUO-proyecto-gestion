class_name RestriccionMovimientoDistanciaEntrePersonajes
extends RefCounted

func aplicar_restriccion_movimiento(personaje: Node2D, otro_personaje: Node2D, input_dir_x: float) -> bool:
	if personaje.has_method("puede_moverse_hacia_otro_personaje"):
		var distancia_seguridad = personaje.distancia_seguridad_chico_cauto
		var resultado = personaje.puede_moverse_hacia_otro_personaje(otro_personaje, input_dir_x, distancia_seguridad)
		var dist_a_otro = abs(otro_personaje.global_position.x - personaje.global_position.x)
		var en_linea_de_vista = personaje.tiene_linea_de_vista_a_objetivo(otro_personaje)
		_dibujar_linea_debug(personaje, otro_personaje, dist_a_otro, distancia_seguridad, en_linea_de_vista)
		
		### DEBUG ###
		#print("--- DEBUG RESTRICCION ---")
		#print("Personaje: ", personaje.name, " | Tipo: ", personaje.personaje_tipo)
		#print("Distancia seguridad: ", distancia_seguridad)
		#print("Distancia actual: ", abs(otro_personaje.global_position.x - personaje.global_position.x))
		#print("Resultado: ", resultado)
		return resultado
	return true


func _dibujar_linea_debug(personaje: Node2D, otro_personaje: Node2D, dist_a_otro: float, distancia_seguridad: float, en_linea_de_vista: bool):
	# se borra si no en distancia
	if dist_a_otro > distancia_seguridad:
		_remover_linea_debug(personaje)
		return
	
	# seteo color
	var color_linea: Color
	if en_linea_de_vista:
		color_linea = Color.RED  # Restricted movement
		print("--- DEBUG: linea ROJA restriccion ---")
	else:
		color_linea = Color.GREEN  # Blocked line of sight
		print("--- DEBUG: linea VERDE ocultos ---")
	
	# puntos
	var origen = personaje.global_position + Vector2(0, -personaje.altura_de_ojos)
	var destino = otro_personaje.global_position + Vector2(0, -otro_personaje.altura_de_cuerpo)
	
	# crear o updatear rayo para linea
	_actualizar_rayo_debug(personaje, origen, destino, color_linea)

func _actualizar_rayo_debug(personaje: Node2D, start_pos: Vector2, end_pos: Vector2, color: Color):
	var rayo_debug = _obtener_rayo_debug(personaje)
	if not rayo_debug:
		rayo_debug = Line2D.new()
		rayo_debug.width = 2.0
		personaje.add_child(rayo_debug)
		_set_rayo_debug_reference(personaje, rayo_debug)
	
	rayo_debug.points = [personaje.to_local(start_pos), personaje.to_local(end_pos)]
	rayo_debug.default_color = color
	print("--- DEBUG: linea de ", start_pos, " hasta ", end_pos, " ---")

func _obtener_rayo_debug(personaje: Node2D) -> Line2D:
	# existe?
	var rayo_debug = personaje.get_node_or_null("RayoDebug")
	return rayo_debug

func _set_rayo_debug_reference(personaje: Node2D, rayo: Line2D):
	# nombre
	if rayo:
		rayo.name = "RayoDebug"

func _remover_linea_debug(personaje: Node2D):
	var rayo_debug = _obtener_rayo_debug(personaje)
	if rayo_debug:
		rayo_debug.queue_free()
		print("--- DEBUG: linea borrada ---")
