extends Area2D

export(float) var bulletspeed := 2500.0
export(float) var basetilt := 0.05
export(int) var damage := 2

var slighttilt : float

func _ready():
	slighttilt = rand_range(-basetilt, basetilt)
	self.global_rotation = global_rotation + slighttilt
func _process(delta):
	position += (Vector2.RIGHT * bulletspeed).rotated(rotation) * delta

func _on_Area2D_body_entered(body):
	if is_in_group("ShootByPlayer"):
		if body.is_in_group("Enemy"):
			body.health -= damage
		if !body.is_in_group("Player"):
			queue_free()
	elif is_in_group("ShootByEnemy"):
		if body.is_in_group("Player"):
			body.health -= damage
		if !body.is_in_group("Enemy"):
			queue_free()
