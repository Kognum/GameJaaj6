extends Node2D

enum cursors {
	DEFAULT,
	AIM}
var cursor = cursors.AIM

func _ready():
	position = Vector2(-50, -50)
	rotation_degrees = 0
	
	match cursor:
		cursors.DEFAULT:
			$sprCursor.region_rect = Rect2(50.5, 60.88, 254.25, 289.975)
			$sprCursor.position = Vector2(16.046, 22.181)
		cursors.AIM:
			$sprCursor.region_rect = Rect2(364.125, 26.125, 398.25, 405)
			$sprCursor.position = Vector2(0, 0)
func _process(delta):
	#position = get_global_mouse_position()
	
	if GameManager.globals.changing_cycle:
		$cursorAnm.play("anmSpin")
		yield($cursorAnm, "animation_finished")
		$cursorAnm.play("anmIdle")
		GameManager.globals.changing_cycle = false
