extends Node2D
@onready var animated_sprite_2d_4: AnimatedSprite2D = $CanvasLayer/AnimatedSprite2D4
@onready var animated_sprite_2d_3: AnimatedSprite2D = $CanvasLayer/AnimatedSprite2D3
@onready var animated_sprite_2d_2: AnimatedSprite2D = $CanvasLayer/AnimatedSprite2D2
@onready var animated_sprite_2d: AnimatedSprite2D = $CanvasLayer/AnimatedSprite2D
@onready var animated_sprite_2d_5: AnimatedSprite2D = $CanvasLayer/AnimatedSprite2D5


func _ready() -> void:
	animated_sprite_2d_4.play()
	animated_sprite_2d_5.play()
	animated_sprite_2d_3.play()
	animated_sprite_2d_2.play()
	animated_sprite_2d.play()
	
