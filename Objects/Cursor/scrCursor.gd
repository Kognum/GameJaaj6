extends Node2D

func _process(delta):
	position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("player_secondary"):
		$cursorAnm.play("anmSpin")
		yield($cursorAnm, "animation_finished")
		$cursorAnm.play("anmIdle")
