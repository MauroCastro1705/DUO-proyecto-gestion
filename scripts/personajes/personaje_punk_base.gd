# personaje_punk_base.gd - v1.2

class_name PersonajePunkBase
extends CharacterBody2D

# --- EXPORTS ---
@export var personaje_tipo: GlobalEnumIndices.Personaje = GlobalEnumIndices.Personaje.NONE
@export var transicion_especial: Array[TransicionDefinicion] = []

# --- Nodos ---
@export var animation_player: AnimationPlayer
@export var sprite_visual: AnimatedSprite2D
@export var animation_tree: AnimationTree
@export var interaccion_detector: Area2D
@export var hombros_detector_raycast: RayCast2D
@export var indicador_personaje_activo: Polygon2D 
@export var color_indicador_activo: Color = Color.DIM_GRAY
@export var raycast_detecta_arista_der: RayCast2D
@export var raycast_detecta_arista_izq: RayCast2D
@export var raycast_objetos_izq: RayCast2D
@export var raycast_objetos_der: RayCast2D

# --- variables para ESTADO---
var _transicion_lookup: Dictionary = {}
var humor_actual_definicion: HumorDefinicion = null
var humor_actual_comportamiento: HumorComportamientoBase = null
var esta_sobre_hombros_de: PersonajePunkBase = null

# --- variables para INTERACCION ---
var interaccion_potencial: ObjetoInteractuableBase = null
var interaccion_activa: ObjetoInteractuableBase = null
var esta_empujando: bool = false
var esta_en_animacion_fail: bool = false
var pin_joint_empujar: PinJoint2D = null


# --- Physics ---
@export_group("Personaje Movimiento")
@export var move_speed: float = 300.0
@export var mult_velocidad_al_empujar: float = 0.6
@export var jump_force: float = -400.0
@export var gravity: float = 980.0
@export_range (0.05,2) var mult_gravity_apex: float = 0.5
@export_range (1,3) var mult_gravity_caida: float = 1.5
@export var velocidad_umbral_caida_apex: float = 50.0

# --- AI ----
@export var distancia_minima_a_chico_cuando_grande_bobo: float = 200.0
@export var move_speed_cuando_bobo: float = 120.0  # velocidad cuando grande zombie
@export var distancia_seguridad_chico_cauto: float = 400.0
@export var altura_de_ojos: float = 60.0
@export var altura_de_cuerpo: float = 60.0
@export var collision_mask_linea_de_vista: int = 1 | 8  # Default: piso + cajas, can be changed in Inspector


# --- Debug ---
@onready var humor_debug_label: Label = $HumorDebugLabel


var _es_personaje_activo: bool = false
var blends_maestro_en_animtree: Array[String] = []


func _ready():
	assert(personaje_tipo != GlobalEnumIndices.Personaje.NONE, "El personaje debe tener un 'personaje_tipo' asignado en el Inspector.")
	
	# Registro en los Managers
	HumoresManager.registrar_personaje(self, personaje_tipo)
	PersonajesSwitchManager.registrar_personaje(self)
	
	# Construye diccionario para transciciones especiales
	for efecto_def in transicion_especial:
		if efecto_def:
			# Cambio de Humor change key: "h_humorORIGEN_humorDESTINO"
			var humor_key = "h_%s_%s" % [efecto_def.desde_humor, efecto_def.hacia_humor]
			_transicion_lookup[humor_key] = efecto_def
			
			# Switch Personaje change key: "s_PersonajeORIGEN_PersonajeDESTINO"
			var switch_key = "s_%s_%s" % [efecto_def.desde_personaje, efecto_def.hacia_personaje]
			_transicion_lookup[switch_key] = efecto_def

	# Conexion de SIGNALS a funcs
	interaccion_detector.body_entered.connect(_al_detectar_interactuable)
	interaccion_detector.body_exited.connect(_al_perder_interactuable)
	
	# Inicia AnimationTree si se asigno
	if animation_tree:
		animation_tree.active = true
		_recolectar_blends_maestro_en_animtree()
	
	#if pin_joint_empujar:
		#pin_joint_empujar.enabled = false

	### DEBUG ###
	call_deferred("_debug_imprimir_nodos_del_animation_tree") # debug
	
	print("--- DEBUG _ready() ---")
	print("Personaje: ", name, " | Tipo: ", personaje_tipo)
	print("distancia_seguridad_chico_cauto: ", distancia_seguridad_chico_cauto)
	

