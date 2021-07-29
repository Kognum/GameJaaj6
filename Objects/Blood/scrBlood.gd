extends Sprite

func _on_bloodAnm_animation_finished(anim_name):
	queue_free()
