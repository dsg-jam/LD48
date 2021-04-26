extends KinematicBody2D

const DAMAGE_PER_SPEED := 0.001

export var active := false
export var base_damage := 50.0

var _velocity := Vector2.ZERO
var _drag_coefficient := 5.0
var _base_acceleration := Vector2(0.0, 100.0)
var _stuck_in: Node2D = null

onready var _particles := $Particles2D
onready var _collision_shape := $CollisionShape2D

func _physics_process(delta: float) -> void:
	if (not active) or _stuck_in:
		return

	var acceleration := _base_acceleration
	var drag := _calculate_drag(_velocity * delta)
	acceleration += drag

	_velocity += acceleration * delta
	var collision := self.move_and_collide(_velocity * delta)
	if collision:
		_on_collision(delta, collision)
	else:
		self.look_at(self.position + _velocity)

func launch(strength: float) -> void:
	active = true
	_collision_shape.disabled = false
	_velocity = Vector2.RIGHT.rotated(self.rotation) * strength

func boost(velocity: Vector2) -> void:
	_velocity += velocity

func _calculate_drag(velocity: Vector2) -> Vector2:
	var inverse_direction := -velocity.normalized()
	return inverse_direction * velocity.length_squared() * _drag_coefficient

func _on_collision(delta: float, collision: KinematicCollision2D) -> void:
	var collider := collision.collider as Node2D
	if collider.is_in_group("harpoon"):
		var v := _velocity / 3.0
		collider.boost(v)
		_velocity = v.bounce(collision.normal)
		return

	if collider.is_in_group("enemy"):
		var damage := base_damage * _velocity.length() * DAMAGE_PER_SPEED
		collider.reduce_health(damage)
		collider.velocity += _velocity * delta
		self.queue_free()
		return

	_velocity = Vector2.ZERO
	_stuck_in = collider
	_particles.emitting = false