func _physics_process(delta: float):
	if _es_personaje_activo:
		_procesar_input_jugador(delta)
	else:
		actualizar_comportamiento_ia(delta)
	move_and_slide()
	_revisar_estado_hombros()
	_actualizar_animaciones()

func _procesar_input_jugador(delta: float):
	# --- Gravedad ---
	if not is_on_floor():
		if velocity.y < -velocidad_umbral_caida_apex:
			# Ascenso
			velocity.y += gravity * delta
			
		elif velocity.y < velocidad_umbral_caida_apex:
			# Apex
			velocity.y += gravity * mult_gravity_apex * delta
			
		else:
			# Descenso
			velocity.y += gravity * mult_gravity_caida * delta
	
	#velocity.y += gravity * delta

	# Input jugador
	var input_dir_x = Input.get_axis("move_left", "move_right")
	
	# Centralized movement restriction check
	#if not puede_moverse_hacia_grande(input_dir_x):
		#input_dir_x = 0
	var otro_personaje = _get_el_otro_personaje()
	if otro_personaje:
		if not EstadosManager.aplicar_restriccion_movimiento(self, otro_personaje, input_dir_x):
			input_dir_x = 0
	
	# Input empujar o interaccion
	if Input.is_action_pressed("interaccion"):
		if not esta_empujando and is_instance_valid(interaccion_potencial):
			_comenzar_empujar()
	else:
		if esta_empujando:
			_finalizar_empujar()


	# --- Movimiento ---
	var actual_move_speed: float = move_speed
	if esta_empujando:
		actual_move_speed *= mult_velocidad_al_empujar

	if input_dir_x:
		velocity.x = input_dir_x * actual_move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, actual_move_speed) # ralentiza


	# Salto por player input
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if puede_realizar_accion(GlobalEnumIndices.MECANICA_SALTO):
			velocity.y = jump_force
	
	# Flip el sprite
	if is_instance_valid(sprite_visual):
		if velocity.x < 0:
			sprite_visual.flip_h = false # izq porque los dibuje invertidos
		elif velocity.x > 0:
			sprite_visual.flip_h = true  # derecha
			
			
# --- AI y animacion ---
func _get_el_otro_personaje() -> Node2D:
	# get el otro personaje de HumoresManager
	var personajes = HumoresManager.personajes_dicc
	@warning_ignore("shadowed_variable")
	for personaje_tipo in personajes:
		if personaje_tipo != self.personaje_tipo:  # que no sea el mismo tipo
			return personajes[personaje_tipo]
	return null


func actualizar_comportamiento_ia(delta: float):
	
	### DEBUG IA ###
	#if personaje_tipo == GlobalEnumIndices.Personaje.GRANDE:
		#print("Grande esta_sobre_hombros_de:", esta_sobre_hombros_de)
	
	# solo actualizo gravedad si no es personaje activo
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	#velocity.x = 0 # reseteo antes de IA
	
	### en caso de Hombros - METODO VELOCITY DE GRANDE
	if is_instance_valid(esta_sobre_hombros_de):
		var movimiento_heredado = esta_sobre_hombros_de.ultimo_movimiento_delta
		velocity = movimiento_heredado / delta
		
		return # evaluar sacar el return par ainteractuar hombros con otros compoortamientos ia
		
	if humor_actual_comportamiento:
		humor_actual_comportamiento.process_physics_mechanic(self, delta)
		
	### en caso de Hombros - METODO FUERZO POSICION DIRECTA
	#if is_instance_valid(esta_sobre_hombros_de):
		#velocity = Vector2.ZERO
		#var target_position = esta_sobre_hombros_de.global_position + Vector2(0, -64) # ver dif de altura
		#global_position = target_position
		#return

func _actualizar_animaciones():
	if not animation_tree:
		print("NO hay Animation Tree")
		return
	pass

# --- Funciones CENTRALES ---

