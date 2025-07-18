extends Area2D

@export var timer: Timer


func _ready() -> void:
	self.body_entered.connect(_on_body_entered)
	timer.timeout.connect(_on_timer_timeout)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		timer.start()


func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
