extends Camera2D


var moveto : Vector2

export var speed : float


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_LEFT):
		moveto = Vector2.LEFT
	if Input.is_key_pressed(KEY_RIGHT):
		moveto = Vector2.RIGHT
	if Input.is_key_pressed(KEY_UP):
		moveto = Vector2.UP
	if Input.is_key_pressed(KEY_DOWN):
		moveto = Vector2.DOWN
	global_position += moveto * speed
