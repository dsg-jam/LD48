extends Node2D

onready var player := $Player

const LEFT_BARRIER = -400
const RIGHT_BARRIER = 1300

var rng = RandomNumberGenerator.new()

# Load prefabs
var coin_prefab := preload("res://prefabs/coin.tscn")
var enemy_prefab := preload("res://prefabs/enemies/bully.tscn")

var height := 0.0


func enemy_hunting_speed():
	return exp(0.01 * (height / 100)) + 15


func get_enemy_spacing():
	return exp(-0.25 * (height / 100)) * 1000


func get_coin_spacing():
	return exp(-0.1 * (height / 100)) * 1500


func amount_of_enemies():
	return int(floor(exp(0.002 * (height / 10))))


func amount_of_coins():
	return int(floor(exp(0.0001 * (height / 10))))


func destroy_nodes() -> void:
	var destroyables = get_tree().get_nodes_in_group("destroyable")
	for destroyable in destroyables:
		var distance = destroyable.global_position - player.global_position
		if distance.y < -7500 or distance.y > 10000:
			destroyable.queue_free()


func enemy_spawn(spawn_pos : Vector2) -> void:
	var new_node = enemy_prefab.instance()
	new_node.position = spawn_pos
	new_node.hunting_speed = enemy_hunting_speed()
	get_tree().current_scene.add_child(new_node)


func coin_spawn(spawn_pos : Vector2) -> void:
	var new_node = coin_prefab.instance()
	new_node.position = spawn_pos
	get_tree().current_scene.add_child(new_node)


func enemy_spawn_manager() -> void:
	var nodes = get_tree().get_nodes_in_group("enemy")
	if len(nodes) != 0:
		var nearest_node = nodes[0]
		for node in nodes:
			if node.is_hunting:
				continue
			if node.global_position.distance_to(player.global_position) < nearest_node.global_position.distance_to(player.global_position):
				nearest_node = node
		if nearest_node.global_position.distance_to(player.global_position) < get_coin_spacing():
			return
	for _i in range(amount_of_enemies()):
		rng.randomize()
		enemy_spawn(Vector2(rng.randf_range(LEFT_BARRIER, RIGHT_BARRIER), rng.randf_range(height * 100 + 500, height * 100 + 2000)))


func coin_spawn_manager() -> void:
	var nodes = get_tree().get_nodes_in_group("coin")
	if len(nodes) > 1:
		var nearest_node = nodes[0]
		for node in nodes:
			if node.global_position.distance_to(player.global_position) < nearest_node.global_position.distance_to(player.global_position):
				nearest_node = node
		if nearest_node.global_position.distance_to(player.global_position) < get_enemy_spacing():
			return
	for _i in range(amount_of_coins()):
		rng.randomize()
		coin_spawn(Vector2(rng.randf_range(LEFT_BARRIER, RIGHT_BARRIER), rng.randf_range(height * 100 + 500, height * 100 + 2000)))


func _process(_delta):
	height = max(0, player.global_position.y / 100.0)
	get_node("CanvasLayer/VBoxContainer/HeightLabel").text = "%.1fm" % height
	
	coin_spawn_manager()
	enemy_spawn_manager()


func _on_DestroyTimer_timeout():
	destroy_nodes()
