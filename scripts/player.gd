extends CharacterBody2D

@export var animation_player: AnimationPlayer

@export_range(1, 10, 0.2) var gravity_multiplier: float = 2.0
@export_range(1, 10, 0.2) var dive_multiplier: float = 2.0
@export_range(-1000, 0, 0.2) var jump_velocity: float = -500.0


func _ready() -> void:
	animation_player.play("lose_vision")


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("dive"):
		velocity += get_gravity() * gravity_multiplier * dive_multiplier * delta
	else:
		velocity += get_gravity() * gravity_multiplier * delta

	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	move_and_slide()
