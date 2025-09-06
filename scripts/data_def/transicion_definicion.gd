# transicion_definicion.gd - v1.0

class_name TransicionDefinicion
extends Resource

enum TriggerContext { CUALQUIERA, ESPECIAL }

@export var desde_humor: GlobalEnumIndices.Humor = GlobalEnumIndices.Humor.NORMAL
@export var hacia_humor: GlobalEnumIndices.Humor = GlobalEnumIndices.Humor.NORMAL
@export var desde_personaje: GlobalEnumIndices.Personaje = GlobalEnumIndices.Personaje.NONE
@export var hacia_personaje: GlobalEnumIndices.Personaje = GlobalEnumIndices.Personaje.NONE

@export_group("Effects to Play")
@export_multiline var notas: String
@export var override_nombre_animacion: StringName = ""
@export var sound_effect: AudioStream
@export var particle_effect: PackedScene
