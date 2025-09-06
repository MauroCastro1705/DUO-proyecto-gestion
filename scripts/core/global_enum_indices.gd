# global_enum_indices.gd - v1.0

extends Node

enum Personaje {
	NONE, #0
	CHICO, #1
	GRANDE #2
}

enum Humor {
	AUTO, #0
	INACTIVO, #1
	NORMAL, #2
	BOBO, #3
	ENOJADO, #4
	MIEDOSO, #5
	ALEGRE, #6
	CAUTO, #7
	ROCKEANDO, #8
	TRISTE, #9
}

enum Estado {
	NONE, #0
	E_INICIO, #1
	E_CHICO_ENOJO_INICIAL, #2
	E_GRANDE_QUIERE_BIRRA, #3
	E_ROCKEAR, #4
}

const MECANICA_CAMBIO_PERSONAJE := "mecanica_cambio_personaje"
const MECANICA_HOMBROS := "mecanica_hombros"
const MECANICA_SALTO := "mecanica_salto"
const EMPUJAR_PESADO := "empujar_pesado"
const EMPUJAR_LIVIANO := "empujar_liviano"

enum RestriccionMovimiento {
	MOVIMIENTO_LIBRE, #0
	NO_ACERCARSE_A_OTRO, #1
	NO_RETROCEDER, #2
	CHICO_NO_ACERCARSE_A_GRANDE, #3
	GRANDE_NO_ACERCARSE_A_CHICO, #4
	# ...otrosss
}
