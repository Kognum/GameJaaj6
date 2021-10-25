extends KinematicBody2D

var max_health := 3
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
onready var timelabel = $nHUD/Timer/Label
export var timer : float
var secs
var mins

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
func _process(delta):
	if not dead:
		if GameManager.globals.player_shoot:
			shoot()
func _physics_process(delta):
	#Timer
	if GameManager.info.counting:
		timer -= delta
	secs = fmod(timer, 60)
	mins = fmod(timer, 60*60) / 60
	timelabel.text = "%02d : %02d" % [mins, secs]
	if timer <= 54:
		get_parent().get_node("Audio").falling = true
		if $alertTimer.is_playing() == false:
			$alertTimer.play("alertTimer")
	GameManager.info.secs = secs
	GameManager.info.mins = mins
	
	if not dead:
		if GameManager.globals.player_move:
			move(delta)
		if GameManager.globals.player_look:
			arm(delta)
			aim(delta)
		
		flashfadeout(1)
		animate()
		manage_health(delta)
	else:
		aply_only_gravity(delta)
		$hitAnimation.stop()
		$playerAnimation.play("anmDead", 1)
		set_physics_process(false)
		yield($playerAnimation, "animation_finished")
		set_physics_process(true)
		if GameManager.cycle >= 3:
			SceneChanger.change_scene("res://Scenes/GameOver/scnGameOver.tscn")
		else:
			get_parent().next_cycle()
			dead = false
			health = max_health

export var speed = 100.0
var velocity := Vector2.ZERO
var acceleration = 5;
var horizontal := 0.0
func move(_delta):
	horizontal = 0.0
	
	#if Input.is_action_pressed("player_left"):
	#	horizontal = min(horizontal + acceleration, -speed)
	#elif Input.is_action_pressed("player_right"):
	#	horizontal = max(horizontal - acceleration, speed)
	#else:
	#	horizontal = lerp(horizontal, 0, 1)
	
	horizontal = $nHUD/Controls/joyMove.output.x * speed
	
	velocity.x = horizontal 
	velocity.y += get_gravity() * _delta
	
	jump(_delta)
	
	velocity = move_and_slide(velocity, Vector2.UP, true)
func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity
func jump(_delta):
	if is_on_floor():
		#if Input.is_action_just_pressed("player_jump"):
		if $nHUD/Controls/btnJump.pressed:
			if not jumping_on_knockback:
				$sfxFootstepJump.play()
				velocity.y = jump_velocity

func aply_only_gravity(_delta):
	velocity.x = 0 
	velocity.y += get_gravity() * _delta
	
	velocity = move_and_slide(velocity, Vector2.UP, true)

