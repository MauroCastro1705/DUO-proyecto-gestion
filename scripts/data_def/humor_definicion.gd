# humor_definicion.gd - v1.0

class_name HumorDefinicion
extends Resource

@export var humor: GlobalEnumIndices.Humor = GlobalEnumIndices.Humor.NORMAL
@export var sufijo_animacion: String = "_normal"
@export var mecanicas_deshabilitadas: Array[String]
@export var speed_caminar_multiplicador: float = 1.0
@export var speed_empujar_multiplicador: float = 1.0
@export var fuerza_salto_multiplicador: float = 1.0
@export var script_de_comportamiento: Script
@export var prohibe_ser_activo: bool = false
