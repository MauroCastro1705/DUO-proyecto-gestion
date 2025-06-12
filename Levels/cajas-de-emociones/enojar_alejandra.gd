extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		print("Es personaje entro:", body)
		if body.has_method("check_emocion"):
			print("colision emocion-box cautar alejandra")
			if body.name == "Laura":  #si el body se llama Laura, se activa la animacion enojada
				body.check_emocion("cauta")