func animate():
	if is_on_floor():
		#if Input.is_action_pressed("player_left") or Input.is_action_pressed("player_right"): 
		if abs($nHUD/Controls/joyMove.output.x) > 0:
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
	var _cursor = get_parent().get_node("oCursor").get_global_transform().get_origin()
	
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
			
			#if Input.is_action_just_pressed("player_shoot"):
			if abs($nHUD/Controls/joyShoot.output.x) > 0 or abs($nHUD/Controls/joyShoot.output.y) > 0:
				$sfxShoot.stream = load("res://Audio/SFX/Shoot/GunFIRE_Shotgun3.mp3")
				$sfxShoot.play()
				#------------------------------------------------#
				gunFire.rotation_degrees = rand_range(0, 359)
				gunFire.visible = true
				
				#-----------------------1------------------------#
				var bala_instance_1 = _bullet.instance()
				bala_instance_1.global_position = bulletPos.global_position
				bala_instance_1.rotation = arm.global_rotation
				bala_instance_1.add_to_group("ShootByPlayer")
				
				bala_instance_1.bullet_type = bala_instance_1.bullet_types.SHOTGUN
				bala_instance_1.damage = 7
				bala_instance_1.bulletspeed = 2500
				bala_instance_1.basetilt = 0.15
				
				get_parent().call_deferred("add_child", bala_instance_1)
				
				#-----------------------2------------------------#
				var bala_instance_2 = _bullet.instance()
				bala_instance_2.global_position = bulletPos.global_position
				bala_instance_2.rotation = arm.global_rotation
				bala_instance_2.add_to_group("ShootByPlayer")
				
				bala_instance_2.bullet_type = bala_instance_2.bullet_types.SHOTGUN
				bala_instance_2.damage = 7
				bala_instance_2.bulletspeed = 2500
				bala_instance_2.basetilt = 0.18
				
				get_parent().call_deferred("add_child", bala_instance_2)
				
				#-----------------------3------------------------#
				var bala_instance_3 = _bullet.instance()
				bala_instance_3.global_position = bulletPos.global_position
				bala_instance_3.rotation = arm.global_rotation
				bala_instance_3.add_to_group("ShootByPlayer")
				
				bala_instance_3.bullet_type = bala_instance_3.bullet_types.SHOTGUN
				bala_instance_3.damage = 7
				bala_instance_3.bulletspeed = 2500
				bala_instance_3.basetilt = 0.1
				
				get_parent().call_deferred("add_child", bala_instance_3)
				
				GameManager.camera.startshaking(1.5, 10, 0.3)
				knockback(200)
				
				gunFire.visible = false
				set_process(false)
				yield(get_tree().create_timer(.3), "timeout")
				set_process(true)
				$sfxReloadShotgun.play()
				set_process(false)
				yield(get_tree().create_timer(.2), "timeout")
				set_process(true)
				
			else:
				gunFire.visible = false
		wp_cycles.SPNIPER:
			$nHUD/sprWPCycle.texture = wpc_tex2
			
			#if Input.is_action_just_pressed("player_shoot"):
			if abs($nHUD/Controls/joyShoot.output.x) > 0 or abs($nHUD/Controls/joyShoot.output.y) > 0:
				$sfxShoot.stream = load("res://Audio/SFX/Shoot/GunFIRE_Snipe1.mp3")
				$sfxShoot.play()
				#------------------------------------------------#
				gunFire.rotation_degrees = rand_range(0, 359)
				gunFire.visible = true
				
				var bala_instance = _bullet.instance()
				bala_instance.global_position = bulletPos.global_position
				bala_instance.rotation = arm.global_rotation
				bala_instance.add_to_group("ShootByPlayer")
				
				bala_instance.bullet_type = bala_instance.bullet_types.SNIPER
				bala_instance.damage = 30
				bala_instance.bulletspeed = 3000
				bala_instance.basetilt = 0.05
				
				get_parent().call_deferred("add_child", bala_instance)
				
				GameManager.camera.startshaking(1.5, 10, 0.3)
				knockback(200)
				
				gunFire.visible = false
				set_process(false)
				yield(get_tree().create_timer(.6), "timeout")
				set_process(true)
				$sfxReloadSniper.play()
				set_process(false)
				yield(get_tree().create_timer(.4), "timeout")
				set_process(true)
			else:
				gunFire.visible = false
		wp_cycles.METRALHADORA:
			$nHUD/sprWPCycle.texture = wpc_tex3
			
			#if Input.is_action_pressed("player_shoot"):
			if abs($nHUD/Controls/joyShoot.output.x) > 0 or abs($nHUD/Controls/joyShoot.output.y) > 0:
				$sfxShoot.stream = load("res://Audio/SFX/Shoot/GunFIRE_MachineGun2.mp3")
				$sfxShoot.play()
				#------------------------------------------------#
				gunFire.rotation_degrees = rand_range(0, 359)
				gunFire.visible = true
				
				var bala_instance = _bullet.instance()
				bala_instance.global_position = bulletPos.global_position
				bala_instance.rotation = arm.global_rotation
				bala_instance.add_to_group("ShootByPlayer")
				
				bala_instance.bullet_type = bala_instance.bullet_types.METRALHADORA
				bala_instance.damage = 3
				bala_instance.bulletspeed = 2500
				bala_instance.basetilt = 0.1
				
				get_parent().call_deferred("add_child", bala_instance)
				
				GameManager.camera.startshaking(1.5, 10, 0.3)
				knockback(120)
				
				set_process(false)
				yield(get_tree().create_timer(.07), "timeout")
				set_process(true)
			else:
				gunFire.visible = false
	
	if wp_cycle > 2:
		wp_cycle = 0 
	elif wp_cycle < 0:
		wp_cycle = 2
func change_cycle(cycle_no :int = -1):
	GameManager.globals.changing_cycle = true
	$sfxCycle.play()
	if cycle_no == -1:
		wp_cycle += 1
	else:
		wp_cycle += cycle_no

var cursor_margin :int = 200 
func aim(var _delta :float):
	get_parent().get_node("oCursor").position = lerp(get_parent().get_node("oCursor").position, position + ($nHUD/Controls/joyShoot.output * cursor_margin), 10 * _delta)

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
func knockback(howstrong :int = 100, whichside :int = 0, has_sound :bool = false):
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
	
	#if is_on_floor():
	#	if Input.is_action_just_pressed("player_jump"):
	#		$sfxFootstepJump.play()
	#		jumping_on_knockback = true
	#		direction.y = jump_velocity / 9
	#jumping_on_knockback = false
	
	if has_sound:
		$sfxHit.play()
	
	direction = move_and_slide(direction * howstrong, Vector2.UP)

