extends KinematicBody2D

export (int) var speed = 15
export (float) var friction = 0.01
export (float) var acceleration = 0.02
export (float) var health = 100.0

onready var sprite := $AnimatedSprite
var velocity := Vector2()
var input_velocity := Vector2()
var vertical_velocity := 0.0

var rng = RandomNumberGenerator.new()

var direction := 1


func get_input():
	input_velocity = Vector2(direction, vertical_velocity)
	input_velocity = input_velocity * speed


func _ready():
	pass # Replace with function body.

func calculate_velocity() -> Vector2:
	if input_velocity.length() > 0:
		return velocity.linear_interpolate(input_velocity, acceleration)
	return velocity.linear_interpolate(Vector2(), friction)

func _physics_process(delta):
	get_input()
	velocity = calculate_velocity()
	var collision_info = move_and_collide(velocity * speed * delta)
	if collision_info:
		direction *= -1
		velocity.x *= -1
		sprite.set_flip_h(!sprite.flip_h)


func _on_Timer_timeout():
	rng.randomize()
	vertical_velocity = rng.randf_range(-0.5, 0.5)
