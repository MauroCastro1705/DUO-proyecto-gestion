# caja_interactuable.gd - v1.0 
# liviana o pesada
@tool
class_name CajaInteractuable
extends ObjetoInteractuableBase

enum CajaTipo { LIVIANA, PESADA }

@export var caja_tipo: CajaTipo = CajaTipo.LIVIANA:
	set(value):
		print("Llamado a setear caja")
		caja_tipo = value
		# Para que cambie sprite y colision en EDITOR.. No esta andando y no me doy cuenta porquw
		if Engine.is_editor_hint():
			print("Llamado es en EDITOR")
			actualizar_apariencia_y_colision()
		else:
			print("Llamado pero no detecta que es en EDITOR")


@export var sprite_liviana: Sprite2D
@export var sprite_pesada: Sprite2D

@export var collision_polygon_liviana: CollisionPolygon2D
@export var collision_polygon_pesada: CollisionPolygon2D
@export var color_modulate_on: Color = Color(1, 1, 1, 1)
@export var color_modulate_off: Color = Color(1, 1, 1, 0)



var esta_siendo_empujada: bool = false
var direccion_empuje: float = 0.0

func _ready():
	super._ready()
	actualizar_apariencia_y_colision() # deberia largar bien desde el editor, pero reactualizo aca para estar seguro


func actualizar_apariencia_y_colision():
	print("actualizar_apariencia_y_colision() llamado correctamente")
	if caja_tipo == CajaTipo.LIVIANA:
		# actualizo sprites
		if sprite_liviana:
			print("Liviana visible")
			sprite_liviana.visible = true
		if sprite_pesada:
			print("Pesada invisible")
			sprite_pesada.visible = false
			
		# actualizo colisiones
		if collision_polygon_liviana:
			print("Colision Liviana activada")
			collision_polygon_liviana.set_deferred("disabled", false)
			collision_polygon_liviana.self_modulate = color_modulate_on 
			
		if collision_polygon_pesada:
			print("Colision Pesada desactivada")
			collision_polygon_pesada.set_deferred("disabled", true)
			collision_polygon_pesada.self_modulate = color_modulate_off 
	else: # PESADA idem
		if sprite_liviana:
			print("Liviana invisible")
			sprite_liviana.visible = false
		if sprite_pesada:
			print("Pesada visible")
			sprite_pesada.visible = true
		if collision_polygon_liviana:
			print("Colision Liviana desactivada")
			collision_polygon_liviana.set_deferred("disabled", true)
			collision_polygon_liviana.self_modulate = color_modulate_off
		if collision_polygon_pesada:
			print("Colision Pesada activada")
			collision_polygon_pesada.set_deferred("disabled", false)
			collision_polygon_pesada.self_modulate = color_modulate_on


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
			# Flag de fail animation
			personaje.esta_en_animacion_fail = true
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
	
	
