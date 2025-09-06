# objeto_interactuable_base.gd - v1.0
# clase base para cualquier objeto que interactue con personajes

class_name ObjetoInteractuableBase
extends RigidBody2D

signal interaccion_ha_comenzado(personaje: PersonajePunkBase)
signal interaccion_ha_finalizado(personaje: PersonajePunkBase)

var actualmente_interactuando: bool = false
var personaje_interactuando: PersonajePunkBase = null
var esta_sobre_hombros_de: PersonajePunkBase = null # por si apilo en hombros

func _ready():
	# Constrain rotation to keep objects upright.
	angular_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
	angular_damp = 100

func puede_interactuar_con_personaje(_personaje: PersonajePunkBase) -> bool:
	return not actualmente_interactuando

func comenzar_interaccion(personaje: PersonajePunkBase) -> bool:
	if not puede_interactuar_con_personaje(personaje):
		return false
	
	actualmente_interactuando = true
	personaje_interactuando = personaje
	emit_signal("interaccion_ha_comenzado", personaje)
	return true

func finalizar_interaccion(personaje: PersonajePunkBase):
	if not actualmente_interactuando or personaje != personaje_interactuando:
		return
		
	actualmente_interactuando = false
	personaje_interactuando = null
	emit_signal("interaccion_ha_finalizado", personaje)
