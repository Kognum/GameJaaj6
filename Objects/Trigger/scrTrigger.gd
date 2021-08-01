extends Area2D

enum types{
	DEATH,
	TOGLE_WIND}
export(types) var type = types.DEATH

var activate_wind = false

func _process(delta):
	if activate_wind:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("MUS"), lerp(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("MUS")), -40, delta * 2))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGS"), lerp(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("BGS")), 0, delta * 2))
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("MUS"), lerp(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("MUS")), 0, delta * 2))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGS"), lerp(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("BGS")), -80, delta * 2))

func _on_oTrigger_body_entered(body):
	if body.is_in_group("Player"):
		match type:
			types.DEATH:
				body.health = 0
				GameManager.camera.startshaking(2.5, 12, 0.3)
				body.get_node("sfxHit").play()
			types.TOGLE_WIND:
				activate_wind = true
	else:
		match type:
			types.DEATH:
				if body.name.begins_with("oHorda") or body.name.begins_with("oHeavy") or body.name.begins_with("oHardHitter"):
					body.health = 0
					GameManager.camera.startshaking(2.5, 12, 0.3)
					body.get_node("sfxHit").play()
func _on_oTrigger_body_exited(body):
	if body.is_in_group("Player"):
		match type:
			types.TOGLE_WIND:
					activate_wind = false
