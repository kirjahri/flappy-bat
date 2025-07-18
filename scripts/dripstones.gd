extends Node2D

@export var speed: float = 600.0


func _process(delta: float) -> void:
	self.position.x -= speed * delta
