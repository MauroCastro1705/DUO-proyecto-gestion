extends Control
@export var escena_menu_principal: PackedScene

func _on_boton_main_menu_pressed() -> void:
	if escena_menu_principal:
		get_tree().change_scene_to_packed(escena_menu_principal)
