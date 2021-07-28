extends KinematicBody2D

onready var Player = GameManager.globals.player_node

enum behaviour{
	FLYINGAROUND,
	HUNTINGPLAYER,
	SEPARATING}

export(behaviour) var currentbeh = behaviour.FLYINGAROUND
	
enum SIZE{
	GIANT,
	SMALL,
	MINI,
	}
	
export(SIZE) var currentsize = SIZE.GIANT
export var health = 100
export var directiontospawn : Vector2

export var keepdriftingforhowlong = 30.0
var keepdrifting



# Declare member variables here. Examples:
# var a = 2
# var b = "text"
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

# Called when the node enters the scene tree for the first time.
func _ready():
	keepdrifting = keepdriftingforhowlong + OS.get_ticks_msec()
	pass # Replace with function body.


var wheretogo : Vector2
var holdtime = 1500
func _process(delta):
	
	print(health)
	
	var playersprite = $Sprite
	
	
	match currentbeh:
		behaviour.FLYINGAROUND:
			if OS.get_ticks_msec() > holdtime:
				randomize()
				wheretogo = Vector2(rand_range(-100, 100), rand_range(-100, 100))
				holdtime = OS.get_ticks_msec() + 1500
			else:
				move_and_slide(wheretogo) * 5
				
			
			if find_player():
				currentbeh = behaviour.HUNTINGPLAYER
				pass
			pass
		behaviour.HUNTINGPLAYER:
			var playerpos = Player.get_global_position()
			wheretogo = -(global_position - playerpos)
			print(wheretogo)
			move_and_slide(wheretogo) * 7
			#global_position = lerp(global_position, playerpos, delta)
			pass
		behaviour.SEPARATING:
			if OS.get_ticks_msec() < keepdrifting:
				var stopforce = inverse_lerp(OS.get_ticks_msec(), keepdrifting, delta)
				
				move_and_slide(directiontospawn * stopforce)
			else:
				currentbeh = behaviour.FLYINGAROUND
			
			
			pass
		
		
		
	playersprite.flip_h = wheretogo.x >= 0
	

	if health <= 0:
		var sizetochoose
		var quantitytochoose : float
		match currentsize:
			SIZE.GIANT:
				sizetochoose = SIZE.SMALL
				quantitytochoose = 3
				pass
			SIZE.SMALL:
				sizetochoose = SIZE.MINI
				quantitytochoose = 2
				pass
			SIZE.MINI:
				queue_free()
				pass
		createchildren(sizetochoose, quantitytochoose)
		queue_free()
	pass
	
func createchildren(whatsize, howmany : float):
	while howmany > 0:
		var newchild = duplicate()
		get_parent().add_child(newchild)
		newchild.global_position = global_position
		newchild.currentsize = whatsize
		newchild.directiontospawn = Vector2(rand_range(-100, 100), rand_range(-100, 100))
		newchild.currentbeh = behaviour.SEPARATING
		howmany -= 1
		pass
	pass
	
func _on_damagedoerCol_area_entered(area):
		if currentbeh == behaviour.HUNTINGPLAYER:
			var body = area.get_parent()
			if body.is_in_group("Player"):
				if not body.dead: 
					body.health -= 1
					body.knockback(10000, -1, true)
					GameManager.camera.startshaking(1.3, 8, 0.2)
		pass # Replace with function body.
