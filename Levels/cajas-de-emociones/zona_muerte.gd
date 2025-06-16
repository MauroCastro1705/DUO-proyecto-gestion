extends Node2D

func _ready() -> void:
	Global.game_over = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		print("Es personaje murio:", body)
		Global.game_over = true #variable global que llama una funcion en el nivel principal
