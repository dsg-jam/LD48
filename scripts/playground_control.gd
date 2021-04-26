extends Node2D

const LEFT_BARRIER = -400
const RIGHT_BARRIER = 1300

export var _label_height_path: NodePath
export var _money_display_path: NodePath

var rng = RandomNumberGenerator.new()
var _player_depth: float = 0.0

# Load prefabs
var coin_prefab := preload("res://prefabs/coin.tscn")
var enemy_prefab := preload("res://prefabs/enemies/bully.tscn")

onready var player := $Player
onready var _label_height := get_node(_label_height_path)
onready var _money_display := get_node(_money_display_path)
onready var _player_upgrades := get_node(@"/root/PlayerUpgrades")
onready var _player_money_at_start: int = _player_upgrades.money

func _ready() -> void:
	_money_display.set_money_value(0, false)
	var err = _player_upgrades.connect("money_changed", self, "_on_player_money_changed")
	assert(!err)

func _exit_tree() -> void:
	var score = Score.new()
	score.depth = _player_depth
	score.money = _player_upgrades.money - _player_money_at_start
	_player_upgrades.current_score = score

func _process(_delta) -> void:
	_player_depth = max(0, player.global_position.y / 100.0)
	_label_height.text = "%.1f m" % _player_depth
	
	coin_spawn_manager(_player_depth)
	enemy_spawn_manager(_player_depth)

func enemy_hunting_speed(depth : float) -> float:
	return exp(0.025 * (depth)) + 15


func amount_of_enemies(depth : float) -> int:
	return int(floor(exp(0.015 * depth)))


func amount_of_coins(depth : float) -> int:
	return int(floor(exp(0.01 * depth)))


func destroy_nodes() -> void:
	var destroyables = get_tree().get_nodes_in_group("destroyable")
	for destroyable in destroyables:
		var distance = destroyable.global_position - player.global_position
		if distance.y < -7500 or distance.y > 10000:
			destroyable.queue_free()


func enemy_spawn(depth : float, spawn_pos : Vector2) -> void:
	var new_node = enemy_prefab.instance()
	new_node.position = spawn_pos
	new_node.hunting_speed = enemy_hunting_speed(depth)
	get_tree().current_scene.add_child(new_node)


func coin_spawn(_depth : float, spawn_pos : Vector2) -> void:
	var new_node = coin_prefab.instance()
	new_node.position = spawn_pos
	get_tree().current_scene.add_child(new_node)


func enemy_spawn_manager(depth : float) -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	var enemies_below_player = 0
	var player_depth = player.global_position.y
	if len(enemies) != 0:
		for enemy in enemies:
			if enemy.global_position.y > player.global_position.y:
				enemies_below_player += 1
	var number_of_additional_enemies = amount_of_enemies(depth) - enemies_below_player
	if number_of_additional_enemies <= 0:
		return
	for _i in range(number_of_additional_enemies):
		rng.randomize()
		enemy_spawn(depth, Vector2(rng.randf_range(LEFT_BARRIER, RIGHT_BARRIER), rng.randf_range(player_depth + 500, player_depth + 2500)))


func coin_spawn_manager(depth : float) -> void:
	var coins = get_tree().get_nodes_in_group("coin")
	var coins_below_player = 0
	var player_depth = player.global_position.y
	if len(coins) != 0:
		for coin in coins:
			if coin.global_position.y > player.global_position.y:
				coins_below_player += 1
	var number_of_additional_coins = amount_of_coins(depth) - coins_below_player
	if number_of_additional_coins <= 0:
		return
	for _i in range(number_of_additional_coins):
		rng.randomize()
		coin_spawn(depth, Vector2(rng.randf_range(LEFT_BARRIER, RIGHT_BARRIER), rng.randf_range(player_depth + 500, player_depth + 2500)))

func _on_player_money_changed() -> void:
	_money_display.set_money_value(_player_upgrades.money - _player_money_at_start)

func _on_DestroyTimer_timeout() -> void:
	destroy_nodes()
