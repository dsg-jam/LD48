extends KinematicBody2D

var _velocity := Vector2(500.0, -50.0)
var _drag_coefficient := 10.0
var _base_acceleration := Vector2(0.0, 200.0)
var _stuck_in: Node2D = null

onready var _particles := $Particles2D

func _physics_process(delta: float) -> void:
	if _stuck_in:
		return

	var acceleration := _base_acceleration
	var drag := _calculate_drag(_velocity * delta)
	acceleration += drag

	_velocity += acceleration * delta
	var collision := self.move_and_collide(_velocity * delta)
	if collision:
		_on_collision(collision)
	else:
		self.look_at(self.position + _velocity)

func _calculate_drag(velocity: Vector2) -> Vector2:
	var inverse_direction := -velocity.normalized()
	return inverse_direction * velocity.length_squared() * _drag_coefficient

func _on_collision(collision: KinematicCollision2D) -> void:
	_velocity = Vector2.ZERO
	_stuck_in = collision.collider
	_particles.emitting = false
