extends KinematicBody2D

export var jump_height : float
export var jump_time_to_peak : float
export var jump_time_to_descent : float

onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

onready var arm = $playerSprites/ArmPivot/Arm
onready var arm_pivot = $playerSprites/ArmPivot
onready var bulletPos = $playerSprites/ArmPivot/Arm/BulletPos
onready var gunFire = $playerSprites/ArmPivot/Arm/BulletPos/bulletGunfire
onready var body = $playerSprites/playerSprite
onready var anm = $playerAnimation

var _cursor = preload("res://Objects/Cursor/oCursor.tscn")
func spawn_cursor():
	var cursor_instance = _cursor.instance()
	get_parent().call_deferred("add_child",cursor_instance)

func _init():
	GameManeger.globals.player_node = self
func _ready():
	GameManager.globals.lock_mouse = true
	spawn_cursor()
func _physics_process(delta):
	if GameManager.globals.player_move:
		move(delta)
	if GameManager.globals.player_look:
		arm(delta)
	if GameManager.globals.player_shoot:
		shoot()
	
	animate()

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

func animate():
	#Walk
	if is_on_floor():
		if Input.is_action_pressed("player_left") or Input.is_action_pressed("player_right"): 
			anm.play("anmWalk")
		else:
			anm.play("anmIdle")
	else:
		if velocity.y < 0:
			anm.play("anmJump")
		else:
			anm.play("anmFall")

# TW : DOR E SOFRIMENTO, Risco de sangramento em suas retinas
func arm(_delta):
	var _cursor = get_global_mouse_position()
	
	var _sprites = arm.get_parent()
	
	body.flip_h = arm.flip_v
	
	if arm.flip_v:
		_sprites.position = Vector2(-70.0, -69.227)
	else:
		_sprites.position = Vector2(0.0, -69.227)
	
	arm.look_at(_cursor)
	
	
	if arm.flip_v:
		if _cursor.x > (arm.global_position.x + 60):
			arm.flip_v = false
	else:
		if _cursor.x < (arm.global_position.x + -60):
			arm.flip_v = true

var _bullet = preload("res://Objects/Bullet/oBullet.tscn")
func shoot():
	if Input.is_action_pressed("player_shoot"):
		gunFire.rotation_degrees = rand_range(0, 359)
		gunFire.visible = true
		
		var bala_instance = _bullet.instance()
		bala_instance.global_position = bulletPos.global_position
		bala_instance.rotation = arm.global_rotation
		get_parent().call_deferred("add_child", bala_instance)
		GameManager.camera.startshaking(1.5, 10, 0.3)
		
		yield(get_tree().create_timer(0.25), "timeout")
	else:
		gunFire.visible = false

func play_footstep():
	$sfxFootstep.pitch_scale = rand_range(0.75, 1.3)
	$sfxFootstep.play()
