# humor_comportamiento_bobo.gd
class_name HumorComportamientoBobo
extends HumorComportamientoBase

@warning_ignore("unused_parameter")
func process_physics_mechanic(personaje: PersonajePunkBase, delta: float):
	
	### DEBUG IA ###

	# Find Chico
	# Get Chico node from HumoresManager's personajes_dicc
	var chico = HumoresManager.personajes_dicc.get(GlobalEnumIndices.Personaje.CHICO, null)
	if not chico:
		return

	# Calculate direction to Chico
	var direccion_x = sign(chico.global_position.x - personaje.global_position.x)
	var dist_a_chico = abs(chico.global_position.x - personaje.global_position.x)

	# Edge detection using personaje's raycasts
	personaje.raycast_detecta_arista_der.force_raycast_update()
	personaje.raycast_detecta_arista_izq.force_raycast_update()
	var hay_arista_a_der = not personaje.raycast_detecta_arista_der.is_colliding()
	var hay_arista_a_izq = not personaje.raycast_detecta_arista_izq.is_colliding()

	# Use the new variable names from the character node
	if dist_a_chico > personaje.distancia_minima_a_chico_cuando_grande_bobo:
		if (hay_arista_a_der and direccion_x == 1) or (hay_arista_a_izq and direccion_x == -1):
			personaje.velocity.x = 0
		else:
			personaje.velocity.x = direccion_x * personaje.move_speed_cuando_bobo
			if Engine.get_physics_frames() % 120 == 0:
				print("BOBO AI sets velocity.x to:", personaje.velocity.x, "dist_a_chico:", dist_a_chico)
	else:
		personaje.velocity.x = 0
	
	# Flip sprite
	if personaje.velocity.x < 0:
		if personaje.sprite_visual:
			personaje.sprite_visual.flip_h = false  # hacia izq
	elif personaje.velocity.x > 0:
		if personaje.sprite_visual:
			personaje.sprite_visual.flip_h = true   # hacia der
