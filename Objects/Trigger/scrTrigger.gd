extends Area2D

enum types{
	DEATH}
export(types) var type = types.DEATH


func _on_oTrigger_body_entered(body):
	if body.is_in_group("Player"):
		match type:
			types.DEATH:
				body.health = 0
				GameManager.camera.startshaking(2.5, 12, 0.3)
				body.get_node("sfxHit").play()
	else:
		match type:
			types.DEATH:
				if body.name.begins_with("oHorda") or body.name.begins_with("oHeavy") or body.name.begins_with("oHardHitter"):
					body.health = 0
					GameManager.camera.startshaking(2.5, 12, 0.3)
					body.get_node("sfxHit").play()


func _on_oTrigger_body_exited(body):
	if body.is_in_group("Player"):
		pass
