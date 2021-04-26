extends Control

export var scene_playground: PackedScene
export var scene_shop: PackedScene

onready var _score_current := $VBoxContainer/HBoxContainer/Current/ScoreDisplay
onready var _score_best := $VBoxContainer/HBoxContainer/Best/ScoreDisplay
onready var _player_upgrades := get_node(@"/root/PlayerUpgrades")

func _ready() -> void:
	_score_current.score = _player_upgrades.current_score
	_score_best.score = _player_upgrades.highscore

func _exit_tree() -> void:
	_player_upgrades.update_highscore()

func _on_RestartButton_pressed() -> void:
	var err := get_tree().change_scene_to(scene_playground)
	assert(!err) 

func _on_ShopButton_pressed() -> void:
	var err := get_tree().change_scene_to(scene_shop)
	assert(!err)
