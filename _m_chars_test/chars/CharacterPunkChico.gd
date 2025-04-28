extends CharacterPunkBase
class_name CharacterPunkChico

@export_group("Settings CHICO")


func _ready() -> void:
	super._ready() # IMPORTANT!
	# Initialize Character B specific things
	

func _physics_process(delta: float) -> void: # Added type hint and -> void
	super._physics_process(delta) # Use base movement when not aiming
