extends Control

@export var start_button: Button
@export var exit_button: Button
@export var main_scene: PackedScene


func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_scene)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
