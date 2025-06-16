extends Node
#GENERALES

var seguir_a_laura := false

#EMOCIONES-GORDO----------
var gordo_mood_normal:bool = true
var gordo_mood_bobo:bool = false
var gordo_mood_triste:bool = false
var gordo_mood_rockeando:bool = false
var gordo_mood_enojado:bool = false

var gordo_texto_mood_enojado:String = "estoy enojado"
var gordo_texto_mood_bobo: String = "estoy bobo"
var gordo_texto_mood_triste:String = "estoy triste"
var gordo_texto_mood_rockeado:String = "estoy rockeando"

func get_humor_bruno() -> String:
	var estados = {
		"normal": gordo_mood_normal,
		"bobo": gordo_mood_bobo,
		"triste": gordo_mood_triste,
		"rockeando": gordo_mood_rockeando
	}

	for estado in estados.keys():
		if estados[estado]:
			return estado
	
	return "ninguno"


#EMOCIONES-LAURA----------
var laura_mood_normal:bool = true
var laura_mood_enojado:bool = false
var laura_mood_ignorando:bool = false
var laura_mood_rockeando:bool = false
var laura_mood_cauta:bool = false

var laura_mood_cauta_texto :String = "estoy cauta"
var laura_texto_mood_rockeado:String = "estoy rockeando"
var laura_texto_mood_ignorando:String = "estoy triste"
var laura_texto_mood_enojado:String = "estoy enojado"
#EMOCIONES-COMPARTIDAS----------

var e_grande_quiere_birra:bool = false
#FUNCIONES GENERALES

func _physics_process(_delta: float) -> void:
	if laura_mood_cauta and gordo_mood_enojado:
		e_grande_quiere_birra = true
	else:
		e_grande_quiere_birra = false
	
	