# se llma desde HumoresManager
#func aplicar_humor_definicion(nueva_humor_def: HumorDefinicion):
	#var viejo_humor_tipo = GlobalEnumIndices.Humor.NORMAL
	#if is_instance_valid(humor_actual_definicion):
		#viejo_humor_tipo = humor_actual_definicion.humor
	#
	#var nuevo_humor_tipo = nueva_humor_def.humor
	#
	#var efecto_key = "h_%s_%s" % [viejo_humor_tipo, nuevo_humor_tipo]
	#var efecto_def: TransicionDefinicion = _transicion_lookup.get(efecto_key, null)
	#
	#var animacion_a_ejecutar: StringName = ""
	#if efecto_def and not efecto_def.override_nombre_animacion.is_empty():
		#animacion_a_ejecutar = efecto_def.override_nombre_animacion
	#else:
		#var viejo_humor_nombre = GlobalEnumIndices.Humor.find_key(viejo_humor_tipo).to_lower()
		#var nuevo_humor_nombre = GlobalEnumIndices.Humor.find_key(nuevo_humor_tipo).to_lower()
		#animacion_a_ejecutar = "change_%s_to_%s" % [viejo_humor_nombre, nuevo_humor_nombre]
	#
	#await _ejecutar_transicion(animacion_a_ejecutar, efecto_def)
	#
	## Clean up old humor behavior
	#if humor_actual_comportamiento:
		#humor_actual_comportamiento.al_finalizar_humor()
#
	#humor_actual_definicion = nueva_humor_def
	#
	## Instantiate and setup new dynamic behavior if one is defined
	#if humor_actual_definicion.script_de_comportamiento:
		#humor_actual_comportamiento = humor_actual_definicion.script_de_comportamiento.new(self)
		#humor_actual_comportamiento.al_comenzar_humor()
	#else:
		#humor_actual_comportamiento = null
#
	## update nuevos indices de humor al animationtree
	#if animation_tree:
		#print("Hay Animation Tree")
		#var nuevo_humor_indice = humor_actual_definicion.humor
		#var ruta_parametro = _get_blend_y_eje_maestro_actual("x")
		#
		#if not ruta_parametro.is_empty():
			#animation_tree.set(ruta_parametro, nuevo_humor_indice)
# Temporarily replace the function in personaje_punk_base.gd

#func aplicar_humor_definicion(nueva_humor_def: HumorDefinicion):
	#print("--- DEBUG: '%s'.aplicar_humor_definicion() llamado. ---" % self.name)
	#print(" -> Valor recibido: %s" % str(nueva_humor_def))
#
	#if not is_instance_valid(nueva_humor_def):
		#printerr(" -> ERROR: El valor recibido es nulo. Deteniendo.")
		#return
	#
	#humor_actual_definicion = nueva_humor_def
	#
	#print(" -> ÉXITO: humor_actual_definicion ahora es '%s'" % GlobalEnumIndices.Humor.find_key(humor_actual_definicion.humor))

#func _actualizar_todos_los_blends_de_humor(nuevo_humor_indice: int):
	#var state_machine_node = animation_tree.get("nodes/StateMachine/node")
	#if not state_machine_node: 
		#printerr("Error: No se pudo encontrar el nodo 'StateMachine' en el AnimationTree.")
		#return
	#for state_name in state_machine_node.get_travel_points():
		#var parametro_final = ""
		#var nodo_de_estado = animation_tree.get("nodes/" + state_name + "/node")
		#if nodo_de_estado is AnimationNodeBlendSpace1D:
			#parametro_final = "blend_position"
		#elif nodo_de_estado is AnimationNodeBlendSpace2D:
			#parametro_final = "blend_position.x"
		#if not parametro_final.is_empty():
			#var ruta_parametro = "parameters/%s/%s" % [state_name, parametro_final]
			#animation_tree.set(ruta_parametro, nuevo_humor_indice)

