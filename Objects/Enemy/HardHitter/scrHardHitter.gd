extends KinematicBody2D

onready var Player = GameManager.globals.player_node

enum behaviour{
	FLYINGAROUND,
	HUNTINGPLAYER,
	SEPARATING,
	DEAD}
export(behaviour) var currentbeh = behaviour.FLYINGAROUND

enum SIZE{
	GIANT,
	SMALL,
	MINI,
	}
export(SIZE) var currentsize = SIZE.GIANT

export(int) var health = 50

var directiontospawn : Vector2

export(float) var spawnvel : float

var rects = [
	Rect2(Vector2(37.481, 1307.31), Vector2(402.277, 359.65)),
	Rect2(Vector2(138, 1850.832), Vector2(146, 148.126)),
	Rect2(Vector2(93.74, 1679.415), Vector2(272.041, 168.406))]

export(float) var keepdriftingforhowlong = 250.0

onready var playersprite = $Sprite

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

func fitsprite():
	var whichrect
	match currentsize:
		SIZE.GIANT:
			whichrect = 0
		SIZE.MINI:
			whichrect = 1
		SIZE.SMALL:
			whichrect = 2
	playersprite.region_rect = rects[whichrect]

func _ready():
	fitsprite()
	
	$Sprite.material.set_shader_param("hit_strength", 0.0)
	$Sprite.material = $Sprite.material.duplicate()
var wheretogo : Vector2
var holdtime = 1500
var maxtime
var prevtime
func _process(delta):
	match currentbeh:
		behaviour.FLYINGAROUND:
			if OS.get_ticks_msec() > holdtime:
				randomize()
				wheretogo = Vector2(rand_range(-100, 100), rand_range(-100, 100))
				holdtime = OS.get_ticks_msec() + 1500
			else:
				move_and_slide(wheretogo) * 5
			
			if find_player():
				$alertAnm.play("anmAlert")
				$sfxNotice.play()
				currentbeh = behaviour.HUNTINGPLAYER
		behaviour.HUNTINGPLAYER:
			var playerpos = Player.get_global_position()
			wheretogo = -(global_position - playerpos)
			move_and_slide(wheretogo) * 7
		behaviour.SEPARATING:
			if maxtime == null and prevtime == null:
				prevtime = OS.get_ticks_msec()
				maxtime = prevtime + keepdriftingforhowlong
				
			if maxtime > OS.get_ticks_msec():
				var driftingstrenght = inverse_lerp(maxtime, prevtime, OS.get_ticks_msec())
				global_position += (directiontospawn * driftingstrenght)
				
			else:
				currentbeh = behaviour.FLYINGAROUND
		behaviour.DEAD:
			$deathAnm.play("anmDeath")
			if not is_on_floor():
				$damagetakerCol.disabled = true
				$damagetakerColDead.disabled = false
				aply_only_gravity(delta)
			else:
				$sfxDie.play()
				$damagetakerCol.queue_free()
				$damagetakerColDead.queue_free()
				
				set_process(false)
	
	playersprite.flip_h = wheretogo.x >= 0
	
	if health <= 0:
		var sizetochoose
		var quantitytochoose : float
		match currentsize:
			SIZE.GIANT:
				sizetochoose = SIZE.SMALL
				quantitytochoose = 3
				
				#get_tree().paused = true
				#$deathBlood.visible = true
				#set_process(false)
				#yield(get_tree().create_timer(0.12), "timeout")
				#set_process(true)
				#get_tree().paused = false
				#$deathBlood.visible = false
				
				queue_free()
			SIZE.SMALL:
				sizetochoose = SIZE.MINI
				quantitytochoose = 2
				queue_free()
			SIZE.MINI:
				currentbeh = behaviour.DEAD
		createchildren(sizetochoose, quantitytochoose)

var jump_height : float = 250
var jump_time_to_descent : float = 0.2
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
var velocity :Vector2
func aply_only_gravity(_delta):
	velocity.x = 0 
	velocity.y += fall_gravity * _delta
	
	velocity = move_and_slide(velocity, Vector2.UP)

func take_damage(damage : float = 1, howstrong :int = 100, whichside :int = 0, has_sound :bool = true):
	if not health <= 0:
		health -= damage
		knockback(howstrong, whichside, has_sound)
		$Sprite.material.set_shader_param("hit_strength", 1.0)
		yield(get_tree().create_timer(0.05),"timeout")
		$Sprite.material.set_shader_param("hit_strength", 0.0)
func knockback(howstrong :int = 100, whichside :int = 0, has_sound :bool = true):
	var direction : Vector2
	
	if whichside == 0:
		if $Sprite.flip_v:
			direction.x += 1
		else:
			direction.x += -1
	else:
		direction.x = whichside
	
	if howstrong != 0:
		howstrong -= 1
	
	if has_sound:
		$sfxHit.play()
	
	direction = move_and_slide(direction * howstrong, Vector2.UP)

func createchildren(whatsize, howmany : float):
	var selfclonetscn = load("res://Objects/Enemy/HardHitter/oHardHitter.tscn")
	while howmany > 0:
		var newchild = selfclonetscn.instance()
		
		newchild.global_position = global_position
		newchild.currentsize = whatsize
		newchild.directiontospawn = Vector2(rand_range(-spawnvel, spawnvel), rand_range(-spawnvel, spawnvel))
		newchild.currentbeh = behaviour.SEPARATING
		
		get_parent().add_child(newchild)
		howmany -= 1

func _on_damagedoerCol_area_entered(area):
		if currentbeh == behaviour.HUNTINGPLAYER:
			var body = area.get_parent()
			if body.is_in_group("Player"):
				if not body.dead: 
					match currentsize:
						SIZE.GIANT:
							body.take_damage(1, 10000, -1, true)
						SIZE.SMALL:
							body.take_damage(0.3, 7000, -1, true)
						SIZE.MINI:
							body.take_damage(0.2, 3000, -1, true)
					
					GameManager.camera.startshaking(1.3, 8, 0.2)
func _on_damagedoerCol2_area_entered(area):
		if currentbeh == behaviour.HUNTINGPLAYER:
			var body = area.get_parent()
			if body.is_in_group("Player"):
				if not body.dead: 
					match currentsize:
						SIZE.GIANT:
							body.take_damage(1, 10000, 1, true)
						SIZE.SMALL:
							body.take_damage(0.3, 7000, 1, true)
						SIZE.MINI:
							body.take_damage(0.2, 3000, 1, true)

					
					GameManager.camera.startshaking(1.3, 8, 0.2)

func _on_deathAnm_animation_finished(anim_name):
	queue_free()
