extends KinematicBody2D

export (int) var speed = 200
export (float) var friction = 0.01
export (float) var acceleration = 0.02
export (float) var health = 100.0

var velocity := Vector2()
var input_velocity := Vector2()

func get_input():
	input_velocity = Vector2()
	if Input.is_action_pressed('right'):
		input_velocity.x += 2
	if Input.is_action_pressed('left'):
		input_velocity.x -= 2
	if Input.is_action_pressed('up'):
		input_velocity.y -= 1
	if Input.is_action_pressed('down'):
		input_velocity.y += 1.5
	input_velocity = input_velocity * speed


func calculate_velocity() -> Vector2:
	if input_velocity.length() > 0:
		return velocity.linear_interpolate(input_velocity, acceleration)
	return velocity.linear_interpolate(Vector2(), friction)


func _physics_process(delta):
	get_input()
	velocity = move_and_slide(calculate_velocity())
