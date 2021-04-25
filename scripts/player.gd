extends KinematicBody2D

const Harpoon := preload("./harpoon.gd")

const HARPOON_BASE_POWER := 250.0
const HARPOON_POWER_PER_SEC := 800.0
const HARPOON_MAX_POWER := 5000.0

export var prefab_harpoon: PackedScene
export (int) var speed = 15
export (float) var friction = 0.05
export (float) var acceleration = 0.02
export (float) var max_health = 100.0
export (float) var speed_rate := 1.0
export (float) var damage_reduction_rate := 1.0
export var harpoon_inventory_size: int = 3

onready var sprite := $AnimatedSprite
onready var health_bar := $Control/HealthBar
onready var health : float = max_health
onready var _timer_harpoon_cooldown := $HarpoonCooldown
onready var _player_upgrades := get_node(@"/root/PlayerUpgrades")
onready var _harpoon_count: int = harpoon_inventory_size

var velocity := Vector2()
var input_velocity := Vector2()
var damage_in_progress = false
# Must never be 0
var _aiming_direction_raw := Vector2.RIGHT
var _aiming: bool
var _harpoon: Harpoon = null
var _harpoon_power: float
var _harpoon_cooldown: bool = false

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
	if velocity.x < 0.0:
		sprite.set_flip_h(true)
		self.rotation = velocity.angle() + PI
	else:
		if velocity.length_squared() > 0.0:
			sprite.set_flip_h(false)
		self.rotation = velocity.angle()

func _process(delta: float) -> void:
	var input := _get_input()
	if input.length_squared() > 0.0:
		_aiming_direction_raw = input

	var has_harpoon: bool = _player_upgrades.parts.harpoon and _harpoon_count and not _harpoon_cooldown
	if has_harpoon and Input.is_action_pressed("aim"):
		_aiming = true
		_process_aiming(delta)
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
	if (_aiming or input_velocity == Vector2.ZERO) and velocity.length() < 10:
			velocity = Vector2()
			$AnimatedSprite.animation = "idle"
	else:
		$AnimatedSprite.animation = "swimming"

func _process_aiming(delta: float) -> void:
	if not _harpoon:
		_harpoon = prefab_harpoon.instance()
		get_tree().current_scene.add_child(_harpoon)
		_harpoon_power = HARPOON_BASE_POWER

	_harpoon.global_position = self.global_position
	_harpoon.look_at(_harpoon.global_position + _aiming_direction_raw)
	_harpoon_power = min(HARPOON_MAX_POWER, _harpoon_power + HARPOON_POWER_PER_SEC * delta)

func _launch_harpoon() -> void:
	assert(_harpoon and _harpoon_count and not _harpoon_cooldown)
	_harpoon.launch(_harpoon_power)
	_harpoon = null
	
	_harpoon_count -= 1
	_harpoon_cooldown = true
	_timer_harpoon_cooldown.start()

func _on_DamageTimer_timeout():
	damage_in_progress = false

func _get_input() -> Vector2:
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

func _on_HarpoonReload_timeout() -> void:
	_harpoon_count = int(min(harpoon_inventory_size, _harpoon_count + 1))

func _on_HarpoonCooldown_timeout() -> void:
	_harpoon_cooldown = false
