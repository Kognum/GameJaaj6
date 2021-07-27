extends KinematicBody2D

var health := 3
var dead := false

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
onready var flash = $Flash

var _cursor = preload("res://Objects/Cursor/oCursor.tscn")
var possibledoortoentner = null
func spawn_cursor():
	var cursor_instance = _cursor.instance()
	get_parent().call_deferred("add_child",cursor_instance)
func setup_flash():
	flash.scale = get_viewport_rect().size

func _init():
	GameManager.globals.player_node = self
func _ready():
	GameManager.globals.lock_mouse = true
	spawn_cursor()
	setup_flash()
func _physics_process(delta):
	if not dead:
		if GameManager.globals.player_move:
			move(delta)
		if GameManager.globals.player_look:
			arm(delta)
		if GameManager.globals.player_shoot:
			shoot()
		
		flashfadeout(1)
		animate()
		manage_health()
	else:
		aply_only_gravity(delta)
		$playerAnimation.play("anmDead", 1)
		yield($playerAnimation, "animation_finished")
		SceneChanger.change_scene("res://Scenes/GameOver/scnGameOver.tscn")

export var speed = 100.0
var velocity := Vector2.ZERO
var acceleration = 5;
var horizontal := 0.0
func move(_delta):
	horizontal = 0.0
	
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
			if not jumping_on_knockback:
				velocity.y = jump_velocity

func aply_only_gravity(_delta):
	velocity.x = 0 
	velocity.y += get_gravity() * _delta
	
	velocity = move_and_slide(velocity, Vector2.UP)

func animate():
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
var wpc_tex1 = preload("res://Sprites/UI/WeaponCycle/sprWPCycle1.png")
var wpc_tex2 = preload("res://Sprites/UI/WeaponCycle/sprWPCycle2.png")
var wpc_tex3 = preload("res://Sprites/UI/WeaponCycle/sprWPCycle3.png")
enum wp_cycles {
	SHOTGUN,
	SPNIPER,
	METRALHADORA}
var wp_cycle = wp_cycles.SHOTGUN
func shoot():
	match wp_cycle:
		wp_cycles.SHOTGUN:
			$nHUD/sprWPCycle.texture = wpc_tex1
			
			if Input.is_action_just_pressed("player_shoot"):
				gunFire.rotation_degrees = rand_range(0, 359)
				gunFire.visible = true
				
				#-----------------------1------------------------#
				var bala_instance_1 = _bullet.instance()
				bala_instance_1.global_position = bulletPos.global_position
				bala_instance_1.rotation = arm.global_rotation
				bala_instance_1.add_to_group("ShootByPlayer")
				
				bala_instance_1.bullet_type = bala_instance_1.bullet_types.SHOTGUN
				bala_instance_1.damage = 3
				bala_instance_1.bulletspeed = 2500
				bala_instance_1.basetilt = 0.12
				
				get_parent().call_deferred("add_child", bala_instance_1)
				
				#-----------------------2------------------------#
				var bala_instance_2 = _bullet.instance()
				bala_instance_2.global_position = bulletPos.global_position
				bala_instance_2.rotation = arm.global_rotation
				bala_instance_2.add_to_group("ShootByPlayer")
				
				bala_instance_2.bullet_type = bala_instance_2.bullet_types.SHOTGUN
				bala_instance_2.damage = 3
				bala_instance_2.bulletspeed = 2500
				bala_instance_2.basetilt = 0.15
				
				get_parent().call_deferred("add_child", bala_instance_2)
				
				#-----------------------3------------------------#
				var bala_instance_3 = _bullet.instance()
				bala_instance_3.global_position = bulletPos.global_position
				bala_instance_3.rotation = arm.global_rotation
				bala_instance_3.add_to_group("ShootByPlayer")
				
				bala_instance_3.bullet_type = bala_instance_3.bullet_types.SHOTGUN
				bala_instance_3.damage = 3
				bala_instance_3.bulletspeed = 2500
				bala_instance_3.basetilt = 0.1
				
				get_parent().call_deferred("add_child", bala_instance_3)
				
				GameManager.camera.startshaking(1.5, 10, 0.3)
				knockback(100)
			else:
				gunFire.visible = false
		wp_cycles.SPNIPER:
			$nHUD/sprWPCycle.texture = wpc_tex2
			
			if Input.is_action_just_pressed("player_shoot"):
				gunFire.rotation_degrees = rand_range(0, 359)
				gunFire.visible = true
				
				var bala_instance = _bullet.instance()
				bala_instance.global_position = bulletPos.global_position
				bala_instance.rotation = arm.global_rotation
				bala_instance.add_to_group("ShootByPlayer")
				
				bala_instance.bullet_type = bala_instance.bullet_types.SNIPER
				bala_instance.damage = 5
				bala_instance.bulletspeed = 3000
				bala_instance.basetilt = 0.05
				
				get_parent().call_deferred("add_child", bala_instance)
				
				GameManager.camera.startshaking(1.5, 10, 0.3)
				knockback(100)
			else:
				gunFire.visible = false
		wp_cycles.METRALHADORA:
			$nHUD/sprWPCycle.texture = wpc_tex3
			
			if Input.is_action_pressed("player_shoot"):
				gunFire.rotation_degrees = rand_range(0, 359)
				gunFire.visible = true
				
				var bala_instance = _bullet.instance()
				bala_instance.global_position = bulletPos.global_position
				bala_instance.rotation = arm.global_rotation
				bala_instance.add_to_group("ShootByPlayer")
				
				bala_instance.bullet_type = bala_instance.bullet_types.METRALHADORA
				bala_instance.damage = 1
				bala_instance.bulletspeed = 2500
				bala_instance.basetilt = 0.05
				
				get_parent().call_deferred("add_child", bala_instance)
				
				GameManager.camera.startshaking(1.5, 10, 0.3)
				knockback(100)
				
				#yield(get_tree().create_timer(2), "timeout")
			else:
				gunFire.visible = false
	
	if wp_cycle > 2:
		wp_cycle = 0 
	elif wp_cycle < 0:
		wp_cycle = 2
	print(wp_cycle)
	
	if Input.is_action_just_pressed("player_secondary"): # DEBUG
		wp_cycle += 1


