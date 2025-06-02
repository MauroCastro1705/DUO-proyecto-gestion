extends Control

@onready var bruno_cabeza = $BoxContainer/BrunoCabejaMejor
@onready var bruno_neon = $BoxContainer/Bruno_neon
@onready var alejandra_cabeza = $BoxContainer/AlejandraCabezaMejor
@onready var alejandra_neon = $BoxContainer/Alejandra_neon

var last_active = ""

func _process(delta: float) -> void:
	if Global.active_player_bruno and last_active != "bruno":
		_activar_bruno()
		last_active = "bruno"
	elif Global.active_player_alejandra and last_active != "alejandra":
		_activar_alejandra()
		last_active = "alejandra"

func _activar_bruno():
	bruno_cabeza.z_index = 52
	bruno_neon.visible = true
	bruno_neon.z_index = 51
	alejandra_cabeza.z_index = 1
	alejandra_neon.visible = false
	alejandra_neon.z_index = 0
		
func _activar_alejandra():
	bruno_cabeza.z_index = 1
	bruno_neon.visible = false
	bruno_neon.z_index = 0
	alejandra_cabeza.z_index = 52
	alejandra_neon.visible = true
	alejandra_neon.z_index = 51
