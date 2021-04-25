extends KinematicBody2D

export var active := false

var _velocity := Vector2.ZERO
var _drag_coefficient := 8.0
var _base_acceleration := Vector2(0.0, 100.0)
var _stuck_in: Node2D = null

onready var _particles := $Particles2D

func _physics_process(delta: float) -> void:
	if !active:
		return

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

func launch(strength: float) -> void:
	active = true
	_velocity = Vector2.RIGHT.rotated(self.rotation) * strength

func _calculate_drag(velocity: Vector2) -> Vector2:
	var inverse_direction := -velocity.normalized()
	return inverse_direction * velocity.length_squared() * _drag_coefficient

func _on_collision(collision: KinematicCollision2D) -> void:
	var collider := collision.collider as Node2D
	if collider.is_in_group("harpoon"):
		return

	_velocity = Vector2.ZERO
	_stuck_in = collider
	_particles.emitting = false