func aplicar_humor_definicion(nueva_humor_def: HumorDefinicion):
	# chequear si HumorManager paso fruta
	if not is_instance_valid(nueva_humor_def):
		printerr("ERROR en '%s': Se intentó aplicar una HumorDefinicion nula. Revisa que el recurso .tres existe y está bien configurado." % self.name)
		return

	var viejo_humor_tipo: GlobalEnumIndices.Humor
	if is_instance_valid(humor_actual_definicion):
		viejo_humor_tipo = humor_actual_definicion.humor
	else:
	# se fuerza en primera iniciacion
		viejo_humor_tipo = GlobalEnumIndices.Humor.NORMAL
	
	# CENTRAL cambio de humor efectivo
	var nuevo_humor_tipo = nueva_humor_def.humor
	humor_actual_definicion = nueva_humor_def

	# --- 4. Handle Special Transition Animation ---
	var efecto_key = "h_%s_%s" % [viejo_humor_tipo, nuevo_humor_tipo]
	var efecto_def: TransicionDefinicion = _transicion_lookup.get(efecto_key, null)
	var animacion_a_ejecutar: StringName = ""
	if efecto_def and not efecto_def.override_nombre_animacion.is_empty():
		animacion_a_ejecutar = efecto_def.override_nombre_animacion
	else:
		var viejo_humor_nombre = GlobalEnumIndices.Humor.find_key(viejo_humor_tipo).to_lower()
		var nuevo_humor_nombre = GlobalEnumIndices.Humor.find_key(nuevo_humor_tipo).to_lower()
		animacion_a_ejecutar = "change_%s_to_%s" % [viejo_humor_nombre, nuevo_humor_nombre]
	
	# This await call will play the one-off transition animation.
	await _ejecutar_transicion(animacion_a_ejecutar, efecto_def)
	
	# --- 5. Update AI Behavior ---
	if is_instance_valid(humor_actual_comportamiento):
		humor_actual_comportamiento.al_finalizar_humor()
	
	if humor_actual_definicion.script_de_comportamiento:
		humor_actual_comportamiento = humor_actual_definicion.script_de_comportamiento.new(self)
		humor_actual_comportamiento.al_comenzar_humor()
	else:
		humor_actual_comportamiento = null
	
	### DEBUG IA ###
	if personaje_tipo == GlobalEnumIndices.Personaje.GRANDE:
		print("Grande humor_actual_comportamiento:", humor_actual_comportamiento)

	# --- 6. Update the AnimationTree BlendSpaces 1d y 2d ---
	if animation_tree:
		_actualizar_todos_los_blends_de_humor(nuevo_humor_tipo)

# --- Update de Debug Label ---
	_update_debug_humor_label(GlobalEnumIndices.Humor.find_key(nuevo_humor_tipo))
	print("nueva funcion recorre states ",get_root_blendspace_nodes())
		
	#
	##for param_path in all_params:
		### The parameters for our maestro states look like: "parameters/idle_maestro/blend_position"
		##if param_path.begins_with("parameters/") and param_path.ends_with("/blend_position"):
			### We found a blend space state! Now we set its value.
			##animation_tree.set(param_path, nuevo_humor_indice)
			##print(" -> Actualizado blend para: %s" % param_path)

func _actualizar_todos_los_blends_de_humor(nuevo_humor_indice: int):
	if not animation_tree:
		return

	# Poner todos los nodos a mano si falla el metodo automatico
	#var maestro_states_params = [
		#"idle_maestro",
		#"caminar_maestro",
		#"saltar_maestro"
	#]
	# Get the playback object for the state machine.
	
	print("--- DEBUG: Actualizando blends de humor para el índice: %d ---" % nuevo_humor_indice)

	var nuevo_humor_float = float(nuevo_humor_indice)

	for param_name in blends_maestro_en_animtree:
		# The path for the .set() method is "parameters/ParameterName".
		var ruta_parametro = "parameters/" + param_name + "/blend_position"
		
		animation_tree [ruta_parametro] = nuevo_humor_float
		
		print("OK para nodo Blend 1d: ", param_name)
		
	# Fuerzo el cambio inmediato. un poco desprolijo
	animation_tree.set("active", false)
	animation_tree.set("active", true)
		


