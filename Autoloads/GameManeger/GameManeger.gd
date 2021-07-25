extends Node

var read_only = {
	"move" : 0.0}
var globals = {
	"lock_mouse": false,
	"player_move": true,
	"player_look": true,
	"player_shoot": true,
	"player_node": null}

func _ready():
	$PauseScreen.visible = false
func _process(delta):
	if Input.is_action_just_pressed("player_quit"):
		if OS.get_name() == "HTML5": # Ele n sai direito do jogo em htlm, ent decidi só pausar o jogo msm
			get_tree().paused =! get_tree().paused
		else:
			get_tree().quit()
	if Input.is_action_just_pressed("player_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	
	if get_tree().paused: # fiz shaders pararem quando o jogar pausar
		VisualServer.set_shader_time_scale(0)
		$PauseScreen.visible = true
	else:
		VisualServer.set_shader_time_scale(1)
		$PauseScreen.visible = false

func _input(event):
	if globals.lock_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else :
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
