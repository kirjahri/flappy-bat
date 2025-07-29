extends Control


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("quick_restart"):
		if get_tree().paused:
			get_tree().paused = false

		Global.in_death_state = false
		get_tree().reload_current_scene()

	if Input.is_action_just_pressed("pause") and visible:
		get_viewport().set_input_as_handled()
		get_tree().paused = false
		hide()
