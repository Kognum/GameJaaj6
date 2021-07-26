extends CanvasLayer

onready var anm = $scAnm

func change_scene(scene_path :String):
	GameManager.globals.player_move = false
	anm.play("anmFade")
	yield(anm, "animation_finished")
	get_tree().change_scene(scene_path)
	yield(get_tree().create_timer(.2), "timeout")
	anm.play_backwards("anmFade")
	yield(anm, "animation_finished")
	GameManager.globals.player_move = true
