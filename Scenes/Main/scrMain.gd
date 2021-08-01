extends Node2D

func _ready():
	GameManager.globals.player_move = false
	GameManager.globals.player_look = false
	GameManager.globals.player_shoot = false
func screen_shake(intensity :float = 2.5):
	GameManager.camera.startshaking(intensity, 12, 0.3)
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

func next_cycle():
	$mainAnm.play("anmStart")
	$"Rooms/01/Objects/partclesSplash".emitting = false
	GameManager.cycle += 1
	for room in $Rooms.get_children():
		if not room.name == "01":
			room.reset()
			room.player_got_here = false

func _process(delta):
	match GameManager.cycle:
		0:
			$"Rooms/01/Sprites/Capsule".visible = false
			$"Rooms/01/Sprites/Capsule2".visible = false
			$"Rooms/01/Sprites/Capsule3".visible = false
		1:
			$"Rooms/01/Sprites/Capsule".visible = true
			$"Rooms/01/Sprites/Capsule2".visible = false
			$"Rooms/01/Sprites/Capsule3".visible = false
		2:
			$"Rooms/01/Sprites/Capsule".visible = true
			$"Rooms/01/Sprites/Capsule2".visible = true
			$"Rooms/01/Sprites/Capsule3".visible = false
		3:
			$"Rooms/01/Sprites/Capsule".visible = true
			$"Rooms/01/Sprites/Capsule2".visible = true
			$"Rooms/01/Sprites/Capsule3".visible = true
	
	if GameManager.globals.player_node.timer <= 0:
		GameManager.globals.player_node.timer = 0
		GameManager.globals.player_node.health = 3
		GameManager.cycle = 0
		$mainAnm.play("anmBadEnding")
	if GameManager.brokas == 4:
		GameManager.globals.player_node.health = 3
		GameManager.cycle = 0
		$mainAnm.play("anmGoodEnding")

func _on_mainAnm_animation_finished(anim_name):
	if anim_name == "anmBadEnding":
		SceneChanger.change_scene("res://Scenes/GameOver/scnCreditsBad.tscn", false)
	elif anim_name == "anmGoodEnding":
		SceneChanger.change_scene("res://Scenes/GameOver/scnCreditsgood.tscn", false)
