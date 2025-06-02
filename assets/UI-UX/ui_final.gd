extends Control
var bruno = Global.active_player_bruno
var alejandra = Global.active_player_alejandra

@onready var bruno_cabeza = $BrunoCabejaMejor
@onready var bruno_neon = $BrunoCabejaMejor/Bruno_neon

@onready var alejandra_cabeza = $AlejandraCabezaMejor
@onready var alejandra_neon = $AlejandraCabezaMejor/Alejandra_neon



func _process(delta: float) -> void:
	if bruno: #esta activo...
		_activar_bruno()
	elif alejandra:
		_activar_alejandra()
	
	
func _activar_bruno():
		bruno_cabeza.z_index = 10
		bruno_neon.visible = true
		alejandra_cabeza.z_index = 1
		alejandra_neon.visible = false
		
func _activar_alejandra():
		bruno_cabeza.z_index = 1
		bruno_neon.visible = false
		alejandra_cabeza.z_index = 10
		alejandra_neon.visible = true
