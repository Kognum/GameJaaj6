extends Node2D

export(Rect2) var camera_bounds = Rect2(0, 0, 0, 0)

var enemy_amount = 0
var count_enemies = false

func _ready():
	$Entities.pause_mode = Node.PAUSE_MODE_STOP
	visible = false
func _process(delta):
	if count_enemies:
		get_parent().get_parent().get_node("Audio").action_amount += $Entities.get_child_count()
		if $Entities.get_child_count() == 0:
			get_parent().get_parent().get_node("Audio").action_amount = 0 
			count_enemies = false

func _on_Bound_area_exited(area):
	if area.is_in_group("PlayerLevelHitbox"):
		
		$Entities.pause_mode = $Entities.PAUSE_MODE_STOP
		$Objects.pause_mode = $Objects.PAUSE_MODE_STOP
		visible = false
	
	if area.is_in_group("Bullet"):
		area.queue_free()
func _on_Bound_area_entered(area):
	if area.is_in_group("PlayerLevelHitbox"):
		count_enemies = true
		GameManager.camera.limit_left = camera_bounds.position.x
		GameManager.camera.limit_top = camera_bounds.position.y
		GameManager.camera.limit_right  = camera_bounds.size.x
		GameManager.camera.limit_bottom  = camera_bounds.size.y
		
		
		$Entities.pause_mode = $Entities.PAUSE_MODE_INHERIT
		$Objects.pause_mode = $Objects.PAUSE_MODE_INHERIT
		visible = true
