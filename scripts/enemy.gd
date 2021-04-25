extends KinematicBody2D

# Enemy controller

export (int) var idle_speed := 10
export (int) var hunting_speed := 15

export (float) var idle_acceleration := 0.01
export (float) var hunting_acceleration := 0.04

export (float) var friction = 0.01

export (float) var max_health = 100.0
export (float) var damage = 25.0

export (float) var bounce_rate = 50.0

onready var sprite := $AnimatedSprite
onready var health_bar := $Control/HealthBar

var health : float = max_health
var speed := idle_speed
var acceleration := idle_acceleration

var direction := Vector2(speed, 0)
var velocity := Vector2()

var player : KinematicBody2D
var is_hunting := false

var rng = RandomNumberGenerator.new()


func _ready():
	health_bar.visible = false


func hunting_velocity() -> Vector2:
	var x_direction = player.global_position.x - self.global_position.x
	var y_direction = player.global_position.y - self.global_position.y
	return Vector2(x_direction, y_direction).normalized() * speed


func calculate_velocity() -> Vector2:
	if direction.length() > 0:
		return velocity.linear_interpolate(direction, acceleration)
	return velocity.linear_interpolate(Vector2(), friction)


func rotate_enemy() -> void:
	if velocity.x < 0:
		sprite.set_flip_h(true)
		self.rotation = velocity.angle() + PI
	else:
		sprite.set_flip_h(false)
		self.rotation = velocity.angle()


func collision_control(collision) -> void:
	if collision:
		if collision.collider.name == "Player":
			velocity = velocity.bounce(collision.normal).normalized() * bounce_rate
			collision.collider.reduce_health(damage)
		else:
			direction.x *= -1
			velocity.x *= -1
			sprite.set_flip_h(!sprite.flip_h)


func _physics_process(delta):
	if is_hunting:
		direction = hunting_velocity()
	velocity = calculate_velocity()
	rotate_enemy()
	health_bar.value = range_lerp(health, 0, max_health, 0, 100)
	var collision = move_and_collide(velocity * speed * delta)
	collision_control(collision)


# Signals handler

func _on_Timer_timeout():
	rng.randomize()
	direction.y = rng.randf_range(-0.5, 0.5)


func _on_PlayerDetectionArea_body_entered(body):
	if body.name == "Player":
		player = body
		is_hunting = true
		speed = hunting_speed
		acceleration = hunting_acceleration


func _on_PlayerDetectionArea_body_exited(body):
	if body.name == "Player":
		is_hunting = false
		speed = idle_speed
		acceleration = idle_acceleration


func _on_HealthBarTimer_timeout():
	health_bar.visible = false
