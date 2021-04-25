extends Node2D

onready var player := $Player

const LEFT_BARRIER = -400
const RIGHT_BARRIER = 1300

var rng = RandomNumberGenerator.new()

# Load prefabs
var prefabs := {"coin": preload("res://prefabs/coin.tscn"), "enemy": preload("res://prefabs/enemies/bully.tscn")}

var height := 0.0


func destroy_nodes() -> void:
	var destroyables = get_tree().get_nodes_in_group("destroyable")
	for destroyable in destroyables:
		var distance = destroyable.global_position - player.global_position
		if distance.y < -7500 or distance.y > 1000:
			destroyable.queue_free()


func spawn(group : String, spawn_pos : Vector2) -> void:
	var new_node = prefabs[group].instance()
	new_node.position = spawn_pos
	get_tree().current_scene.add_child(new_node)


func enemy_spawn_manager(offset : int, spacing : int, group : String) -> void:
	if int(height) % offset == 0:
		var nodes = get_tree().get_nodes_in_group(group)
		if len(nodes) != 0:
			var nearest_node = nodes[0]
			for node in nodes:
				if node.is_hunting:
					continue
				if node.global_position.distance_to(player.global_position) < nearest_node.global_position.distance_to(player.global_position):
					nearest_node = node
			if nearest_node.global_position.distance_to(player.global_position) < spacing:
				return
		rng.randomize()
		spawn(group, Vector2(rng.randf_range(LEFT_BARRIER, RIGHT_BARRIER), rng.randf_range(height * 100 + 500, height * 100 + 1500)))


func coin_spawn_manager(offset : int, spacing : int, group : String) -> void:
	if int(height) % offset == 0:
		var nodes = get_tree().get_nodes_in_group(group)
		if len(nodes) > 1:
			var nearest_node = nodes[0]
			for node in nodes:
				if node.global_position.distance_to(player.global_position) < nearest_node.global_position.distance_to(player.global_position):
					nearest_node = node
			if nearest_node.global_position.distance_to(player.global_position) < spacing:
				return
		rng.randomize()
		spawn(group, Vector2(rng.randf_range(LEFT_BARRIER, RIGHT_BARRIER), rng.randf_range(height * 100 + 500, height * 100 + 1500)))


func _process(_delta):
	height = max(0, player.global_position.y / 100.0)
	get_node("CanvasLayer/VBoxContainer/HeightLabel").text = "%.1fm" % height
	
	coin_spawn_manager(15, 1500, "coin")
	enemy_spawn_manager(25, 1500, "enemy")


func _on_DestroyTimer_timeout():
	destroy_nodes()
