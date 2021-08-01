extends Node

var read_only = {
	"move" : 0.0}
var globals = {
	"lock_mouse": false,
	"player_move": true,
	"player_look": true,
	"player_shoot": true,
	"player_node": null,
	"changing_cycle": false}

var cycle := 0
var camera = null
var game_paused = false

func _ready():
	$PauseScreen.visible = false
func _process(delta):
	if Input.is_action_just_pressed("player_quit"):
		if not OS.get_name() == "HTML5":
			get_tree().paused =! get_tree().paused
			game_paused =! game_paused
		else:
			get_tree().quit()
	if Input.is_action_just_pressed("player_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	
	if get_tree().paused:
		VisualServer.set_shader_time_scale(0)
		$PauseScreen.visible = true
	else:
		VisualServer.set_shader_time_scale(1)
		$PauseScreen.visible = false
	
	$PauseScreen/Text.visible = game_paused
	$PauseScreen/Margin.visible = game_paused
	if game_paused and Input.is_action_just_pressed("player_menu"):
		SceneChanger.change_scene("res://Scenes/Menu/scnMenu.tscn", true)
		get_tree().paused = false
		game_paused = false
		
	if globals.player_node != null:
		if globals.player_node.timer <= 0:
			SceneChanger.change_scene("res://Scenes/GameOver/scnGameOver.tscn")

func _input(event):
	if globals.lock_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else :
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
