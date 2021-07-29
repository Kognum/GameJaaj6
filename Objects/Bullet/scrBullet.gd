extends Area2D

export(float) var bulletspeed := 2500.0
export(float) var basetilt := 0.05
export(int) var damage := 2
enum bullet_types {
	SHOTGUN,
	SNIPER,
	METRALHADORA}
export(bullet_types) var bullet_type = bullet_types.SHOTGUN

var slighttilt : float

func _ready():
	slighttilt = rand_range(-basetilt, basetilt)
	self.global_rotation = global_rotation + slighttilt
	
	match bullet_type:
		bullet_types.METRALHADORA:
			$sprBullet.texture = load("res://Objects/Bullet/bala_metralhadora.png")
		bullet_types.SNIPER:
			$sprBullet.texture = load("res://Objects/Bullet/bala_sniper.png")
		bullet_types.SHOTGUN:
			$sprBullet.texture = load("res://Objects/Bullet/bala_shotgun.png")
func _process(_delta):
	position += (Vector2.RIGHT * bulletspeed).rotated(rotation) * _delta

func _on_Area2D_body_entered(body):
	if is_in_group("ShootByPlayer"):
		if body.is_in_group("Enemy"):
			body.health -= damage
		if !body.is_in_group("Player"):
			queue_free()
	
	elif is_in_group("ShootByEnemy"):
		if body.is_in_group("Player"):
			body.take_damage(damage)
		if !body.is_in_group("Enemy"):
			queue_free()
