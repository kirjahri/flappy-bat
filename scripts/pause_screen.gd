extends Control


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause") and visible:
		get_viewport().set_input_as_handled()
		get_tree().paused = false
		hide()
