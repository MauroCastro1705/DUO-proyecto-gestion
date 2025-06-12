extends Node2D
@export var escena_menu_principal: PackedScene
@export var escena_a_reiniciar : PackedScene


func _on_boton_reiniciar_pressed() -> void:
	if escena_a_reiniciar:
		get_tree().change_scene_to_packed(escena_a_reiniciar)


func _on_boton_main_menu_pressed() -> void:
	if escena_menu_principal:
		get_tree().change_scene_to_packed(escena_menu_principal)
