# caja_interactuable.gd - v1.0 
# liviana o pesada

class_name CajaInteractuable
extends ObjetoInteractuableBase

enum CajaTipo { LIVIANA, PESADA }

@export var caja_tipo: CajaTipo = CajaTipo.LIVIANA

var esta_siendo_empujada: bool = false
var direccion_empuje: float = 0.0

func _integrate_forces(state: PhysicsDirectBodyState2D):
	#super._integrate_forces(state)
	if esta_siendo_empujada and is_instance_valid(personaje_interactuando):
		var push_force = Vector2(direccion_empuje * 7500, 0)
		state.apply_central_force(push_force)

func puede_interactuar_con_personaje(personaje: PersonajePunkBase) -> bool:
	if not super.puede_interactuar_con_personaje(personaje):
		return false
	
	var mecanica_a_revisar = GlobalEnumIndices.EMPUJAR_LIVIANO
	if caja_tipo == CajaTipo.PESADA:
		mecanica_a_revisar = GlobalEnumIndices.EMPUJAR_PESADO
	
	return personaje.puede_realizar_accion(mecanica_a_revisar)

func comenzar_empujar(personaje: PersonajePunkBase, direccion: float) -> bool:
	if not comenzar_interaccion(personaje):
		return false
	esta_siendo_empujada = true
	direccion_empuje = direccion
	return true

func finalizar_empujar(personaje: PersonajePunkBase):
	if not esta_siendo_empujada:
		return
	finalizar_interaccion(personaje)
	esta_siendo_empujada = false
	direccion_empuje = 0.0
