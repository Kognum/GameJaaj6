extends Area2D

export(String) var ToWhere
export(bool) var shouldtrigger = true

export var wheretosendtheplayer = Vector2.ZERO

var playerhere = false

func _process(delta):
	if playerhere:
		GameManager.playerdoorexitloc = wheretosendtheplayer
		if shouldtrigger:
			if Input.is_action_just_pressed("player_interact"):
				SceneChanger.change_scene(ToWhere, true)
		else:
			SceneChanger.change_scene(ToWhere, false)

func _on_Door_body_entered(body):
		if body.is_in_group("Player"):
			$interactAnm.play("anmInteract")
			playerhere = true # Replace with function body.

func _on_Door_body_exited(body):
	if body.is_in_group("Player"):
			$interactAnm.play_backwards("anmInteract")
			playerhere = false
	pass # Replace with function body.
