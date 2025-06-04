extends RigidBody2D

func _physics_process(delta):
	if Input.is_action_pressed("empujar"):
		apply_force(Vector2(100, 0))
		
	elif Input.is_action_just_released("empujar"):
		linear_velocity = Vector2.ZERO
		angular_velocity = 0
		
	#else:
		#linear_velocity = Vector2.ZERO
		#angular_velocity = 0
		
	#este genera que las plataformas caigan muy lento ya que aplica a todo movimiento
	#que se ejecute mientras no se ejecute la accion "empujar"
	
	
		
