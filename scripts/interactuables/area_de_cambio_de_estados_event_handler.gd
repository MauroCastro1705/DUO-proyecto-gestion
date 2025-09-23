# area_de_cambio_de_estados_event_handler.gd
# attachearlo a un Node en la misma escena

extends Node

func _ready():
	# Connect to all AreaDeCambioDeEstados nodes in the scene
	var areas = []
	
	# Find all Area2D nodes recursively and check if they have our class
	_find_area_nodes(get_tree().current_scene, areas)
	
	print("--- DEBUG HANDLER: Found ", areas.size(), " AreaDeCambioDeEstados nodes")
	
	for area in areas:
		if area.has_signal("area_cambio_de_estado_triggered"):
			area.area_cambio_de_estado_triggered.connect(_on_area_cambio_de_estado_triggered)
			print("--- DEBUG HANDLER: Connected to area: ", area.name)


func _find_area_nodes(node: Node, areas: Array):
	# Check if this node is an AreaDeCambioDeEstados
	if node is Area2D and node.get_script():
		var script = node.get_script()
		if script.get_global_name() == "AreaDeCambioDeEstados":
			areas.append(node)
	
	# Recursively check children
	for child in node.get_children():
		_find_area_nodes(child, areas)


func _on_area_cambio_de_estado_triggered(area: Area2D):
	# Match por nombre de area disparada
	match area.name:
		"area_e_normal_post_bobo":
			print("Todo normal de nuevo")
			#Dialogos.colectivero_inicio(ale_marker,bruno_marker,$Marker2D_colectivero)
			#Dialogos.colectivero_inicio_bool = true
		"area_e_grande_quiere_birra":
			print("Bruno se ENOJO")
		_:
			# Default behavior for unnamed areas
			print("Area cambio de estados triggered: ", area.name, " - sin POST EVENTOS")

#func _do_special_action():
	#print("Special area action triggered!")
#
#
#func _on_area_e_normal_post_bobo_area_cambio_de_estado_triggered(mode: AreaDeCambioDeEstados.ModoArea, personaje: Node2D, area: Area2D) -> void:
	#pass # Replace with function body.
