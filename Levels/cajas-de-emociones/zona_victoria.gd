extends Node2D



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		Global.primer_nivel_win = true #variable global que llama una funcion en el nivel principal
