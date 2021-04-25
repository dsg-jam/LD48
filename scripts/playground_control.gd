extends Node2D


onready var player := $Player

const LEFT_BARRIER = -400
const RIGHT_BARRIER = 1300

var rng = RandomNumberGenerator.new()

# Load prefabs
var coin_prefab := preload("res://prefabs/coin.tscn")

var height := 0


func _ready():
	generate_coin(Vector2(0,0))

func destroy_nodes():
	var destroyables = get_tree().get_nodes_in_group("destroyable")
	for destroyable in destroyables:
		var distance = destroyable.global_position - player.global_position
		if distance.y < -7500 or distance.y > 1000:
			destroyable.queue_free()


func generate_coin(coin_pos : Vector2):
	var new_coin = coin_prefab.instance()
	new_coin.position = coin_pos
	get_tree().current_scene.add_child(new_coin)


func _process(delta):
	height = max(0, floor(player.global_position.y / 100))
	get_node("CanvasLayer/VBoxContainer/HeightLabel").text = str(height) + " m"
	
#	if height % 15 == 0:
#		rng.randomize()
#		generate_coin(Vector2(rng.randf_range(LEFT_BARRIER, RIGHT_BARRIER), height * 100))


func _on_DestroyTimer_timeout():
	destroy_nodes()
