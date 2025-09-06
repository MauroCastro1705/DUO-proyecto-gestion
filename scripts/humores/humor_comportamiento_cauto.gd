class_name HumorComportamientoCauto
extends HumorComportamientoBase

var anim_asustado_played: bool = false
var personaje_bloqueado: bool = false

func process_physics_mechanic(personaje: PersonajePunkBase, delta: float):
	# Centralized restriction check
	if not EstadosManager.restriccion_movimiento_hacia_grande_activa():
		return
		
	var grande = HumoresManager.personajes_dicc.get(GlobalEnumIndices.Personaje.GRANDE, null)
	if not grande:
		return

	var direccion_alejarse_de_grande = -sign(grande.global_position.x - personaje.global_position.x)
	var dist_a_grande = abs(grande.global_position.x - personaje.global_position.x)
	var en_linea_de_vista = personaje.tiene_linea_de_vista_a_objetivo(grande)

	# si dentro de zona y a la vista, retrocede
	if dist_a_grande <= personaje.distancia_seguridad_chico_cauto and en_linea_de_vista:
		# animacion asustado una sola vez
		if not anim_asustado_played:
			personaje.play_special_animation("asustar")
			anim_asustado_played = true

		# retroceder
		if personaje.puede_retroceder(direccion_alejarse_de_grande):
			personaje.velocity.x = direccion_alejarse_de_grande * personaje.move_speed_cuando_cauto
			personaje_bloqueado = false
		else:
			personaje.velocity.x = 0
			# animacion acorralado una vez
			if not personaje_bloqueado:
				personaje.play_special_animation("bloqueado")
				personaje_bloqueado = true
	else:
		personaje.velocity.x = 0
		anim_asustado_played = false
		personaje_bloqueado = false
