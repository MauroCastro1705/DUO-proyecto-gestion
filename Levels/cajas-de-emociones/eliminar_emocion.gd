extends Node2D

#RESETEA PERSONAJES A LA EMOCION NORMAL
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		print("Es personaje entro:", body)
		if body.has_method("check_emocion"):
			body.check_emocion("normal")
