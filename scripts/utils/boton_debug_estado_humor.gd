# boton_debug_estado_humor.gd - v1.1 (Final, Automatic Version)
# A reusable debug button to force either a specific Humor on a character
# or a specific global Estado. Automatically populates dropdowns from GlobalEnumIndices.
@tool
class_name BotonDebugEstadoHumor
extends Button

# --- CONFIGURATION ---
enum ModoBoton { MODO_HUMOR, MODO_ESTADO }

@export var modo: ModoBoton = ModoBoton.MODO_HUMOR:
	set(value):
		modo = value
		property_list_changed.emit()

# --- Properties are now defined inside _get_property_list ---
var personaje_objetivo: GlobalEnumIndices.Personaje = GlobalEnumIndices.Personaje.CHICO
var humor_a_aplicar: GlobalEnumIndices.Humor = GlobalEnumIndices.Humor.ENOJADO
var estado_a_aplicar: GlobalEnumIndices.Estado = GlobalEnumIndices.Estado.E_INICIO

# --- COLORES DE BOTONES ---
@export var color_chico: Color = Color.BLUE
@export var color_grande: Color = Color.RED
@export var color_estado: Color = Color.GREEN  # si modo ESTADO


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
	if modo == ModoBoton.MODO_HUMOR:
		properties.append({
			"name": "personaje_objetivo", "type": TYPE_INT, "usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_ENUM, "hint_string": personajes_string
		})
		properties.append({
			"name": "humor_a_aplicar", "type": TYPE_INT, "usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_ENUM, "hint_string": humores_string
		})
	elif modo == ModoBoton.MODO_ESTADO:
		properties.append({
			"name": "estado_a_aplicar", "type": TYPE_INT, "usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_ENUM, "hint_string": estados_string
		})
		
	return properties


func _ready():
	self.pressed.connect(_on_button_pressed)
	if not Engine.is_editor_hint():
		# At runtime, we can safely wait for the tree to be ready.
		await get_tree().process_frame
		
		_actualizar_texto_boton()
	else:
		# In the editor, update the text if possible.
		_actualizar_texto_boton()


func _on_button_pressed():
	if modo == ModoBoton.MODO_HUMOR:
		print("--- DEBUG BUTTON: Forzando humor '%s' en '%s' ---" % [GlobalEnumIndices.Humor.find_key(humor_a_aplicar), GlobalEnumIndices.Personaje.find_key(personaje_objetivo)])
		HumoresManager.set_humor_personaje(personaje_objetivo, humor_a_aplicar)
	elif modo == ModoBoton.MODO_ESTADO:
		print("--- DEBUG BUTTON: Forzando estado '%s' ---" % GlobalEnumIndices.Estado.find_key(estado_a_aplicar))
		EstadosManager.forzar_estado(estado_a_aplicar)


func _actualizar_texto_boton():
	# Skip if we're in the editor
	if Engine.is_editor_hint():
		return
	#default para editor
	#if not Engine.has_singleton("GlobalEnumIndices"):
		#text = "Cargando..."
		#return
	
	# busco a mano porque Engine.has_singleton falla en runtime
	var global_enums = get_node("/root/GlobalEnumIndices")
	
	if not global_enums:
		text = "Cargando..."
		return

	if modo == ModoBoton.MODO_HUMOR:
		var char_name = GlobalEnumIndices.Personaje.find_key(personaje_objetivo)
		var humor_name = GlobalEnumIndices.Humor.find_key(humor_a_aplicar)
		text = "%s -> %s" % [char_name, humor_name]
		
		# Set background color based on character
		if personaje_objetivo == GlobalEnumIndices.Personaje.CHICO:
			self_modulate = color_chico
		elif personaje_objetivo == GlobalEnumIndices.Personaje.GRANDE:
			self_modulate = color_grande
		else:
			self_modulate = Color.WHITE  # Default for NONE
			
		
	elif modo == ModoBoton.MODO_ESTADO:
		var estado_name = GlobalEnumIndices.Estado.find_key(estado_a_aplicar)
		text = "ESTADO: %s" % [estado_name]
		
		# Set background color for estado mode
		self_modulate = color_estado
