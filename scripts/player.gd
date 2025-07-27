extends CharacterBody2D

@export var animation_player: AnimationPlayer
@export var animated_sprite: AnimatedSprite2D

@export_range(1, 10, 0.2) var gravity_multiplier: float = 2.0
@export_range(1, 10, 0.2) var dive_multiplier: float = 2.0
@export_range(-1000, 0, 0.2) var jump_velocity: float = -500.0


func _ready() -> void:
	animation_player.play("lose_vision")


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("dive") and not Global.in_death_state:
		velocity += get_gravity() * gravity_multiplier * dive_multiplier * delta

		animated_sprite.play("dive")
	else:
		velocity += get_gravity() * gravity_multiplier * delta

		if not animated_sprite.animation == "flap" and not Global.in_death_state:
			animated_sprite.play("idle")

	if Input.is_action_just_pressed("flap") and not Global.in_death_state:
		velocity.y = jump_velocity

		if not Input.is_action_pressed("dive"):
			animated_sprite.stop()
			animated_sprite.play("flap")
			animated_sprite.animation_finished.connect(func() -> void: animated_sprite.play("idle"))

	move_and_slide()
