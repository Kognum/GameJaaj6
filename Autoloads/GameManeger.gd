extends Node

var read_only = {
	"move" : 0.0}
var globals = {
	"lock_mouse": false,
	"player_move": true,
	"player_look": true,
	"player_shoot": true}

func _process(delta):
	if Input.is_action_just_pressed("player_quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("player_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func _input(event):
	if globals.lock_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else :
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
