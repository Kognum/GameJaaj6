extends RigidBody2D

func _on_dropAnm_animation_finished(anim_name):
	queue_free()
