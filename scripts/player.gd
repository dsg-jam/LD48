extends KinematicBody2D

const Harpoon := preload("./harpoon.gd")

export var prefab_harpoon: PackedScene
export (int) var speed = 15
export (float) var friction = 0.05
export (float) var acceleration = 0.02
export (float) var max_health = 100.0


export (float) var speed_rate := 1.0
export (float) var damage_reduction_rate := 1.0


onready var sprite := $AnimatedSprite
onready var health_bar := $Control/HealthBar
onready var _player_upgrades := get_node(@"/root/PlayerUpgrades")

var health : float = max_health
var velocity := Vector2()
var input_velocity := Vector2()
var damage_in_progress = false
var _aiming: bool
var _harpoon: Harpoon = null

func _ready():
	health_bar.visible = false
	speed += 2 * _player_upgrades.levels.speed
	damage_reduction_rate = _player_upgrades.levels.hull_strength
	

func get_input() -> void:
	input_velocity = Vector2()
	if Input.is_action_pressed("right"):
		input_velocity.x += 2
	if Input.is_action_pressed("left"):
		input_velocity.x -= 2
	if Input.is_action_pressed("up"):
		input_velocity.y -= 1
	if Input.is_action_pressed("down"):
		input_velocity.y += 1.5
	input_velocity = input_velocity * speed


func calculate_velocity() -> Vector2:
	if not _aiming and input_velocity.length() > 0:
		return velocity.linear_interpolate(input_velocity, acceleration)
	return velocity.linear_interpolate(Vector2(), friction)


func game_over():
	var _err := get_tree().change_scene("res://scenes/game_over_menu.tscn")


func reduce_health(amount) -> void:
	if damage_in_progress:
		return
	$AnimatedSprite.animation = "damage"
	health -= amount / damage_reduction_rate
	health_bar.value = range_lerp(health, 0, max_health, 0, 100)
	if health <= 0:
		game_over()
	damage_in_progress = true
	health_bar.visible = true
	$DamageTimer.start()
	if health/max_health > 0.3:
		$HealthBarTimer.start()


func rotate_player() -> void:
	if velocity.x < 0:
		sprite.set_flip_h(true)
		self.rotation = velocity.angle() + PI
	else:
		sprite.set_flip_h(false)
		self.rotation = velocity.angle()

func _process(_delta: float) -> void:
	if Input.is_action_pressed("aim"):
		_aiming = true
		_process_aiming()
	elif _aiming:
		_aiming = false
		_launch_harpoon()

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

func _process_aiming() -> void:
	if not _harpoon:
		_harpoon = prefab_harpoon.instance()
		get_tree().current_scene.add_child(_harpoon)

	_harpoon.global_position = self.global_position
	_harpoon.look_at(_harpoon.global_position + _get_aiming_input())

func _launch_harpoon() -> void:
	assert(_harpoon)
	_harpoon.launch(700.0)
	_harpoon = null

func _on_DamageTimer_timeout():
	damage_in_progress = false

func _get_aiming_input() -> Vector2:
	return Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)

func _on_CoinDetectionArea_area_entered(area):
	if area.get_parent().is_in_group("coin"):
		_player_upgrades.money += 1
		area.get_parent().queue_free()


func _on_HealthBarTimer_timeout():
	health_bar.visible = false
