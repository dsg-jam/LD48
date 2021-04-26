extends KinematicBody2D


export (int) var speed = 1000
export (int) var damage = 30

var _velocity := Vector2.ZERO

func fire(dir: Vector2):
	_velocity = dir.normalized()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	
	var collision := self.move_and_collide(_velocity * speed * delta)
	if collision:
		if collision.collider.name == "Player":
			self.queue_free()
			collision.collider.reduce_health(damage)
