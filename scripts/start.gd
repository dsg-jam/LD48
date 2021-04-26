extends Control

export var scene_playground: PackedScene

func _on_Button_pressed() -> void:
	var err := get_tree().change_scene_to(scene_playground)
	assert(!err) 
