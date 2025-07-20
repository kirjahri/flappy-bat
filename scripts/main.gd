extends Node

@export_group("Dripstones")

@export_subgroup("Nodes")
@export var dripstones_scene: PackedScene
@export var destroy_area: Area2D
@export var timer: Timer

@export_subgroup("Spawn Position")
@export var x: float
@export var y_min: float
@export var y_max: float

@export_subgroup("Speed")
@export_range(1, 100, 0.2) var added_speed: float = 5.0

@export_subgroup("Scale")
@export var dripstones_scale: Vector2 = Vector2(10, 10)

@export_group("Orb")
@export var orb_scene: PackedScene
@export var spawn_odds: float = 1.0 / 3.0

@export_subgroup("Spawn Position")
@export var added_x_range_min: float = 100.0
@export var added_x_range_max: float = 400.0

@export_subgroup("Scale")
@export var orb_scale: Vector2 = Vector2(2.5, 2.5)

@export_group("GUI")
@export var gui: Control

@export_group("Player")
@export var player: CharacterBody2D

@export_subgroup("Vision")

# Defines how many seconds the animation that limits the player's vision is set back (0.0 restores nothing, 20.0 restores it all).
@export_range(0, 20, 0.2) var seconds_restored: float = 2.0

var score: int = 0
var dripstones_speed: float


func _ready() -> void:
	dripstones_speed = dripstones_scene.instantiate().speed

	destroy_area.area_entered.connect(_on_area_entered)
	timer.timeout.connect(_on_timer_timeout)

	timer.start()


func _on_area_entered(area: Area2D) -> void:
	area.queue_free()


func _on_timer_timeout() -> void:
	var dripstones: Node2D = dripstones_scene.instantiate()

	dripstones.scale = dripstones_scale
	dripstones.position = Vector2(x, randf_range(y_min, y_max))
	dripstones.speed = dripstones_speed
	dripstones.point_scored.connect(_on_point_scored)

	if randf() < spawn_odds:
		var orb: Area2D = orb_scene.instantiate()

		orb.scale = orb_scale
		orb.position = Vector2(
			x + randf_range(added_x_range_min, added_x_range_max), randf_range(y_min, y_max)
		)
		orb.speed = dripstones_speed
		orb.orb_collected.connect(_on_orb_collected)

		self.add_child(orb)

	self.add_child(dripstones)


func increment_score(amount: int) -> void:
	var score_label: Label = gui.get_node("%ScoreLabel")
	score += amount
	score_label.text = str(score)


func _on_point_scored() -> void:
	increment_score(1)

	dripstones_speed += added_speed

	# Make sure that existing dripstones and orbs have their speed changed too
	for node: Node in get_tree().get_nodes_in_group("dripstones"):
		node.speed = dripstones_speed

	for node: Node in get_tree().get_nodes_in_group("orb"):
		node.speed = dripstones_speed


func _on_orb_collected() -> void:
	var animation_player: AnimationPlayer = player.get_node("AnimationPlayer")
	var current_position: float = animation_player.current_animation_position

	# Play the `"lose_vision"` animation starting from the previous current position minus `seconds_restored` until the end
	animation_player.stop()
	animation_player.play_section("lose_vision", current_position - seconds_restored, -1.0)
