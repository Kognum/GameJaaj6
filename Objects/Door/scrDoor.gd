extends Area2D

export(PackedScene) var ToWhere
export(bool) var shouldtrigger = true

var playerhere = false

func _process(delta):
	if playerhere:
		if shouldtrigger:
			if Input.is_action_just_pressed("player_interact"):
				SceneChanger.change_scene(ToWhere.resource_path, true)
		else:
			SceneChanger.change_scene(ToWhere.resource_path, false)

func _on_Door_body_entered(body):
		if body.is_in_group("Player"):
			$interactAnm.play("anmInteract")
			playerhere = true # Replace with function body.

func _on_Door_body_exited(body):
	if body.is_in_group("Player"):
			$interactAnm.play_backwards("anmInteract")
			playerhere = false
	pass # Replace with function body.
