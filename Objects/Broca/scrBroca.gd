extends Area2D

var destroyed = false
var player_here = false

export var spawn_enemy := false
export var enemy : PackedScene
export var father : NodePath
export var where : NodePath

func _ready():
	$sprInterract.visible = false
func _process(delta):
	if player_here:
		if Input.is_action_just_pressed("player_interact"):
			destroyed = true
		if destroyed:
			$interactAnm.play_backwards("anmInteract")
			$brocaAnm.play("anmDestroyed", .7)
			$sfxOFF.play()
			$brocaBlood.emitting = true
			GameManager.brokas += 1
			#if spawn_enemy:
			#	spawn()
			set_process(false)

func _on_oPC_body_entered(body):
	if not destroyed:
		if body.is_in_group("Player"):
			$interactAnm.play("anmInteract")
			player_here = true
func _on_oPC_body_exited(body):
	if body.is_in_group("Player"):
		$interactAnm.play_backwards("anmInteract")
		player_here = false

func spawn():
	var enemy_instance = enemy.instance()
	enemy_instance.position = get_node(where).position
	enemy_instance.set_process(false)
	enemy_instance.set_physics_process(false)
	get_node(father).add_child(enemy_instance)
