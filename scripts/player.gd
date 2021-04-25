extends KinematicBody2D

export (int) var speed = 15
export (float) var friction = 0.05
export (float) var acceleration = 0.02
export (float) var health = 100.0

onready var sprite := $AnimatedSprite

var velocity := Vector2()
var input_velocity := Vector2()

var damage_in_progress = false

func get_input() -> void:
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


func game_over():
	var _err := get_tree().change_scene("res://scenes/game_over_menu.tscn")


func reduce_health(amount) -> void:
	$AnimatedSprite.animation = "damage"
	damage_in_progress = true
	$DamageTimer.start()
	health -= amount
	if health <= 0:
		game_over()

func rotate_player() -> void:
	if velocity.x < 0:
		sprite.set_flip_h(true)
		self.rotation = velocity.angle() + PI
	else:
		sprite.set_flip_h(false)
		self.rotation = velocity.angle()



func _physics_process(delta):
	get_input()
	velocity = calculate_velocity()
	var _collision := move_and_collide(velocity * speed * delta)
	rotate_player()
	if damage_in_progress:
		return
	if input_velocity == Vector2.ZERO and velocity.length() < 10:
			velocity = Vector2()
			$AnimatedSprite.animation = "idle"
	else:
		$AnimatedSprite.animation = "swimming"


func _on_DamageTimer_timeout():
	damage_in_progress = false


func _on_CoinDetectionArea_area_entered(area):
	if area.get_parent().get_node("Coin"):
		area.get_parent().queue_free()
