extends Area2D

export var ToWhere : NodePath
onready var ToWherenode = get_node(ToWhere)
export(bool) var shouldtrigger = true
var playernode : Node2D

export var wheretosendtheplayer : Vector2

var playerhere = false

func _process(delta):
	if playerhere:
		if shouldtrigger:
			if Input.is_action_just_pressed("player_interact"):
				playernode.global_position = ToWherenode.global_position
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
