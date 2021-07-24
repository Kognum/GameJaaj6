extends Area2D

export var bulletspeed = 1150.0

export var basetilt = 0.05

var slighttilt : float

var rng = RandomNumberGenerator.new()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	slighttilt = rng.randf_range(-basetilt, basetilt)
	self.global_rotation = global_rotation + slighttilt
	print(slighttilt)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += (Vector2.RIGHT*bulletspeed).rotated(rotation) * delta


func _on_Area2D_body_entered(body):
	if body.name.begins_with("inimigo"):
		print("u killed the bad guy!!!")
	
	queue_free()
	pass # Replace with function body.
