extends KinematicBody2D

export var jump_height : float
export var jump_time_to_peak : float
export var jump_time_to_descent : float

onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

var _cursor = preload("res://Objects/oCursor.tscn")
func spawn_cursor():
	var cursor_instance = _cursor.instance()
	get_parent().call_deferred("add_child",cursor_instance)

func _ready():
	GameManeger.globals.lock_mouse = true
	spawn_cursor()
	
func _physics_process(delta):
	if GameManeger.globals.player_move:
		move(delta)
	if GameManeger.globals.player_look:
		arm(delta)
	if GameManeger.globals.player_shoot:
		shoot()

export var speed = 100.0
var velocity := Vector2.ZERO
var acceleration = 5;
func move(_delta):
	var horizontal := 0.0
	
	if Input.is_action_pressed("player_left"):
		horizontal = min(horizontal + acceleration, -speed)
	elif Input.is_action_pressed("player_right"):
		horizontal = max(horizontal - acceleration, speed)
	else:
		horizontal = lerp(horizontal, 0, 1)
	
	velocity.x = horizontal 
	velocity.y += get_gravity() * _delta
	
	jump(_delta)
	
	velocity = move_and_slide(velocity, Vector2.UP)
func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity
func jump(_delta):
	if is_on_floor():
		if Input.is_action_just_pressed("player_jump"):
			velocity.y = jump_velocity
	#else:       --guardar pra dps--
	#	if velocity.y < 0:
			#$Sprite.play("Jump")
		#else:
			#$Sprite.play("Fall")

# TW : DOR E SOFRIMENTO, Risco de sangramento em suas retinas
func arm(_delta):
	var _playerArm = $sprites/playerArm
	
	var _cursor = get_viewport().get_mouse_position()
	
	var _sprites = _playerArm.get_parent()
	
	$playerPrototype.flip_h = _playerArm.flip_v
	
	if _playerArm.flip_v:
		_sprites.position = Vector2(-70.0, 13.0)
	else:
		_sprites.position = Vector2(0.0, 13.0)
	
	_playerArm.look_at(get_viewport().get_mouse_position())
	
	
	if _playerArm.flip_v:
		if _cursor.x > (_playerArm.global_position.x + 60):
			_playerArm.flip_v = false
	else:
		if _cursor.x < (_playerArm.global_position.x + -60):
			_playerArm.flip_v = true
			
	print(_cursor.x)
	print(_playerArm.global_position.x)

var _bullet = preload("res://Objects/Bullet/oBullet.tscn")

func shoot():
	if Input.is_action_pressed("player_shoot"):
		$sprites/playerArm/BulletPos/bulletGunfire.rotation_degrees = rand_range(0, 359)
		$sprites/playerArm/BulletPos/bulletGunfire.visible = true
		
		var bala_instance = _bullet.instance()
		bala_instance.global_position = $sprites/playerArm/BulletPos.global_position
		bala_instance.rotation = $sprites/playerArm.global_rotation
		get_parent().call_deferred("add_child", bala_instance)
		print($sprites/playerArm/BulletPos.global_position)
		print($sprites/playerArm.global_rotation)
		
		yield(get_tree().create_timer(0.25), "timeout")
	else:
		$sprites/playerArm/BulletPos/bulletGunfire.visible = false
