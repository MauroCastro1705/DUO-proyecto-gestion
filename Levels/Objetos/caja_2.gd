extends RigidBody2D
@onready var sprite = $Sprite2D
@onready var shader_material := sprite.material as ShaderMaterial
@onready var timer = $Timer

func _ready() -> void:
	var unique_material = sprite.material.duplicate()
	sprite.material = unique_material
	shader_material = unique_material as ShaderMaterial

func _on_timer_timeout() -> void:
	shader_material.set_shader_parameter("show_outline", false)


func _on_prender_shader_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		timer.start()
		shader_material.set_shader_parameter("show_outline", true)
