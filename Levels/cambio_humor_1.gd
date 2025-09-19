extends Area2D
#hacer: agregar codigo de cambio de humor


func _on_body_entered(body: Node2D) -> void:
	var estados = get_node("/root/EstadosManager")
	if estados:
		estados.forzar_estado(GlobalEnumIndices.Estado.E_INICIO)
	else:
		push_error("EstadosManager no encontrado")
