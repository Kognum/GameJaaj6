extends Area2D

export var bulletspeed = 670.0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += (Vector2.RIGHT*bulletspeed).rotated(rotation) * delta


func _on_Area2D_body_entered(body):
	if body.name.begins_with("inimigo"):
		print("u killed the bad guy!!!")
	
	queue_free()
	pass # Replace with function body.
