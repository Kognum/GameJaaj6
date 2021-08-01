extends KinematicBody2D

onready var Player = GameManager.globals.player_node

export(Texture) var sprite

enum state_machine {
	WAITING,
	HUNTING,
	SHOOTING,
	RUNAWAY,
	DEAD}

enum attack_types {
	TANQUE}

export(attack_types) var attack_type = attack_types.TANQUE

export(state_machine) var default_state = state_machine.WAITING
onready var currect_state = default_state

export(int) var speed = 170

export(int) var max_health = 80
export(int) var runaway_health = 46
onready var health = max_health

func _init():
	if not sprite == null:
		$pivot/enemySprite.texture = sprite
func _ready():
	$pivot/enemySprite.material = $pivot/enemySprite.material.duplicate()
func _process(delta):
	match currect_state:
		state_machine.HUNTING:
			shoot()
		state_machine.RUNAWAY:
			shoot()
		state_machine.SHOOTING:
			shoot()
func _physics_process(delta):
	if health <= 0:
		currect_state = state_machine.DEAD
	
	correct_positions()
	match currect_state:
		state_machine.WAITING:
			aply_gravity(delta)
			$enemyAnm.play("anmWaiting")
			if find_player():
				$alertAnm.play("anmAlert")
				if is_health_low():
					currect_state = state_machine.RUNAWAY
				else:
					currect_state = state_machine.HUNTING
					$sfxNoticed.play()
		state_machine.HUNTING:
			hunt(delta)
				
			if not find_player():
				currect_state = state_machine.WAITING
			if is_health_low():
				currect_state = state_machine.RUNAWAY
		state_machine.RUNAWAY:
			$enemyAnm.play("anmHunting", -1, 1.2)
			$EnemySprint.emitting = true
			runaway(delta)
			eye_reach = 600
			if not find_player():
				currect_state = state_machine.WAITING
		state_machine.DEAD:
			$EnemySprint.emitting = false
			$enemyAnm.play("anmDead")
			$enemyHitbox/enemyCol.disabled = true
			$enemyHitbox2/enemyCol2.disabled = true
			if not is_on_floor():
				aply_gravity(delta)
			else:
				$sfxDie.play()
				$enemyCol.disabled = true
				
				get_tree().paused = true
				$deathBlood.visible = true
				set_physics_process(false)
				yield(get_tree().create_timer(0.2), "timeout")
				set_physics_process(true)
				get_tree().paused = false
				$deathBlood.visible = false
				
				GameManager.info.enemies += 1
				
				set_physics_process(false)

func is_health_low() -> bool:
	if health <= runaway_health:
		return true
	else:
		return false

export(int) var eye_reach = 240
func find_player(vision := 600, eyeReach := -1) -> bool:
	if eyeReach == -1:
		eyeReach = eye_reach
	vision = vision + (eyeReach / 4)
	
	var eye_center = get_global_position()
	var eye_top = eye_center + Vector2(0, -eyeReach)
	var eye_left = eye_center + Vector2(-eyeReach, 0)
	var eye_right = eye_center + Vector2(eyeReach, 0)

	var player_pos = Player.get_global_position()
	var player_extents = Player.get_node("Hitbox/playerHitbox").shape.extents - Vector2(1, 1)
	var top_left = player_pos + Vector2(-player_extents.x, -player_extents.y)
	var top_right = player_pos + Vector2(player_extents.x, -player_extents.y)
	var bottom_left = player_pos + Vector2(-player_extents.x, player_extents.y)
	var bottom_right = player_pos + Vector2(player_extents.x, player_extents.y)

	var space_state = get_world_2d().direct_space_state

	for eye in [eye_center, eye_top, eye_left, eye_right]:
		for corner in [top_left, top_right, bottom_left, bottom_right]:
			if (corner - eye).length() > vision:
				continue
			var collision = space_state.intersect_ray(eye, corner, [], 2) # collision mask = sum of 2^(collision layers) - e.g 2^0 + 2^3 = 9
			if collision and collision.collider.name == "oPlayer":
				return true
	return false

export(int) var react_time = 500
export(int) var target_player_dist = 100
export(int) var jump_heigh = 0 
export(int) var avoid_distance = 20
var vel = Vector2(0, 0)
var grav = 1800
var max_grav = 3000
var dir = 0
var next_dir = 0
var next_dir_time = 0
var next_jump_time = -1
func hunt(delta):
	if not find_player(600, avoid_distance):
		$enemyAnm.play("anmHunting")
		if Player.position.x < position.x - target_player_dist:
			set_dir(-1)
			$pivot/enemySprite.scale.x = 0.305
		elif Player.position.x > position.x + target_player_dist:
			set_dir(1)
			$pivot/enemySprite.scale.x = -0.305
		else:
			set_dir(0)
	else:
		set_dir(0)
	
	if OS.get_ticks_msec() > next_dir_time:
		dir = next_dir
	
	if OS.get_ticks_msec() > next_jump_time and next_jump_time != -1 and is_on_floor():
		if Player.position.y < position.y - 64:
			vel.y = -jump_heigh
		next_jump_time = -1
	
	vel.x = dir * speed
	
	if Player.position.y < position.y - 64 and next_jump_time == -1 and true:
		next_jump_time = OS.get_ticks_msec() + react_time
	
	vel.y += grav * delta;
	if vel.y > max_grav:
		vel.y = max_grav
	
	if is_on_floor() and vel.y > 0:
		vel.y = 0
	
	vel = move_and_slide(vel, Vector2(0, -1))