var regenRate := 0.5
var can_regenerate := false
var heal_cooldown := 9.0
var max_heal_cooldown := 9.0
var start_cooldown = false
var accept_damage = true
func take_damage(damage : float = 1, howstrong :int = 100, whichside :int = 0, has_sound :bool = false):
	if not health <= 0:
		if accept_damage:
			health -= damage
			knockback(howstrong, whichside, has_sound)
			
			can_regenerate = false
			heal_cooldown = max_heal_cooldown
			start_cooldown = true
			
			$playerSprites/playerSprite.material.set_shader_param("hit_strength", 1.0)
			$playerSprites/ArmPivot/Arm.material.set_shader_param("hit_strength", 1.0)
			yield(get_tree().create_timer(0.1),"timeout")
			$playerSprites/playerSprite.material.set_shader_param("hit_strength", 0.0)
			$playerSprites/ArmPivot/Arm.material.set_shader_param("hit_strength", 0.0)
		
		accept_damage = false
		$hitAnimation.play("anmHit")
		yield($hitAnimation, "animation_finished")
		accept_damage = true
func manage_health(_delta):
	
	if health < 0:
		health = 0
	
	var opacity_level = $nUI/BackBufferCopy/fxDamage.material.get_shader_param("opacity")
	var shift_level1 = $nHUD/Heath/health1.material.get_shader_param("shift")
	var shift_level2 = $nHUD/Heath/health2.material.get_shader_param("shift")
	var shift_level3 = $nHUD/Heath/health3.material.get_shader_param("shift")
	match health:
		0:
			$bgsHeartbeat.volume_db = lerp($bgsHeartbeat.volume_db, 0, _delta * health)
			#$bgsHeartbeat.volume_db = linear2db(1)
			$nUI/BackBufferCopy/fxDamage.material.set_shader_param("opacity", lerp(opacity_level, 1, _delta * health))
			$nUI/BackBufferCopy/fxDamage.visible = true
			dead = true
		1:
			$bgsHeartbeat.volume_db = lerp($bgsHeartbeat.volume_db, -0, _delta * health)
			#$bgsHeartbeat.volume_db = linear2db(0.75)
			$nUI/BackBufferCopy/fxDamage.material.set_shader_param("opacity", lerp(opacity_level, 0.5, _delta * health))
			$nUI/BackBufferCopy/fxDamage.visible = true
			dead = false
		2:
			$bgsHeartbeat.volume_db = lerp($bgsHeartbeat.volume_db, -15, _delta * health)
			#$bgsHeartbeat.volume_db = linear2db(0.35)
			$nUI/BackBufferCopy/fxDamage.material.set_shader_param("opacity", lerp(opacity_level, 0.3, _delta * health))
			$nUI/BackBufferCopy/fxDamage.visible = true
			dead = false
			
		3:
			$bgsHeartbeat.volume_db = lerp($bgsHeartbeat.volume_db, -80, _delta * health)
			#$bgsHeartbeat.volume_db = linear2db(0)
			$nUI/BackBufferCopy/fxDamage.material.set_shader_param("opacity", lerp(opacity_level, 0.0, _delta * health))
			$nUI/BackBufferCopy/fxDamage.visible = true
			dead = false
	
	match GameManager.cycle:
			0:
				$nHUD/Heath/health1.material.set_shader_param("shift", lerp(shift_level1, 1.0, _delta * health))
				$nHUD/Heath/health2.material.set_shader_param("shift", lerp(shift_level2, 1.0, _delta * health))
				$nHUD/Heath/health3.material.set_shader_param("shift", lerp(shift_level3, 1.0, _delta * health))
			1:
				$nHUD/Heath/health1.material.set_shader_param("shift", lerp(shift_level1, 1.0, _delta * health))
				$nHUD/Heath/health2.material.set_shader_param("shift", lerp(shift_level2, 1.0, _delta * health))
				$nHUD/Heath/health3.material.set_shader_param("shift", lerp(shift_level3, -0.2, _delta * health))
			2:
				$nHUD/Heath/health1.material.set_shader_param("shift", lerp(shift_level1, 1.0, _delta * health))
				$nHUD/Heath/health2.material.set_shader_param("shift", lerp(shift_level2, -0.2, _delta * health))
				$nHUD/Heath/health3.material.set_shader_param("shift", lerp(shift_level3, -0.2, _delta * health))
			3:
				$nHUD/Heath/health1.material.set_shader_param("shift", lerp(shift_level1, -0.2, _delta * health))
				$nHUD/Heath/health2.material.set_shader_param("shift", lerp(shift_level2, -0.2, _delta * health))
				$nHUD/Heath/health3.material.set_shader_param("shift", lerp(shift_level3, -0.2, _delta * health))
		
	if start_cooldown:
		heal_cooldown -= _delta
		if heal_cooldown <= 0:
			can_regenerate = true
			start_cooldown = false
	if can_regenerate:
		if health < max_health:
			health += ceil(_delta * regenRate)
		else:
			health = max_health
			heal_cooldown = max_heal_cooldown
			can_regenerate = false
