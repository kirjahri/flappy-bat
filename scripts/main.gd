extends Node

@export_group("Dripstones")

@export_subgroup("Nodes")
@export var scene: PackedScene
@export var destroy_area: Area2D
@export var timer: Timer

@export_subgroup("Spawn Position")
@export var x: float
@export var y_min: float
@export var y_max: float


func _ready() -> void:
	if scene == null:
		push_warning("The dripstones scene has not been assigned in the editor")

	destroy_area.area_entered.connect(_on_area_entered)
	timer.timeout.connect(_on_timer_timeout)

	timer.start()


func _on_area_entered(area: Area2D) -> void:
	area.queue_free()


func _on_timer_timeout() -> void:
	var dripstones: Node2D = scene.instantiate()

	dripstones.scale = Vector2(10, 10)
	dripstones.position = Vector2(x, randf_range(y_min, y_max))

	self.add_child(dripstones)
