extends Area2D

signal orb_collected

@export var speed: float = 600.0


func _ready() -> void:
	self.body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	self.position.x -= speed * delta


func _on_body_entered(_body: Node2D) -> void:
	self.queue_free()
	orb_collected.emit()
