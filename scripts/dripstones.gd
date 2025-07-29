extends Node2D

signal point_scored

@export var score_area: Area2D

@export var speed: float = 600.0


func _ready() -> void:
	score_area.body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if not Global.in_death_state:
		position.x -= speed * delta


func _on_body_entered(_body: Node2D) -> void:
	point_scored.emit()
