class_name PauseMenuController
extends Node

## Node for opening a pause menu when detecting a 'ui_cancel' event.

@export var pause_menu_packed : PackedScene
@export var focused_viewport : Viewport

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if not focused_viewport:
			focused_viewport = get_viewport()
		var _initial_focus_control = focused_viewport.gui_get_focus_owner()
		var current_menu = pause_menu_packed.instantiate()
		# 👉 Asegurate de tener un nodo llamado "UI" como hijo de la escena actual
		var ui_node = get_tree().current_scene.get_node("CanvasLayer") 
		if ui_node:
			ui_node.call_deferred("add_child", current_menu)
		else:
			push_error("No se encontró el nodo UI para agregar el menú de pausa")
		await current_menu.tree_exited
		if is_inside_tree() and _initial_focus_control:
			_initial_focus_control.grab_focus()
