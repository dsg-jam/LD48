extends Node2D


onready var player := $Player

# Load prefabs
var coin_prefab := preload("res://prefabs/coin.tscn")

var height := 0


func _ready():
	generate_coin(Vector2(0,0))

func destroy_nodes():
	var destroyables = get_tree().get_nodes_in_group("destroyable")
	for destroyable in destroyables:
		print((destroyable.global_position - player.global_position).length())
		if (destroyable.global_position - player.global_position).length() > 7500:
			destroyable.queue_free()

func generate_coin(coin_pos : Vector2):
	var new_coin = coin_prefab.instance()
	new_coin.position = coin_pos
	get_tree().current_scene.add_child(new_coin)


func _process(delta):
	height = max(0, floor(player.global_position.y / 100))
	get_node("CanvasLayer/VBoxContainer/HeightLabel").text = str(height) + " m"


func _on_DestroyTimer_timeout():
	destroy_nodes()
