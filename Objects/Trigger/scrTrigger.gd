extends Area2D

enum types {
	SPAWN_HORDA}
export(types) var type  = types.SPAWN_HORDA

export (bool) var once
export (bool) var checking = true
export var info = {
	"horda_spawner": NodePath()}

onready var col = $triggerCol

func _process(delta):
	$triggerCol.disabled =! checking

func _on_oTrigger_body_entered(body):
	if body.is_in_group("Player"):
		match type:
			types.SPAWN_HORDA:
				print("triggered")
				get_node(info.horda_spawner).summon()
func _on_oTrigger_body_exited(body):
	if body.is_in_group("Player"):
		if once:
			checking = false
