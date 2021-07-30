extends Control

func _ready():
	change = false
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode != KEY_ESCAPE:
			_on_TouchScreenButton_released()

var change = false
func change_scene():
	if change:
		SceneChanger.change_scene("res://Scenes/Prototype/scnPrototype.tscn", true)

func _on_TouchScreenButton_released():
	change = true
	$introAnm.play_backwards("anmDefault")
