extends KinematicBody2D

export var move_speed = 200.0

var velocity := Vector2.ZERO

export var jump_height : float
export var jump_time_to_peak : float
export var jump_time_to_descent : float

var timeHeld = 0
export var timeForFullJump = 0.1

onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

func _ready():
	GameManeger.globals.lock_mouse = true
	
	spawn_cursor()
func _physics_process(delta):
	if GameManeger.globals.player_move:
		move(delta)
	if GameManeger.globals.player_look:
		arm(delta)

func move(_delta):
	var horizontal := 0.0
	
	if Input.is_action_pressed("player_left"):
		horizontal -= 1.0
	if Input.is_action_pressed("player_right"):
		horizontal += 1.0
	print(horizontal)
	
	velocity.x = horizontal * move_speed
	velocity.y += get_gravity() * _delta
	
	jump(_delta)
	
	velocity = move_and_slide(velocity, Vector2.UP)
func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity
func jump(_delta):
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = jump_velocity

func arm(_delta):
	$playerArm.look_at(get_viewport().get_mouse_position())
	
	print($playerArm.rotation_degrees)

var _cursor = preload("res://Objects/oCursor.tscn")
func spawn_cursor():
	var cursor_instance = _cursor.instance()
	get_parent().call_deferred("add_child",cursor_instance)