func runaway(delta):
	if Player.position.x < position.x - target_player_dist and true:
		set_dir(1)
		$pivot/enemySprite.scale.x = 0.305
	elif Player.position.x > position.x + target_player_dist and true:
		set_dir(-1)
		$pivot/enemySprite.scale.x = -0.305
	else:
		set_dir(0)

	if OS.get_ticks_msec() > next_dir_time:
		dir = next_dir

	if OS.get_ticks_msec() > next_jump_time and next_jump_time != -1 and is_on_floor():
		if Player.position.y < position.y - 64 and true:
			vel.y = -jump_heigh
		next_jump_time = -1

	vel.x = dir * speed

	if Player.position.y < position.y - 64 and next_jump_time == -1 and true:
		next_jump_time = OS.get_ticks_msec() + react_time

	vel.y += grav * delta;
	if vel.y > max_grav:
		vel.y = max_grav

	if is_on_floor() and vel.y > 0:
		vel.y = 0

	vel = move_and_slide(vel, Vector2(0, -1))

func set_dir(target_dir):
	if next_dir != target_dir:
		next_dir = target_dir
		next_dir_time = OS.get_ticks_msec() + react_time
func aply_gravity(delta):
	vel.y += grav * delta;
	if vel.y > max_grav:
		vel.y = max_grav

	if is_on_floor() and vel.y > 0:
		vel.y = 0

	vel = move_and_slide(vel, Vector2(0, -1))

func correct_positions():
	if $pivot/enemySprite.scale.x < 0.0:
		$sfxShoot.position = Vector2(-189.309, 48.953)
		
		$enemyHitbox/enemyCol.disabled = true
		$enemyHitbox2/enemyCol2.disabled = false
	elif $pivot/enemySprite.scale.x > 0.0:
		$sfxShoot.position = Vector2(189.309, 48.953)
		
		$enemyHitbox/enemyCol.disabled = false
		$enemyHitbox2/enemyCol2.disabled = true

func take_damage(damage : float = 1, howstrong :int = 100, whichside :int = 0, has_sound :bool = true):
	if not health <= 0:
		health -= damage
		knockback(howstrong, whichside, has_sound)
		$pivot/enemySprite.material.set_shader_param("hit_strength", 1.0)
		yield(get_tree().create_timer(0.05),"timeout")
		$pivot/enemySprite.material.set_shader_param("hit_strength", 0.0)
func knockback(howstrong :int = 100, whichside :int = 0, has_sound :bool = true):
	var direction : Vector2
	
	if whichside == 0:
		if $pivot/enemySprite.scale.x < 0.0:
			direction.x += -1
		elif $pivot/enemySprite.scale.x > 0.0:
			direction.x += 1
	else:
		direction.x = whichside
	
	if howstrong != 0:
		howstrong -= 1
	
	if has_sound:
		$sfxHit.play()
	
	direction = move_and_slide(direction * howstrong, Vector2.UP)

var _bullet = preload("res://Objects/Bullet/oBullet.tscn")
onready var bulletPos = $pivot/enemySprite/BulletPos
func shoot(rate_speed := 1):
	match attack_type:
		attack_types.TANQUE:
				$sfxShoot.stream = load("res://Audio/SFX/Shoot/GunFIRE_MachineGun2.mp3")
				$sfxShoot.play()
				#------------------------------------------------#
				$pivot/enemySprite/BulletPos/bulletGunfire.rotation_degrees = rand_range(0, 359)
				$pivot/enemySprite/BulletPos/bulletGunfire.visible = true
				
				var bala_instance = _bullet.instance()
				bala_instance.global_position = bulletPos.global_position
				bala_instance.rotation = $pivot/enemySprite/BulletPos.global_rotation
				bala_instance.add_to_group("ShootByEnemy")
				
				bala_instance.bullet_type = bala_instance.bullet_types.METRALHADORA
				bala_instance.damage = 1
				bala_instance.bulletspeed = 2500
				bala_instance.basetilt = 0.25
				
				get_parent().call_deferred("add_child", bala_instance)
				
				GameManager.camera.startshaking(1.5, 10, 0.3)
				
				
				knockback(120)
				
				set_process(false)
				yield(get_tree().create_timer(.03), "timeout")
				set_process(true)
				
				$pivot/enemySprite/BulletPos/bulletGunfire.visible = false
				
				set_process(false)
				yield(get_tree().create_timer(.25), "timeout")
				set_process(true)
func _on_enemyHitbox_area_entered(area):
	if attack_type == attack_types.TANQUE:
		var body = area.get_parent()
		if body.is_in_group("Player"):
			if not body.dead: 
				body.take_damage(1, 10000, -1, true)
				GameManager.camera.startshaking(1.3, 8, 0.2)
func _on_enemyHitbox2_area_entered(area):
	if attack_type == attack_types.TANQUE:
		var body = area.get_parent()
		if body.is_in_group("Player"):
			if not body.dead: 
				body.take_damage(1, 10000, 1, true)
				GameManager.camera.startshaking(1.3, 8, 0.2)

func _on_enemyAnm_animation_finished(anim_name):
	if anim_name == "anmDead":
		queue_free()
