extends Control

export var scene_playground: PackedScene
export var scene_shop: PackedScene

func _on_RestartButton_pressed() -> void:
	var err := get_tree().change_scene_to(scene_playground)
	assert(!err) 

func _on_ShopButton_pressed() -> void:
	var err := get_tree().change_scene_to(scene_shop)
	assert(!err)
