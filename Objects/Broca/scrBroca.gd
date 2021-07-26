extends Area2D

var destroyed = false
var player_here = false

func _ready():
	$sprInterract.visible = false
func _process(delta):
	if player_here:
		if Input.is_action_just_pressed("player_interact"):
			destroyed = true
		if destroyed:
			$interactAnm.play_backwards("anmInteract")
			$brocaAnm.play("anmDestroyed")
			$brocaBlood.emitting = true

func _on_oPC_body_entered(body):
	if not destroyed:
		if body.is_in_group("Player"):
			$interactAnm.play("anmInteract")
			player_here = true
func _on_oPC_body_exited(body):
	if body.is_in_group("Player"):
		$interactAnm.play_backwards("anmInteract")
		player_here = false
