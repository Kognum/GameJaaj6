extends Node2D

func summon():
	$spawnerAnm.play("anmWake")
	print("player Anm")

var horda = preload("res://Objects/Enemy/Horda/oEnemyHorda.tscn")
func spawn():
	var horda_instace = horda.instance()
	
	horda_instace.global_position = global_position
	
	get_parent().call_deferred("add_child",horda_instace)
	
	queue_free()
