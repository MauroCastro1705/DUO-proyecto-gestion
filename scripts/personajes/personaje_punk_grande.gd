# personaje_punk_grande.gd v1.2 con hombros

class_name PersonajePunkGrande
extends PersonajePunkBase

var objeto_cargado_en_hombros: Node2D = null
var ultimo_movimiento_delta: Vector2 = Vector2.ZERO
@export var hombros_plataforma_collision: CollisionShape2D # vincular a colision de hombros

func _ready():
	super._ready() # primero la parent ready function, o sea de punk_base
	_set_hombros_plataforma_activa(false)

func _physics_process(delta: float):
	var posicion_antes_de_mover = global_position
	
	super._physics_process(delta) # physics_process de punk base, todo el mov y logica
	
	ultimo_movimiento_delta = global_position - posicion_antes_de_mover

# override de aplicar_humor_definicion en base para llamar actualizar estado hombros
func aplicar_humor_definicion(nueva_humor_def: HumorDefinicion):
	await super.aplicar_humor_definicion(nueva_humor_def) # espera que corra todo el metodo de la clase parent
	
	print("Llamando a Actualizar_estado_hombros")
	actualizar_estado_hombros()


# --- Mecanica Hombros ( lado del portador ) - La invoca Chico cuando cae en hombros --
func _montar_en_hombros(objeto_a_cargar: Node2D):
	if not puede_realizar_accion(GlobalEnumIndices.MECANICA_HOMBROS) or is_instance_valid(objeto_cargado_en_hombros):
		return
		
	# Para no duplicar si ya esta cargando algo:
	#if is_instance_valid(objeto_cargado_en_hombros):
		#return

	print("Grande: Portando a '%s' en hombros." % objeto_a_cargar.name)
	objeto_cargado_en_hombros = objeto_a_cargar
	
	# Seteo en el que es llevado que
	if objeto_a_cargar.has_method("set_hombros_portador"):
		objeto_a_cargar.set_hombros_portador(self)


# Lo llama Chico cuando desmomta
func _notificar_hombros_desmonte():
	if is_instance_valid(objeto_cargado_en_hombros):
		print("Grande: '%s' se ha desmontado." % objeto_cargado_en_hombros.name)
	objeto_cargado_en_hombros = null


func actualizar_estado_hombros():
	print(GlobalEnumIndices.MECANICA_HOMBROS)
	
	if puede_realizar_accion(GlobalEnumIndices.MECANICA_HOMBROS):
		print("Activando Hombros...")
		_set_hombros_plataforma_activa(true)
	else:
		_set_hombros_plataforma_activa(false)
		# Si un estado desactiva hombros aca se fuerrza el desmonte
		if is_instance_valid(objeto_cargado_en_hombros):
			if objeto_cargado_en_hombros.has_method("forzar_desmontar_hombros"):
				objeto_cargado_en_hombros.forzar_desmontar_hombros()


func _set_hombros_plataforma_activa(esta_activa: bool): # Mec Hombros on/off
	#hombros_plataforma_collision.disabled = not esta_activa
	#print("Grande: Plataforma de hombros " + ("activada" if esta_activa else "desactivada"))
	# We will check if the state is actually changing to avoid log spam.
	var _is_currently_disabled = hombros_plataforma_collision.disabled
	var should_be_disabled = not esta_activa
	
	#if is_currently_disabled != should_be_disabled:
	print("--- DEBUG GRANDE: Cambiando estado de hombros. Debe estar deshabilitado: %s ---" % str(should_be_disabled))
	hombros_plataforma_collision.set_deferred("disabled", should_be_disabled)
	print(hombros_plataforma_collision.disabled)
