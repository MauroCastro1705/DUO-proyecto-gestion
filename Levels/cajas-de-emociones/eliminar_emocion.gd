extends Node2D
signal ramiro_entra
#RESETEA PERSONAJES A LA EMOCION NORMAL
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		print("Es personaje entro:", body)
		if body.has_method("check_emocion"):
			body.check_emocion("normal")
	elif body.is_in_group("grupo-ramiro"):
		emit_signal("ramiro_entra")
		Input.action_press("cambiar")
		print("aprete Q")
