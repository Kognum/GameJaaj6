extends Control

var clicks := 0

func _ready():
	GameManeger.globals.lock_mouse = false
	$musMenu.pitch_scale = 2.7

func _on_btnClick_released():
	$Page1/btnClick.queue_free()
	GameManeger.globals.lock_mouse = true
	$Page2.visible = true
	$musMenu.pitch_scale = 1.2
func _on_btnClick2_released():
	$Page2/btnClick2.queue_free()
	$Page3.visible = true
	$musMenu.pitch_scale = 0.8
func _on_btnClick3_released():
	$Page3/btnClick3.queue_free()
	$Page4.visible = true
	$musMenu.pitch_scale = 1
func _on_btnClick4_released():
	SceneChanger.change_scene("res://Scenes/Prototype/scnPrototype.tscn")
