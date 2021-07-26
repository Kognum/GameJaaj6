extends Camera2D

export var maxoffset : Vector2

var isshaking = false
var currentinten
var currenttime
var currentlen
var currentspeed

func _ready():
	randomize()
	GameManager.camera = self
func _process(_delta):
	if isshaking:
		if currenttime <= 0:
			offset = Vector2(0,0)
			isshaking = false
		currenttime -= 1
		var makingdecay = inverse_lerp(0, currentlen, currenttime)
		
		_shake(currentinten, makingdecay)
		
		yield(get_tree().create_timer(currentspeed), "timeout")

func startshaking(intensity, howlong, howfast):
	currentinten = intensity
	currentlen = howlong
	currenttime = howlong
	currentspeed = howfast
	isshaking = true
func _shake(intensity, decay):
	offset.x = maxoffset.x * intensity * decay * rand_range(-1.0, 1.0)
	offset.y = maxoffset.y * intensity * decay * rand_range(-1.0, 1.0)


