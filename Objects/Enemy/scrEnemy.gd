extends KinematicBody2D

enum state_machine {
	WAITING,
	PATROLING,
	SEEKING,
	ATTACKING,
	DEFENDING,
	DEAD}

var default_state = state_machine.WAITING
var currect_state = currect_state

var health = 100

func _process(delta):
	print(currect_state)

func waiting():
	pass
