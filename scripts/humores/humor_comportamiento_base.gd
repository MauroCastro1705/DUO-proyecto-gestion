# humor_comportamiento_base.gd - v1.0
# clase base para comportamientos ia

class_name HumorComportamientoBase
extends RefCounted

# A reference to the character this behavior is controlling.
var personaje_propietario: PersonajePunkBase

# The constructor. Called when a new behavior is instantiated.
func _init(propietario: PersonajePunkBase):
	self.personaje_propietario = propietario

# Called when this humor becomes active. Use for setup.
func al_comenzar_humor():
	pass

# Called just before this humor becomes inactive. Use for cleanup.
func al_finalizar_humor():
	pass

# Called every physics frame from the character's _physics_process.
# This is where the main AI logic (moving, fleeing, etc.) will go.
# We pass the character as an argument to avoid confusion with 'self'.
func process_physics_mechanic(_personaje: PersonajePunkBase, _delta: float):
	pass
