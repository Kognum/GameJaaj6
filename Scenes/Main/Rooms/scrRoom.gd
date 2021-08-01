extends Node2D

export(Rect2) var camera_bounds = Rect2(0, 0, 0, 0)

var enemy_amount = 0
var count_enemies = false
var player_got_here = false
var positions : Dictionary

func _ready():
	if not $Entities.get_child_count() == 0:
		for enemy in $Entities.get_children():
			#var _nname = String(enemy.name) + String(enemy.get_index())
			positions[enemy.name] = enemy.position
			
			enemy.set_process(false)
			enemy.set_physics_process(false)
	
	visible = false
func _process(delta):
	if count_enemies:
		get_parent().get_parent().get_node("Audio").action_amount += $Entities.get_child_count()
		if $Entities.get_child_count() == 0:
			get_parent().get_parent().get_node("Audio").action_amount = 0 
			count_enemies = false
	
	for node in $Sprites.get_children():
		if node.name.begins_with("ParallaxBackground"):
			for layer in node.get_children():
				layer.visible = visible

func reset():
	if not $Entities.get_child_count() == 0:
		for enemy in $Entities.get_children():
			if enemy.name.begins_with("@"):
				enemy.position = positions[positions.keys()[0]]
			else:
				if positions.has(enemy.name):
					enemy.position = positions[enemy.name]
			
			enemy.set_process(false)
			enemy.set_physics_process(false)

func _on_Bound_area_exited(area):
	if area.is_in_group("PlayerLevelHitbox"):
		visible = false
	
	if area.is_in_group("Bullet") and area.is_in_group("ShootByEnemy"):
		area.queue_free()
func _on_Bound_area_entered(area):
	if area.is_in_group("PlayerLevelHitbox"):
		count_enemies = true
		
		GameManager.camera.limit_left = camera_bounds.position.x
		GameManager.camera.limit_top = camera_bounds.position.y
		GameManager.camera.limit_right  = camera_bounds.size.x
		GameManager.camera.limit_bottom  = camera_bounds.size.y
		
		if not player_got_here:
			if not $Entities.get_child_count() == 0:
				for enemy in $Entities.get_children():
					enemy.set_process(true)
					enemy.set_physics_process(true)
					#pass
		
		player_got_here = true
		visible = true
