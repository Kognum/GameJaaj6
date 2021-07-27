extends Node2D

var continue_to = "res://Scenes/Prototype/scnPrototype.tscn"



func _on_btnContinue_released():
	SceneChanger.change_scene(continue_to)
