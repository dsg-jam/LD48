extends KinematicBody2D

var _velocity := Vector2(400.0, -400.0)
var _acceleration := Vector2(0.0, 50.0)
var _stuck_in: Node2D = null

onready var _particles := $Particles2D

func _physics_process(delta: float) -> void:
	if _stuck_in:
		return

	_velocity += _acceleration * delta
	var collision := self.move_and_collide(_velocity * delta)
	if collision:
		_on_collision(collision)
	else:
		self.look_at(self.position + _velocity)

func _on_collision(collision: KinematicCollision2D) -> void:
	_velocity = Vector2.ZERO
	_stuck_in = collision.collider
	_particles.emitting = false
