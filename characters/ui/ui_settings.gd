extends CanvasLayer

signal jump_height_changed(new_height)

@onready var jump_text_edit = $GDEsaltoFuerza/GDEsaltoFuerza_edit as LineEdit
@onready var jump_slider = $GDEsaltoFuerza/GDEsaltoFuerza_slider as Slider

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_instance_valid(jump_text_edit):
		jump_text_edit.text_changed.connect(_on_jump_text_changed)
	if is_instance_valid(jump_slider):
		jump_slider.value_changed.connect(_on_jump_slider_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void: pass


func _on_jump_text_changed(new_text):
	if new_text.is_valid_float():
		var new_jump = float(new_text)
		if is_valid_jump_value(new_jump):
			emit_signal("jump_height_changed", new_jump)
		else:
			print("Invalid jump height entered in text box (out of range).")
			# Optionally provide visual feedback in the UI
	else:
		print("Invalid input in jump height text box (not a number).")
		# Optionally provide visual feedback in the UI

func _on_jump_slider_changed(value):
	emit_signal("jump_height_changed", value)

func is_valid_jump_value(value):
	return is_finite(value) and value <= 0 # Adjust constraints as needed