func play_footstep():
	$sfxFootstep.pitch_scale = rand_range(0.75, 1.3)
	$sfxFootstep.play()

func flashscreen(howmuch):
	flash.modulate = Color(255, 255, 255, howmuch)
	pass
func flashfadeout(howfast):
	var howmuchleft = flash.modulate.a
	
	if howmuchleft != 0:
		howmuchleft -= howfast
		
		flash.modulate = Color(255, 255, 255, howmuchleft)

var jumping_on_knockback = false
func knockback(howstrong :int = 100, whichside :int = 0):
	var direction : Vector2
	
	if whichside == 0:
		if arm.flip_v:
			direction.x += 1
		else:
			direction.x += -1
	else:
		direction.x = whichside
	
	if howstrong != 0:
		howstrong -= 1
	
	if is_on_floor():
		if Input.is_action_just_pressed("player_jump"):
			jumping_on_knockback = true
			direction.y = jump_velocity / 9
	jumping_on_knockback = false
	
	direction = move_and_slide(direction * howstrong, Vector2.UP)

func manage_health():
	match health:
		0:
			$nUI/BackBufferCopy/fxDamage.visible = true
			$nUI/BackBufferCopy/fxDamage.material.set_shader_param("Shadows", Color(255, 0, 0, 255))
			$nUI/BackBufferCopy/fxDamage.material.set_shader_param("Hilights", Color(196, 0, 0, 255))
			dead = true
		1:
			$nUI/BackBufferCopy/fxDamage.visible = true
			$nUI/BackBufferCopy/fxDamage.material.set_shader_param("Shadows", Color(170, 0, 0, 255))
			$nUI/BackBufferCopy/fxDamage.material.set_shader_param("Hilights", Color(131, 0, 0, 255))
		2:
			$nUI/BackBufferCopy/fxDamage.visible = true
			$nUI/BackBufferCopy/fxDamage.material.set_shader_param("Shadows", Color(170, 0, 0, 255))
			$nUI/BackBufferCopy/fxDamage.material.set_shader_param("Hilights", Color(67, 0, 0, 255))
		3:
			$nUI/BackBufferCopy/fxDamage.visible = false
			$nUI/BackBufferCopy/fxDamage.material.set_shader_param("Shadows", Color(0, 0, 0, 0))
			$nUI/BackBufferCopy/fxDamage.material.set_shader_param("Hilights", Color(0, 0, 0, 0))
			dead = false
