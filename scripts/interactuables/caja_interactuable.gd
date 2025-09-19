# caja_interactuable.gd - v1.0 
# liviana o pesada

class_name CajaInteractuable
extends ObjetoInteractuableBase

enum CajaTipo { LIVIANA, PESADA }

@export var caja_tipo: CajaTipo = CajaTipo.LIVIANA:
	set(value):
		caja_tipo = value
		# Para que cambie sprite y colision en EDITOR.. No esta andando y no me doy cuenta porquw
		if Engine.is_editor_hint():
			actualizar_apariencia_y_colision()

@export var sprite_liviana: Sprite2D
@export var sprite_pesada: Sprite2D

@export var collision_polygon_liviana: CollisionPolygon2D
@export var collision_polygon_pesada: CollisionPolygon2D

var esta_siendo_empujada: bool = false
var direccion_empuje: float = 0.0

func _ready():
	super._ready()
	actualizar_apariencia_y_colision() # deberia largar bien desde el editor, pero reactualizo aca para estar seguro


func actualizar_apariencia_y_colision():
	if caja_tipo == CajaTipo.LIVIANA:
		# actualizo sprites
		if sprite_liviana:
			sprite_liviana.visible = true
		if sprite_pesada:
			sprite_pesada.visible = false
			
		# actualizo colisiones
		if collision_polygon_liviana:
			collision_polygon_liviana.disabled = false
		if collision_polygon_pesada:
			collision_polygon_pesada.disabled = true
	else: # PESADA idem
		if sprite_liviana:
			sprite_liviana.visible = false
		if sprite_pesada:
			sprite_pesada.visible = true
		if collision_polygon_liviana:
			collision_polygon_liviana.disabled = true
		if collision_polygon_pesada:
			collision_polygon_pesada.disabled = false


func _integrate_forces(state: PhysicsDirectBodyState2D):
	#super._integrate_forces(state)
	if esta_siendo_empujada and is_instance_valid(personaje_interactuando):
		var push_force = Vector2(direccion_empuje * 7500, 0)
		state.apply_central_force(push_force)


func puede_interactuar_con_personaje(personaje: PersonajePunkBase) -> bool:
	if not super.puede_interactuar_con_personaje(personaje):
		return false
	
	# MChequeos de interaccion contra el emun
	var mecanica_a_revisar = GlobalEnumIndices.EMPUJAR_LIVIANO
	if caja_tipo == CajaTipo.PESADA:
		mecanica_a_revisar = GlobalEnumIndices.EMPUJAR_PESADO
	
	#bloqueo luego
	return personaje.puede_realizar_accion(mecanica_a_revisar)


func comenzar_empujar(personaje: PersonajePunkBase, direccion: float) -> bool:
	if not comenzar_interaccion(personaje):
		return false
	
	# chico pesada?
	if caja_tipo == CajaTipo.PESADA and personaje.personaje_tipo == GlobalEnumIndices.Personaje.CHICO:
		if personaje.animation_player and personaje.animation_player.has_animation("empujar_caja_pesada"):
			personaje.animation_player.play("empujar_caja_pesada")
		return false  # no empujar
	
	esta_siendo_empujada = true
	direccion_empuje = direccion
	return true

func finalizar_empujar(personaje: PersonajePunkBase):
	if not esta_siendo_empujada:
		return
	finalizar_interaccion(personaje)
	esta_siendo_empujada = false
	direccion_empuje = 0.0
	
	
