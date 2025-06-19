extends RigidBody2D
@onready var sprite := $CajaLiviana2
@onready var shader_material := sprite.material as ShaderMaterial
@onready var texto = $Label
@onready var timer = $Timer
@onready var input := $input

func _ready() -> void:
	input.visible = false
	texto.visible = false
	var unique_material = sprite.material.duplicate()
	sprite.material = unique_material
	shader_material = unique_material as ShaderMaterial

func _on_prender_shader_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		timer.start()
		_mostrar_input()

func _on_prender_shader_body_exited(_body: Node2D) -> void:
	pass

		
func _mostrar_input():
	shader_material.set_shader_parameter("show_outline", true)
	texto.visible = true
	input.visible = true

func _esconder_input():
	shader_material.set_shader_parameter("show_outline", false)
	texto.visible = false
	input.visible = false

func _on_timer_timeout() -> void:
	_esconder_input()
