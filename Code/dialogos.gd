extends Node

var primer_dialogo_bool:bool = false
func primer_dialogo(laura, ramiro):
	var layout = Dialogic.start("res://Dialogos/timeline_test.dtl")
	layout.register_character(load("res://Dialogos/Laura.dch"),laura,)
	layout.register_character(load("res://Dialogos/Ramiro.dch"),ramiro,)
	

func alejandra_caja_pesada(laura):
	var layout = Dialogic.start("res://Dialogos/alejandra_caja_pesada.dtl")
	layout.register_character(load("res://Dialogos/Laura.dch"),laura,)

func bruno_no_puede_cambiar(bruno):
	var layout = Dialogic.start("res://Dialogos/bruno_no_puede_cambiar.dtl")
	layout.register_character(load("res://Dialogos/Ramiro.dch"),bruno,)
	
var inicio_ambos_pj_bool:bool = false
func inicio_ambos_pj(laura, ramiro):
	var layout = Dialogic.start("res://Dialogos/inicio_ambos_pj.dtl")
	layout.register_character(load("res://Dialogos/Laura.dch"),laura,)
	layout.register_character(load("res://Dialogos/Ramiro.dch"),ramiro,)
	
var colectivero_inicio_bool:bool = false
func colectivero_inicio(laura, ramiro, colectivero):
	var layout = Dialogic.start("res://Dialogos/colectivero_inicio.dtl")
	layout.register_character(load("res://Dialogos/Laura.dch"),laura,)
	layout.register_character(load("res://Dialogos/colectivero.dch"),colectivero,)
	layout.register_character(load("res://Dialogos/Ramiro.dch"),ramiro,)

var cables_pelados_bool:bool = false
func cables_pelados(laura, ramiro):
	var layout = Dialogic.start("res://Dialogos/cables_pelados.dtl")
	layout.register_character(load("res://Dialogos/Laura.dch"),laura,)
	layout.register_character(load("res://Dialogos/Ramiro.dch"),ramiro,)

var mas_cables_pelados_bool:bool = false
func mas_cables_pelados(laura, ramiro):
	var layout = Dialogic.start("res://Dialogos/mas_cables_pelados.dtl")
	layout.register_character(load("res://Dialogos/Laura.dch"),laura,)
	layout.register_character(load("res://Dialogos/Ramiro.dch"),ramiro,)
	
var se_enojo_bruno_bool:bool = false
func se_enojo_bruno(laura):
	var layout = Dialogic.start("res://Dialogos/ale_cuando_bruno_se_enoja.dtl")
	layout.register_character(load("res://Dialogos/Laura.dch"),laura,)
