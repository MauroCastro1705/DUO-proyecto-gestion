# area_de_cambio_de_estados.gd - v1.0

@tool
class_name AreaDeCambioDeEstados
extends Area2D

# --- CONFIGURATION ---
enum ModoArea { MODO_HUMOR, MODO_ESTADO }

@export var modo: ModoArea = ModoArea.MODO_HUMOR:
	set(value):
		modo = value
		property_list_changed.emit()

var personaje_disparador: GlobalEnumIndices.Personaje = GlobalEnumIndices.Personaje.NONE
var personaje_objetivo: GlobalEnumIndices.Personaje = GlobalEnumIndices.Personaje.CHICO
var humor_a_aplicar: GlobalEnumIndices.Humor = GlobalEnumIndices.Humor.ENOJADO
var estado_a_aplicar: GlobalEnumIndices.Estado = GlobalEnumIndices.Estado.E_INICIO
var esperar_ambos_personajes: bool = false
var reset_estado_al_cambiar_humor: bool = true
var switch_personaje_al_cambiar: bool = false
var consumible: bool = false

# --- Estado INTERNO ---
var _ya_consumido: bool = false
var _personajes_que_entraron: Array[GlobalEnumIndices.Personaje] = []

# --- SIGNALS ---
signal area_cambio_de_estado_triggered(mode: ModoArea, personaje: Node2D, area: Area2D)

# --- COLORES DE AREA ---
@export var color_chico: Color = Color.BLUE
@export var color_grande: Color = Color.RED
@export var color_estado: Color = Color(0.39, 0.56, 0.11, 0.02) # si modo ESTADO


func _get_property_list():
	var properties = []
	
	# --- AUTOMATIC ENUM STRINGS ---
	# We can access the Autoload, but we need a safety check for the editor.
	var enums = null
	if Engine.has_singleton("GlobalEnumIndices"):
		enums = Engine.get_singleton("GlobalEnumIndices")

	# If the Autoload isn't ready, we provide a fallback so the editor doesn't crash.
	var personajes_string = "NONE,CHICO,GRANDE"
	var humores_string = "AUTO, INACTIVO,NORMAL,BOBO,ENOJADO,MIEDOSO,ALEGRE,CAUTO,ROCKEANDO,TRISTE"
	var estados_string = "NONE,E_INICIO,E_CHICO_ENOJO_INICIAL,E_GRANDE_QUIERE_BIRRA,E_ROCKEAR"

	if enums:
		# If the Autoload is ready, build the strings dynamically.
		personajes_string = ",".join(Array(enums.Personaje.keys()))
		humores_string = ",".join(Array(enums.Humor.keys()))
		estados_string = ",".join(Array(enums.Estado.keys()))

	# --- CONDITIONAL PROPERTIES ---
	if modo == ModoArea.MODO_HUMOR:
		properties.append({
			"name": "personaje_disparador", "type": TYPE_INT, "usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_ENUM, "hint_string": personajes_string
		})
		properties.append({
			"name": "personaje_objetivo", "type": TYPE_INT, "usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_ENUM, "hint_string": personajes_string
		})
		properties.append({
			"name": "humor_a_aplicar", "type": TYPE_INT, "usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_ENUM, "hint_string": humores_string
		})
		properties.append({
			"name": "reset_estado_al_cambiar_humor", "type": TYPE_BOOL, "usage": PROPERTY_USAGE_DEFAULT
		})
		properties.append({
			"name": "switch_personaje_al_cambiar", "type": TYPE_BOOL, "usage": PROPERTY_USAGE_DEFAULT
		})
		properties.append({
			"name": "consumible", "type": TYPE_BOOL, "usage": PROPERTY_USAGE_DEFAULT
		})
		properties.append({
			"name": "esperar_ambos_personajes", "type": TYPE_BOOL, "usage": PROPERTY_USAGE_DEFAULT
		})
	elif modo == ModoArea.MODO_ESTADO:
		properties.append({
			"name": "personaje_disparador", "type": TYPE_INT, "usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_ENUM, "hint_string": personajes_string
		})
		properties.append({
			"name": "estado_a_aplicar", "type": TYPE_INT, "usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_ENUM, "hint_string": estados_string
		})
		properties.append({
			"name": "switch_personaje_al_cambiar", "type": TYPE_BOOL, "usage": PROPERTY_USAGE_DEFAULT
		})
		properties.append({
			"name": "consumible", "type": TYPE_BOOL, "usage": PROPERTY_USAGE_DEFAULT
		})
		properties.append({
			"name": "esperar_ambos_personajes", "type": TYPE_BOOL, "usage": PROPERTY_USAGE_DEFAULT
		})
		
	return properties


func _ready():
	if not Engine.is_editor_hint():
		# At runtime, we can safely wait for the tree to be ready.
		await get_tree().process_frame
		
		_actualizar_color_area()
	else:
		# In the editor, update the color if possible.
		_actualizar_color_area()


