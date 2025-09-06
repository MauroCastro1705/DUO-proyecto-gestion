# estado_definicion.gd - v1.0

class_name EstadoDefinicion
extends Resource

@export var estado: GlobalEnumIndices.Estado = GlobalEnumIndices.Estado.NONE
@export var humores_forzados: Dictionary = {}
@export var humores_gatillo: Dictionary = {}
@export var mecanicas_globales_deshabilitadas: Array[String]
@export var personaje_activo_forzado: GlobalEnumIndices.Personaje = GlobalEnumIndices.Personaje.NONE

@export_group("Restricciones Movimiento")
@export var restriccion_movimiento: GlobalEnumIndices.RestriccionMovimiento = GlobalEnumIndices.RestriccionMovimiento.MOVIMIENTO_LIBRE
@export var limite_distancia_a_grande: bool = false
@export var script_de_restriccion_movimiento: Script
