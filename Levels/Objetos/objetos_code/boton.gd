extends Area2D

signal boton_pulsado



func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		emit_signal("boton_pulsado")
		print("boton pulsado")