func _get_blend_y_eje_maestro_actual(eje_blend: String = "x") -> String:
	if not animation_tree:
		print("No hay Animation Tree")
		return ""
	
	var maquina_de_estados_anim = animation_tree.get("parameters/playback")
	print(maquina_de_estados_anim)
	var estado_actual_nombre = maquina_de_estados_anim.get_current_node()
	print(estado_actual_nombre)
	var nodo_de_estado = animation_tree.get("nodes/" + estado_actual_nombre + "/node")
	print(nodo_de_estado)
	var parametro_final = ""
	
	if nodo_de_estado is AnimationNodeBlendSpace1D:
		parametro_final = "blend_position"
	elif nodo_de_estado is AnimationNodeBlendSpace2D:
		parametro_final = "blend_position." + eje_blend
	else:
		return ""
			
	print("parameters/%s/%s" % [estado_actual_nombre, parametro_final])
	return "parameters/%s/%s" % [estado_actual_nombre, parametro_final]



# llamado por PersonajesSwitchManager
func play_transicion_de_switch(desde_personaje: PersonajePunkBase):
	var desde_tipo_personaje = GlobalEnumIndices.Personaje.NONE
	if is_instance_valid(desde_personaje):
		desde_tipo_personaje = desde_personaje.personaje_tipo
	
	var efecto_key = "s_%s_%s" % [desde_tipo_personaje, self.personaje_tipo]
	var efecto_def: TransicionDefinicion = _transicion_lookup.get(efecto_key, null)
	
	if efecto_def:
		await _ejecutar_transicion(efecto_def.override_nombre_animacion, efecto_def)

func _ejecutar_transicion(anim_nombre: StringName, efecto_def: TransicionDefinicion):
	var has_played_animation = false
	if not anim_nombre.is_empty() and animation_player.has_animation(anim_nombre):
		has_played_animation = true
		await play_animation_and_wait(anim_nombre)

	if efecto_def:
		play_transicion_adicional(efecto_def)

	if not has_played_animation and efecto_def and efecto_def.sound_effect:
		await get_tree().create_timer(0.1).timeout

func play_animation_and_wait(anim_nombre: StringName):
	animation_tree.active = false
	animation_player.play(anim_nombre)
	await animation_player.animation_finished
	animation_tree.active = true

func play_transicion_adicional(efecto_def: TransicionDefinicion):
	if efecto_def.sound_effect:
		pass # logica de SFX
	if efecto_def.particle_effect:
		pass # logica de particulas


# --- Interacciones y Habilitaciones ---

func puede_realizar_accion(nombre_mecanica: String) -> bool:
	### DEBUG IA ###
	print("Checking puede_realizar_accion for:", nombre_mecanica)
	
	
	print(EstadosManager.mecanica_global_habilitada(nombre_mecanica))
	if not EstadosManager.mecanica_global_habilitada(nombre_mecanica):
		return false
	if humor_actual_definicion and nombre_mecanica in humor_actual_definicion.mecanicas_deshabilitadas:
		return false
	print("Si, puede habilitar Hombros")
	return true

func _comenzar_empujar():
	if not interaccion_potencial: return

	# Calculate direction for push or pull
	var box_pos = interaccion_potencial.global_position.x
	var char_pos = global_position.x
	var input_dir_x = Input.get_axis("move_left", "move_right")
	if input_dir_x == 0:
		return  # Only allow push/pull if player is pressing a direction

	var direction = sign(box_pos - char_pos)
	var input_direction = sign(input_dir_x)
	var empuje = direction if input_direction == direction else -direction
	if empuje == 0:
		return  # Prevent accidental launches

	if interaccion_potencial is CajaInteractuable:
		if interaccion_potencial.comenzar_empujar(self, empuje):
			esta_empujando = true
			interaccion_activa = interaccion_potencial
			if pin_joint_empujar and pin_joint_empujar.is_inside_tree():
				pin_joint_empujar.queue_free()  # Clean up any existing joint
			pin_joint_empujar = PinJoint2D.new()
			pin_joint_empujar.node_a = get_path()
			pin_joint_empujar.node_b = interaccion_potencial.get_path()
			# Set the joint position between character and box
			pin_joint_empujar.position = global_position.lerp(interaccion_potencial.global_position, 0.5)
			get_parent().add_child(pin_joint_empujar)  # Add to the parent, not to self
			
	#if not interaccion_potencial: return
	#
	#var direccion_de_empuje = sign(global_position.direction_to(interaccion_potencial.global_position).x)
	#if interaccion_potencial is CajaInteractuable:
		#if interaccion_potencial.comenzar_empujar(self, direccion_de_empuje):
			#esta_empujando = true
			#interaccion_activa = interaccion_potencial
	
	### CON METODO PINJOINT ###
	#if pin_joint_empujar:
		#pin_joint_empujar.node_a = get_path()
		#pin_joint_empujar.node_b = interaccion_potencial.get_path()
		#pin_joint_empujar.disabled = false

