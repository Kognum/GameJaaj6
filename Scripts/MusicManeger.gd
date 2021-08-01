extends Node2D


var action_amount := 0
var falling = false
var active = false

func start_maneger():
	if not active:
		$msuAction.play()
		active = true

func _process(delta):
	if active:
		if falling:
			if $msuFalling.playing != true:
				$msuFalling.play()
			
			$msuFalling.volume_db = lerp($msuFalling.volume_db, -5, delta * 2)
			$msuAction.volume_db = lerp($msuAction.volume_db, -80, delta * 2)
			$msuQuiet.volume_db = lerp($msuQuiet.volume_db, -80, delta * 2)
		else:
			if action_amount > 0 : # INIMIGO NA AREA
				$msuAction.volume_db = lerp($msuAction.volume_db, 0, delta * 2)
				$msuQuiet.volume_db = lerp($msuQuiet.volume_db, 0, delta * 2)
			else: # TA SAFE
				$msuAction.volume_db = lerp($msuAction.volume_db, 0, delta * 2)
				$msuQuiet.volume_db = lerp($msuQuiet.volume_db, 0, delta * 2)
	else:
		$msuFalling.volume_db = lerp($msuFalling.volume_db, -80, delta * 2)
		$msuAction.volume_db = lerp($msuAction.volume_db, -80, delta * 2)
		$msuQuiet.volume_db = lerp($msuQuiet.volume_db, -80, delta * 2)


func _on_msuQuiet_finished():
	$msuAction.play()
func _on_msuAction_finished():
	$msuQuiet.play()
