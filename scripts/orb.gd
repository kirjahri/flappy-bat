extends Area2D

signal orb_collected

@export var speed: float = 600.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if not Global.in_death_state:
		position.x -= speed * delta


func _on_body_entered(_body: Node2D) -> void:
	queue_free()
	orb_collected.emit()
