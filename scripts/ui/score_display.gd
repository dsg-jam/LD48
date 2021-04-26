extends Container

var score: Score setget _set_score

onready var _label_depth := $HBoxContainer/Depth
onready var _money_display := $HBoxContainer/MoneyDisplay

func _set_score(new_score: Score) -> void:
	score = new_score
	_label_depth.text = "%.1f m" % score.depth
	_money_display.set_money_value(score.money, false)
