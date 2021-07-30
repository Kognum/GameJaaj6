extends Node2D

func _process(delta):
	position = get_global_mouse_position()
	
	if GameManager.globals.changing_cycle:
		$cursorAnm.play("anmSpin")
		yield($cursorAnm, "animation_finished")
		$cursorAnm.play("anmIdle")
		GameManager.globals.changing_cycle = false
