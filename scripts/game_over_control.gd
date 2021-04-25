extends Control


func _on_RestartButton_pressed():
	get_tree().change_scene("res://scenes/playground.tscn")


func _on_ShopButton_pressed():
	print("shop")