func _finalizar_empujar():
	if not interaccion_activa: return
	if interaccion_activa is CajaInteractuable:
		interaccion_activa.finalizar_empujar(self)
	esta_empujando = false
	interaccion_activa = null
	
	# Stop fail animation if it's playing
	if esta_en_animacion_fail:
		esta_en_animacion_fail = false
		if animation_player and animation_player.is_playing():
			animation_player.stop()
	
	# Remove the joint when done
	if pin_joint_empujar and pin_joint_empujar.is_inside_tree():
		pin_joint_empujar.queue_free()
		pin_joint_empujar = null
	
	
	#if not interaccion_activa: return
	#if interaccion_activa is CajaInteractuable:
		#interaccion_activa.finalizar_empujar(self)
	#esta_empujando = false
	#interaccion_activa = null
	
	### CON METODO PINJOINT ###
	#if pin_joint_empujar:
		#pin_joint_empujar.disabled = true

func _al_detectar_interactuable(body: Node2D):
	if body is ObjetoInteractuableBase:
		interaccion_potencial = body

func _al_perder_interactuable(body: Node2D):
	if body == interaccion_potencial:
		interaccion_potencial = null

# llamado por PersonajesSwitchManager
func set_active_state(is_active: bool):
	_es_personaje_activo = is_active
	# reseteo al desactivar
	if not is_active:
		velocity.x = 0
		indicador_personaje_activo.visible = false
		# ceso acciones
		esta_empujando = false
		if interaccion_activa:
			_finalizar_empujar()
		
	if is_active:
		_mostrar_indicador_personaje_activo()



# --- Mecanica HOMBROS funciones del portador ---

func _mostrar_indicador_personaje_activo():
	if not indicador_personaje_activo:
		return
	
	indicador_personaje_activo.color = color_indicador_activo
	indicador_personaje_activo.visible = true
	
	# anim entrada
	indicador_personaje_activo.scale = Vector2(0.3, 0.3)
	var tween = create_tween()
	tween.tween_property(indicador_personaje_activo, "scale", Vector2(1, 1), 0.2)
	
	# ocultar a los 2 secs
	await get_tree().create_timer(2.0).timeout
	indicador_personaje_activo.visible = false
	
	
func _revisar_estado_hombros():
	if not hombros_detector_raycast: return

	hombros_detector_raycast.force_raycast_update()
	
	if hombros_detector_raycast.is_colliding():
		var collider = hombros_detector_raycast.get_collider()
		if collider is StaticBody2D and collider.name == "HombrosPlataforma":
			if not is_instance_valid(esta_sobre_hombros_de):
				# The collider is the StaticBody, its owner is Grande
				var portador = collider.get_owner()
				if portador is PersonajePunkGrande:
					portador._montar_en_hombros(self)
	else:
		# If the ray is NOT colliding, but we think we are on shoulders, detach.
		if is_instance_valid(esta_sobre_hombros_de):
			_desmontar_hombros()

#func _revisar_estado_hombros():
	## If this character doesn't have the detector (e.g., Grande), do nothing.
	#if not hombros_detector_raycast:
		#return
#
	#var is_colliding_with_shoulders = hombros_detector_raycast.is_colliding()
	#var am_i_on_shoulders_now = is_instance_valid(esta_sobre_hombros_de)
#
	## --- ATTACH LOGIC ---
	#if is_colliding_with_shoulders and not am_i_on_shoulders_now:
		## We just detected the platform, and we weren't on it before. Time to attach.
		#var collider_node = hombros_detector_raycast.get_collider()
		## The collider is the HombrosPlataforma StaticBody2D. Its owner is Grande.
		#if collider_node and collider_node.get_owner() is PersonajePunkGrande:
			#var portador: PersonajePunkGrande = collider_node.get_owner()
			#portador._montar_en_hombros(self)
			#
	## --- DETACH LOGIC ---
	#elif not is_colliding_with_shoulders and am_i_on_shoulders_now:
		## We are no longer detecting the platform, but we thought we were on it. Time to detach.
		#_desmontar_hombros()


