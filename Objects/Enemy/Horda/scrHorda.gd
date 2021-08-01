extends KinematicBody2D

onready var Player = GameManager.globals.player_node

export(Texture) var sprite

enum state_machine {
	WAITING,
	HUNTING,
	RUNAWAY,
	DEAD}

enum attack_types {
	HORDA}

export(attack_types) var attack_type = attack_types.HORDA

export(state_machine) var default_state = state_machine.WAITING
onready var currect_state = default_state

export(int) var speed = 250
export(float) var HWGtimetofire = 3.5
export(float) var HWGprevioustimetofire

export(int) var max_health = 100
export(int) var runaway_health = 55
onready var health = max_health

func _init():
	if not sprite == null:
		$enemySprite.texture = sprite
func _ready():
	$enemySprite.material = $enemySprite.material.duplicate()
func _process(delta):
	match currect_state:
		state_machine.HUNTING:
			shoot()
		state_machine.RUNAWAY:
			shoot()
func _physics_process(delta):
	if health <= 0:
		currect_state = state_machine.DEAD
	
	correct_shoot_position()
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
			$enemyHitbox/enemyHitbox.disabled = true
			$enemyHitbox2/enemyHitbox2.disabled = true
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
export(int) var target_player_dist = 140
export(int) var jump_heigh = 800
export(int) var avoid_distance = 50
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
			$enemySprite.flip_h = false
		elif Player.position.x > position.x + target_player_dist:
			set_dir(1)
			$enemySprite.flip_h = true
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
		$enemySprite.flip_h = true
	elif Player.position.x > position.x + target_player_dist and true:
		set_dir(-1)
		$enemySprite.flip_h = true
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

func correct_shoot_position():
	if $enemySprite.flip_h:
		$enemySprite/BulletPos.position =  Vector2(337.843, -432.192)
	else:
		$enemySprite/BulletPos.position =  Vector2(-337.843, -432.192)

func take_damage(damage : float = 1, howstrong :int = 100, whichside :int = 0, has_sound :bool = true):
	if not health <= 0:
		health -= damage
		knockback(howstrong, whichside, has_sound)
		$enemySprite.material.set_shader_param("hit_strength", 1.0)
		yield(get_tree().create_timer(0.05),"timeout")
		$enemySprite.material.set_shader_param("hit_strength", 0.0)
func knockback(howstrong :int = 100, whichside :int = 0, has_sound :bool = true):
	var direction : Vector2
	
	if whichside == 0:
		if $enemySprite.flip_v:
			direction.x += -1
		else:
			direction.x += 1
	else:
		direction.x = whichside
	
	if howstrong != 0:
		howstrong -= 1
	
	if has_sound:
		$sfxHit.play()
	
	direction = move_and_slide(direction * howstrong, Vector2.UP)

var minion = preload("res://Objects/Enemy/Horda/Minion/oHordaMinion.tscn")
onready var bulletPos = $enemySprite/BulletPos
func shoot(rate_speed := 1):
	match attack_type:
		attack_types.HORDA:
			var minion_instance = minion.instance()
			minion_instance.global_position = bulletPos.global_position
			
			$sfxShoot.play()
			
			get_parent().call_deferred("add_child", minion_instance)
			
			GameManager.camera.startshaking(1.2, 6, 0.25)
			
			set_process(false)
			yield(get_tree().create_timer(2 * rate_speed), "timeout")
			set_process(true)
func _on_enemyHitbox_area_entered(area):
	if attack_type == attack_types.HORDA:
		var body = area.get_parent()
		if body.is_in_group("Player"):
			if not body.dead: 
				body.take_damage(1, 10000, -1, true)
				GameManager.camera.startshaking(1.3, 8, 0.2)
func _on_enemyHitbox2_area_entered(area):
	if attack_type == attack_types.HORDA:
		var body = area.get_parent()
		if body.is_in_group("Player"):
			if not body.dead: 
				body.take_damage(1, 10000, 1, true)
				GameManager.camera.startshaking(1.3, 8, 0.2)

func _on_enemyAnm_animation_finished(anim_name):
	if anim_name == "anmDead":
		queue_free()
