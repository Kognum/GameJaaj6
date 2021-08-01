extends Node2D


var action_amount := 0
var falling = false
var active = false

func start_maneger():
	active = true
	$msuAction.play()
	$msuQuiet.play()

func _process(delta):
	#print("action amount: " + String(action_amount))
	
	if active:
		
		if falling:
			$msuFalling.playing = true
			$msuAction.volume_db = lerp($msuAction.volume_db, -80, delta * 2)
			$msuQuiet.volume_db = lerp($msuQuiet.volume_db, -80, delta * 2)
			
		
		if action_amount > 0 : # INIMIGO NA AREA
			$msuAction.volume_db = lerp($msuAction.volume_db, -5, delta * 2)
			$msuQuiet.volume_db = lerp($msuQuiet.volume_db, -80, delta * 2)
		else: # TA SAFE
			$msuAction.volume_db = lerp($msuAction.volume_db, -80, delta * 2)
			$msuQuiet.volume_db = lerp($msuQuiet.volume_db, -2, delta * 2)
	else:
		$msuFalling.volume_db = lerp($msuFalling.volume_db, -80, delta * 2)
		$msuAction.volume_db = lerp($msuAction.volume_db, -80, delta * 2)
		$msuQuiet.volume_db = lerp($msuQuiet.volume_db, -80, delta * 2)
