extends Area2D

export var bulletspeed = 1150.0
export var basetilt = 0.05

var slighttilt : float

func _ready():
	slighttilt = rand_range(-basetilt, basetilt)
	self.global_rotation = global_rotation + slighttilt
func _process(delta):
	position += (Vector2.RIGHT * bulletspeed).rotated(rotation) * delta

func _on_Area2D_body_entered(body):
	if body.is_in_group("Enemy"):
		body.health -= 2
		
	if !body.is_in_group("Player"):
		queue_free()
