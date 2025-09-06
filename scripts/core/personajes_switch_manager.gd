# personajes_switch_manager.gd - v1.1

extends Node

signal personaje_activo_ha_cambiado(nuevo_personaje: Node)

var personajes: Array[Node] = []
var index_personaje_actual: int = -1

func registrar_personaje(personaje: Node):
	if not personaje in personajes:
		personajes.append(personaje)
		# si es el primer personaje, setearlo active
		if index_personaje_actual == -1:
			_switch_a_personaje_por_index(0)
		else:
			# This function name is from a future step, using a placeholder for now
			personaje.call_deferred("set_active_state", false)

func unregistrar_personaje(_personaje: Node):
	pass

func _input(event: InputEvent):
	if event.is_action_pressed("switch_character"):
		if personajes.size() > 1 and EstadosManager.mecanica_global_habilitada(GlobalEnumIndices.MECANICA_CAMBIO_PERSONAJE):
			var next_index = (index_personaje_actual + 1) % personajes.size()
			_switch_a_personaje_por_index(next_index)
			get_viewport().set_input_as_handled()

func _switch_a_personaje_por_index(index: int):
	var viejo_personaje: Node = null
	if index_personaje_actual != -1 and is_instance_valid(personajes[index_personaje_actual]):
		viejo_personaje = personajes[index_personaje_actual]
		# This function name is from a future step, using a placeholder for now
		viejo_personaje.set_active_state(false)

	index_personaje_actual = index
	var nuevo_personaje = personajes[index_personaje_actual]

	# The 'await' here is what makes the function asynchronous.
	await nuevo_personaje.play_transicion_de_switch(viejo_personaje)
	
	# This function name is from a future step, using a placeholder for now
	nuevo_personaje.set_active_state(true)
	emit_signal("personaje_activo_ha_cambiado", nuevo_personaje)

func get_personaje_activo() -> Node:
	if index_personaje_actual != -1: return personajes[index_personaje_actual]
	return null

func get_personajes_todos() -> Array[Node]:
	return personajes


### FUCIONES PARA FORZAR PERSONAJE ACTIVO ####
func get_personaje_por_tipo(tipo: GlobalEnumIndices.Personaje) -> Node:
	for personaje in personajes:
		if personaje.personaje_tipo == tipo:
			return personaje
	return null

func forzar_personaje_activo(tipo: GlobalEnumIndices.Personaje):
	for i in range(personajes.size()):
		if personajes[i].personaje_tipo == tipo:
			_switch_a_personaje_por_index(i)
			break
