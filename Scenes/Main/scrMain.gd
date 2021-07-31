extends Node2D

func _ready():
	GameManager.globals.player_move = false
	GameManager.globals.player_look = false
	GameManager.globals.player_shoot = false
func screen_shake():
	GameManager.camera.startshaking(2.5, 12, 0.3)
func activate_player():
	GameManager.globals.player_move = true
	GameManager.globals.player_look = true
	GameManager.globals.player_shoot = true
	$oPlayer.get_node("cycleAnimation").play("amnCycle")
	$Audio.start_maneger()
func slow_down():
	Engine.time_scale = 0.3
func slow_up():
	Engine.time_scale = 1