func _desmontar_hombros():
	if not is_instance_valid(esta_sobre_hombros_de): return
	if esta_sobre_hombros_de.has_method("_notificar_hombros_desmonte"):
		esta_sobre_hombros_de._notificar_hombros_desmonte()
	esta_sobre_hombros_de = null

func set_hombros_portador(portador: PersonajePunkGrande):
		esta_sobre_hombros_de = portador

func forzar_desmontar_hombros():
	_desmontar_hombros()
	velocity.y = jump_force * 0.25


func _recolectar_blends_maestro_en_animtree():
	blends_maestro_en_animtree.clear()
	
	if not animation_tree or not animation_tree.tree_root:
		return
	
	var root_state_machine = animation_tree.tree_root
	
	if not root_state_machine is AnimationNodeStateMachine:
		return
	
	# Collect all node names from transitions
	var found_nodes: Array[String] = []
	
	for i in range(root_state_machine.get_transition_count()):
		var from_node = root_state_machine.get_transition_from(i)
		var to_node = root_state_machine.get_transition_to(i)
		
		if from_node not in found_nodes:
			found_nodes.append(from_node)
		if to_node not in found_nodes:
			found_nodes.append(to_node)
	
	# Check which ones are BlendSpace1D and add to class variable
	for node_name in found_nodes:
		if root_state_machine.has_node(node_name):
			var node = root_state_machine.get_node(node_name)
			if node is AnimationNodeBlendSpace1D:
				blends_maestro_en_animtree.append(node_name)
	
	print("Estados 'Maestro' con blend detectados: ", blends_maestro_en_animtree)


### FUNCIONES DE AI ###

func puede_retroceder(direccion: float) -> bool:
	# true si se puede mover en determinada direccion si no esta bloqueado
	if direccion < 0 and raycast_objetos_izq:
		raycast_objetos_izq.force_raycast_update()
		return not raycast_objetos_izq.is_colliding()
	elif direccion > 0 and raycast_objetos_der:
		raycast_objetos_der.force_raycast_update()
		return not raycast_objetos_der.is_colliding()
	return true


func puede_moverse_hacia_otro_personaje(otro_personaje: Node2D, input_dir_x: float, distancia_seguridad: float) -> bool:
	var direccion_a_otro = sign(otro_personaje.global_position.x - global_position.x)
	var dist_a_otro = abs(otro_personaje.global_position.x - global_position.x)
	var en_linea_de_vista = tiene_linea_de_vista_a_objetivo(otro_personaje)
	if dist_a_otro <= distancia_seguridad and input_dir_x == direccion_a_otro and en_linea_de_vista:
		return false
	return true


#func puede_moverse_hacia_grande(input_dir_x: float) -> bool:
	#if not EstadosManager.restriccion_distancia_a_grande_activa():
		#return true
	#var grande = HumoresManager.personajes_dicc.get(GlobalEnumIndices.Personaje.GRANDE, null)
	#if not grande:
		#return true
	#var direccion_a_grande = sign(grande.global_position.x - global_position.x)
	#var dist_a_grande = abs(grande.global_position.x - global_position.x)
	#var en_linea_de_vista = tiene_linea_de_vista_a_objetivo(grande)
	#if dist_a_grande <= distancia_seguridad_chico_cauto and input_dir_x == direccion_a_grande and en_linea_de_vista:
		#return false
	#return true


@warning_ignore("shadowed_variable_base_class")
func tiene_linea_de_vista_a_objetivo(objetivo: Node2D, collision_mask: int = -1) -> bool:
	var space_state = get_world_2d().direct_space_state
	var ray_origin = global_position + Vector2(0, -altura_de_ojos)
	var ray_target = objetivo.global_position + Vector2(0, -altura_de_cuerpo)
	var query = PhysicsRayQueryParameters2D.create(ray_origin, ray_target)
	query.exclude = [self, objetivo]
	if collision_mask == -1:
		query.collision_mask = collision_mask_linea_de_vista
	else:
		query.collision_mask = collision_mask
	var result = space_state.intersect_ray(query)
	return result.is_empty()
	
