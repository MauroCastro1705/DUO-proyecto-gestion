extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		print("Es personaje murio:", body)
		get_tree().reload_current_scene()
