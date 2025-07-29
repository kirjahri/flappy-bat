extends Node

@export var spawn_timer: Timer
@export var canvas_modulate: CanvasModulate

@export_group("Dripstones")

@export var dripstones_scene: PackedScene
@export var dripstones_destroy_area: Area2D

@export_subgroup("Spawn")
@export var dripstones_spawn_x: float
@export var dripstones_spawn_y_min: float
@export var dripstones_spawn_y_max: float

@export_subgroup("Speed")
@export_range(1, 100, 0.2) var dripstones_added_speed: float = 5.0

@export_subgroup("Scale")
@export var dripstones_scale: Vector2 = Vector2(10, 10)

@export_group("Orb")
@export var orb_scene: PackedScene
@export var orb_scale: Vector2 = Vector2(2.5, 2.5)
@export var orb_spawn_rate: float = 1.0 / 3.0

# Defines how many seconds the animation that limits the player's vision is set back by orbs (0.0 restores nothing, 20.0 restores it all).
@export_range(0, 30, 0.2) var seconds_of_vision_restored: float = 2.0

@export_subgroup("Spawn Position")
@export var orb_spawn_added_x_range_min: float = 100.0
@export var orb_spawn_added_x_range_max: float = 400.0

@export_group("Player")
@export var player: CharacterBody2D

@export_group("HUD")
@export var hud: Control

@export_group("Pause Screen")
@export var pause_screen: Control

@export_group("Game Over")
@export var death_timer: Timer
@export var death_flash: ColorRect
@export_range(-1000, 0, 0.2) var death_hop_velocity: float = -600.0

@export_subgroup("UI")
@export var game_over: Control
@export_file("*.tscn") var main_menu_scene_path: String

var score: int = 0
var dripstones_speed: float

@onready var animation_player: AnimationPlayer = player.get_node("AnimationPlayer")
@onready var previous_animation_position: float = animation_player.current_animation_position

@onready var vision_bar: ProgressBar = hud.get_node("%VisionBar")

@onready var resume_button: Button = pause_screen.get_node("%ResumeButton")
@onready var pause_screen_retry_button: Button = pause_screen.get_node("%RetryButton")
@onready var pause_screen_exit_button: Button = pause_screen.get_node("%ExitButton")

@onready var game_over_retry_button: Button = game_over.get_node("%RetryButton")
@onready var game_over_exit_button: Button = game_over.get_node("%ExitButton")


func _ready() -> void:
	dripstones_speed = dripstones_scene.instantiate().speed

	vision_bar.max_value = animation_player.current_animation_length

	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	dripstones_destroy_area.area_entered.connect(_on_dripstones_destroy_area_entered)

	resume_button.pressed.connect(_on_resume_button_pressed)
	pause_screen_retry_button.pressed.connect(_on_retry_button_pressed)
	pause_screen_exit_button.pressed.connect(_on_exit_button_pressed)

	death_timer.timeout.connect(_on_death_timer_timeout)

	game_over_retry_button.pressed.connect(_on_retry_button_pressed)
	game_over_exit_button.pressed.connect(_on_exit_button_pressed)

	spawn_timer.start()


func _process(delta: float) -> void:
	for kill_zone: Area2D in get_tree().get_nodes_in_group("kill_zone"):
		if not kill_zone.is_connected("body_entered", _on_kill_zone_body_entered):
			kill_zone.body_entered.connect(_on_kill_zone_body_entered)

	# This check prevents the progress bar from jumping above where it should be
	if not (
		animation_player.current_animation_position
		< previous_animation_position - seconds_of_vision_restored
	):
		vision_bar.value = lerp(
			vision_bar.value,
			animation_player.current_animation_length - animation_player.current_animation_position,
			delta * 10
		)

	previous_animation_position = animation_player.current_animation_position


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause") and not game_over.visible:
		get_tree().paused = true
		pause_screen.visible = true


func _on_dripstones_destroy_area_entered(area: Area2D) -> void:
	area.queue_free()


func _on_point_scored() -> void:
	increment_score(1)

	dripstones_speed += dripstones_added_speed

	# Make sure that existing dripstones and orbs have their speed changed too
	for node: Node in get_tree().get_nodes_in_group("dripstones"):
		node.speed = dripstones_speed

	for node: Node in get_tree().get_nodes_in_group("orb"):
		node.speed = dripstones_speed


func _on_orb_collected() -> void:
	var current_position: float = animation_player.current_animation_position

	# Play the `"lose_vision"` animation starting from the previous current position minus `seconds_restored` until the end
	animation_player.stop()
	animation_player.play_section(
		"lose_vision", current_position - seconds_of_vision_restored, -1.0
	)


func _on_spawn_timer_timeout() -> void:
	var dripstones: Node2D = dripstones_scene.instantiate()

	dripstones.scale = dripstones_scale
	dripstones.position = Vector2(
		dripstones_spawn_x, randf_range(dripstones_spawn_y_min, dripstones_spawn_y_max)
	)
	dripstones.speed = dripstones_speed
	dripstones.point_scored.connect(_on_point_scored)

	if randf() < orb_spawn_rate:
		var orb: Area2D = orb_scene.instantiate()

		orb.scale = orb_scale
		orb.position = Vector2(
			(
				dripstones_spawn_x
				+ randf_range(orb_spawn_added_x_range_min, orb_spawn_added_x_range_max)
			),
			randf_range(dripstones_spawn_y_min, dripstones_spawn_y_max)
		)
		orb.speed = dripstones_speed
		orb.orb_collected.connect(_on_orb_collected)

		add_child(orb)

	add_child(dripstones)


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	pause_screen.hide()


func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	Global.in_death_state = false
	get_tree().reload_current_scene()


func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	Global.in_death_state = false
	get_tree().change_scene_to_file(main_menu_scene_path)


func _on_death_timer_timeout() -> void:
	get_tree().paused = true

	game_over.update_score_labels(score)

	game_over.visible = true


func _on_kill_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		hud.hide()
		canvas_modulate.hide()
		Global.in_death_state = true

		if score > Global.best_score:
			Global.best_score = score

		var player_light: PointLight2D = body.get_node("PointLight2D")
		player_light.hide()

		for orb: Node2D in get_tree().get_nodes_in_group("orb"):
			var orb_light: PointLight2D = orb.get_node("PointLight2D")
			orb_light.hide()

		var flash_player: AnimationPlayer = death_flash.get_node("AnimationPlayer")
		death_flash.visible = true
		flash_player.play("flash")

		death_timer.start()

		var collider: CollisionPolygon2D = body.get_node("CollisionPolygon2D")
		collider.queue_free()

		var animated_sprite: AnimatedSprite2D = body.get_node("AnimatedSprite2D")
		animated_sprite.play("die")

		# This check is for code completion
		if body is CharacterBody2D:
			body.velocity = Vector2.ZERO
			body.velocity.y = death_hop_velocity

		await death_timer.timeout


func increment_score(amount: int) -> void:
	var score_label: Label = hud.get_node("%ScoreLabel")
	score += amount
	score_label.text = str(score)