#------------------------Funciones de DEBUG---------------------------------#

func _debug_imprimir_nodos_del_animation_tree():
	if not animation_tree:
		print("DEBUG: AnimationTree no está asignado.")
		return

	print("---------- DEBUG: Búsqueda de Nodos 'Maestro' con Blend Position ----------")
	print("Personaje: ", personaje_tipo)
	# Get the list of all properties, which includes parameter paths.
	var property_list = animation_tree.get_property_list()
	
	var found_nodes = []

	for prop in property_list:
		var path_string = str(prop.name)
		
		if path_string.begins_with("parameters/") and path_string.ends_with("/blend_position"):
			var trimmed_path = path_string.trim_prefix("parameters/")
			var node_name = trimmed_path.get_slice("/", 0)
			
			if node_name.ends_with("_maestro"):# Our convention is that these nodes end with "_maestro".
				if not node_name in found_nodes:
					found_nodes.append(node_name)
					
	if not found_nodes.is_empty():
		print(" -> Nodos 'Maestro' con 'blend_position' encontrados:")
		for node_name in found_nodes:
			print("    -> '%s'" % node_name)
	else:
		print(" -> No se encontraron nodos que coincidan con el patrón '_maestro' y tengan 'blend_position'.")
			
	print("----------------------------------------------------------------------")


func _update_debug_humor_label(nombre_del_humor:String):
	if is_instance_valid(humor_debug_label):
		humor_debug_label.text = nombre_del_humor


# Function to get root BlendSpace1D node names
#func get_root_blendspace_nodes() -> Array[String]:
	#var root_nodes: Array[String] = []
	#
	## Get the root StateMachine from your AnimationTree
	#var root_state_machine = animation_tree.tree_root
	#
	#if root_state_machine is AnimationNodeStateMachine:
		## Get all node names in the root state machine
		#var node_list = root_state_machine.get_state_list()
		#
		#for node_name in node_list:
			#var node = root_state_machine.get_node(node_name)
			### Check if it's a BlendSpace1D
			#if node is AnimationNodeBlendSpace1D:
				#root_nodes.append(node_name)    
	#
	#return root_nodes


func get_root_blendspace_nodes() -> Array[String]:
	var root_nodes: Array[String] = []
	
	if not animation_tree or not animation_tree.tree_root:
		return root_nodes
	
	var root_state_machine = animation_tree.tree_root
	
	if not root_state_machine is AnimationNodeStateMachine:
		return root_nodes
	
	var found_nodes: Array[String] = []	# Collect all node names from transitions
	
	for i in range(root_state_machine.get_transition_count()):
		var from_node = root_state_machine.get_transition_from(i)
		var to_node = root_state_machine.get_transition_to(i)
		
		if from_node not in found_nodes:
			found_nodes.append(from_node)
		if to_node not in found_nodes:
			found_nodes.append(to_node)
	
	# Check which ones are BlendSpace1D
	for node_name in found_nodes:
		if root_state_machine.has_node(node_name):
			var node = root_state_machine.get_node(node_name)
			if node is AnimationNodeBlendSpace1D:
				root_nodes.append(node_name)
	
	return root_nodes

func print_collision_settings():
	print("---- Collision Settings for ", name, " ----")
	print("Root node: ", self)
	print("	Layer: ", get_collision_layer())
	print("	Mask: ", get_collision_mask())
	for child in get_children():
		if child is PhysicsBody2D:
			print("	Child PhysicsBody2D: ", child.name)
			print("		Layer: ", child.get_collision_layer())
			print("		Mask: ", child.get_collision_mask())
		elif child is Area2D:
			print("	Child Area2D: ", child.name)
			print("		Layer: ", child.collision_layer)
			print("		Mask: ", child.collision_mask)


func print_collision_settings_recursive(node = self, indent = ""):
	if node is PhysicsBody2D:
		print(indent, "PhysicsBody2D: ", node.name, " | Layer: ", node.get_collision_layer(), " | Mask: ", node.get_collision_mask())
	elif node is Area2D:
		print(indent, "Area2D: ", node.name, " | Layer: ", node.collision_layer, " | Mask: ", node.collision_mask)
	for child in node.get_children():
		print_collision_settings_recursive(child, indent + "\t")
