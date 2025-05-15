# character_punk_grande.gd
extends CharacterPunkBase
class_name CharacterPunkGrande


@export_group("Settings GRANDE")
#@export var push_power: float = 10.0 # Example unique stat
#@export var push_area_node_path: NodePath = ^""

#@onready var push_area: Area2D = get_node_or_null(push_area_node_path) as Area2D
# ... other nodes specific to Character Punk Grande



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready() # IMPORTANT: Call the parent's _ready function!


func _physics_process(delta) -> void:
	super._physics_process(delta) # IMPORTANT: Call the parent's physics process!



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
