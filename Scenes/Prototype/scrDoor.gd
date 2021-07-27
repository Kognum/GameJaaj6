extends Area2D

export(PackedScene) var ToWhere

export var shouldtrigger = true

var playerhere = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if playerhere:
		if shouldtrigger:
			if Input.is_action_just_pressed("player_interact"):
				SceneChanger.change_scene(ToWhere.resource_path, true)
		else:
			SceneChanger.change_scene(ToWhere.resource_path, false)


func _on_Door_body_entered(body):
		if body.is_in_group("Player"):
			playerhere = true # Replace with function body.


func _on_Door_body_exited(body):
	if body.is_in_group("Player"):
			playerhere = false
	pass # Replace with function body.
