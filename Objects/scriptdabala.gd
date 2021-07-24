extends Area2D

export var bulletspeed = 1150.0

export var basetilt = 0.05

var slighttilt : float
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	slighttilt = rand_range(-basetilt, basetilt)
	self.global_rotation = global_rotation + slighttilt
	print(slighttilt)
	pass # Replace with function body.

func _on_Area2D_body_entered(body):
	if body.is_in_group("inimigos"):
		print("u killed deh enemymm")
	
	queue_free()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position += (Vector2.RIGHT*bulletspeed).rotated(rotation) * _delta