func _on_body_entered(body: Node2D) -> void:
	print("Algo entro")
	# Check if the body is a character
	if not "personaje_tipo" in body:
		print("Pero no es un personaje")
		return
	
	print("Y entro un personaje")
	
	# Check si consumible y ya consumida
	if consumible and _ya_consumido:
		print("Pero esta area ya fue CONSUMIDA")
		return
	
	################### If personaje_objetivo is NONE, trigger for any character
	###################if personaje_objetivo == GlobalEnumIndices.Personaje.NONE:
	# Check if the entering character matches our trigger
	if personaje_disparador == GlobalEnumIndices.Personaje.NONE:
		#_ejecutar_accion(body)
		_procesar_entrada_personaje(body)
	else:
		############## Check if the entering character matches our target
		##############if body.personaje_tipo == personaje_objetivo:
		# Check if the entering character matches our trigger
		if body.personaje_tipo == personaje_disparador:
			#_ejecutar_accion(body)
			_procesar_entrada_personaje(body)


func _procesar_entrada_personaje(personaje: Node2D):
	if esperar_ambos_personajes:
		# Add character to the list if not already there
		if not personaje.personaje_tipo in _personajes_que_entraron:
			_personajes_que_entraron.append(personaje.personaje_tipo)
			print("--- DEBUG AREA: Personaje entró: ", GlobalEnumIndices.Personaje.find_key(personaje.personaje_tipo))
		
		# Check if both characters have entered
		if _personajes_que_entraron.size() >= 2:
			print("--- DEBUG AREA: Ambos personajes han entrado, ejecutando acción")
			_ejecutar_accion(personaje)
	else:
		# Normal behavior - execute immediately
		_ejecutar_accion(personaje)


func _ejecutar_accion(personaje: Node2D):
	if modo == ModoArea.MODO_HUMOR:
		#print("--- DEBUG AREA: Forzando humor '%s' en '%s' ---" % [GlobalEnumIndices.Humor.find_key(humor_a_aplicar), GlobalEnumIndices.Personaje.find_key(personaje.personaje_tipo)])
		# In humor mode, personaje_objetivo is who gets the humor changed
		var target_character = personaje_objetivo
		if target_character == GlobalEnumIndices.Personaje.NONE:
			# If NONE, change the humor of whoever entered
			target_character = personaje.personaje_tipo
		
		print("--- DEBUG AREA: Forzando humor '%s' en '%s' ---" % [GlobalEnumIndices.Humor.find_key(humor_a_aplicar), GlobalEnumIndices.Personaje.find_key(target_character)])
		
		# # Reset estado when humor changes bottom-up (if enabled)
		if reset_estado_al_cambiar_humor:
			EstadosManager.forzar_estado(GlobalEnumIndices.Estado.NONE)
		
		##########HumoresManager.set_humor_personaje(personaje.personaje_tipo, humor_a_aplicar)
		HumoresManager.set_humor_personaje(target_character, humor_a_aplicar)
	elif modo == ModoArea.MODO_ESTADO:
		print("--- DEBUG AREA: Forzando estado '%s' ---" % GlobalEnumIndices.Estado.find_key(estado_a_aplicar))
		EstadosManager.forzar_estado(estado_a_aplicar)
	
	# Switch character if enabled
	if switch_personaje_al_cambiar:
		PersonajesSwitchManager.switch_personaje()
	
	# Mark as consumed if consumible
	if consumible:
		_ya_consumido = true
	
	# Emit signal for external event handling
	emit_signal("area_cambio_de_estado_triggered", modo, personaje, self)


func _actualizar_color_area():
	# Skip if we're in the editor
	if Engine.is_editor_hint():
		return
	
	# busco a mano porque Engine.has_singleton falla en runtime
	var global_enums = get_node("/root/GlobalEnumIndices")
	
	if not global_enums:
		return

	if modo == ModoArea.MODO_HUMOR:
		# Set background color based on target character
		if personaje_objetivo == GlobalEnumIndices.Personaje.CHICO:
			_apply_color_to_collision_shape(color_chico)
		elif personaje_objetivo == GlobalEnumIndices.Personaje.GRANDE:
			_apply_color_to_collision_shape(color_grande)
		elif personaje_objetivo == GlobalEnumIndices.Personaje.NONE:
			_apply_color_to_collision_shape(Color.WHITE)  # Default for ANY character
		else:
			_apply_color_to_collision_shape(Color.WHITE)
			
	elif modo == ModoArea.MODO_ESTADO:
		# Set background color for estado mode
		_apply_color_to_collision_shape(color_estado)


func _apply_color_to_collision_shape(color: Color):
	# Find the CollisionShape2D child and apply color
	var collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape:
		# Note: CollisionShape2D doesn't have a direct color property
		# You might want to add a ColorRect or other visual element as a child
		# For now, we'll just print the color change
		print("--- DEBUG AREA: Color aplicado: ", color, " ---")
