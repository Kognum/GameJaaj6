extends Sprite

export var bulletspeed = 250.0

export var rotation_to_inherit : float
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _move(_delta):
	self.move_and_collide(rotation_to_inherit)



func _on_Area2D_body_entered(body):
	if body.name.begins_with("inimigo"):
		print("u killed the bad guy!!!")
	
	queue_free()
	pass # Replace with function body.
