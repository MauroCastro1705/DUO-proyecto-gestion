extends Node2D
@export var proximo_nivel: PackedScene #nivel cargado

func _on_cambio_de_nivel_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador") and proximo_nivel:
		call_deferred("_cambiar_nivel")


func _cambiar_nivel():
	var main = get_tree().current_scene
	main.load_level(proximo_nivel)
