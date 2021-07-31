extends Area2D

export(String) var ToWhere
export(bool) var shouldtrigger = true
var playernode : Node2D

export var wheretosendtheplayer : NodePath

var playerhere = false

func _process(delta):
	if playerhere:
		print(playernode.get_child_count())
		if shouldtrigger:
			if Input.is_action_just_pressed("player_interact"):
				playernode.get_child(0)
				pass
		#else:

func _on_Door_body_entered(body):
		if body.is_in_group("Player"):
			playernode = body
			$interactAnm.play("anmInteract")
			playerhere = true # Replace with function body.

func _on_Door_body_exited(body):
	if body.is_in_group("Player"):
			playernode = body
			$interactAnm.play_backwards("anmInteract")
			playerhere = false
	pass # Replace with function body.

func transfernode(whatnode : Node2D, whatparent : Node2D):
	var previousowner = whatnode.get_parent()
	whatparent.add_child(whatnode)
	previousowner.remove_child(whatnode)
	pass
