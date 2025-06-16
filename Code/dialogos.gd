extends Node

func primer_dialogo(laura, ramiro):
	var layout = Dialogic.start("res://Dialogos/timeline_test.dtl")
	layout.register_character(load("res://Dialogos/Laura.dch"),laura,)
	layout.register_character(load("res://Dialogos/Ramiro.dch"),ramiro,)
	

func alejandra_caja_pesada(laura):
	var layout = Dialogic.start("res://Dialogos/alejandra_caja_pesada.dtl")
	layout.register_character(load("res://Dialogos/Laura.dch"),laura,)
