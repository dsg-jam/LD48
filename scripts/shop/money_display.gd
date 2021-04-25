extends Control

export var show_player_money := false
export var money_value: int setget _set_money_value, _get_money_value

onready var _label_value := $Value
onready var _player_upgrades := get_node(@"/root/PlayerUpgrades")

func _ready() -> void:
	if show_player_money:
		_display_value(_player_upgrades.money)
		var err = _player_upgrades.connect("money_changed", self, "_on_money_changed")
		assert(!err)

func _display_value(value: int) -> void:
	_label_value.text = str(value)

func _on_money_changed() -> void:
	_display_value(_player_upgrades.money)

func _set_money_value(value: int) -> void:
	if show_player_money:
		_player_upgrades.money = value
		return

	_display_value(value)
	money_value = value

func _get_money_value() -> int:
	if show_player_money:
		return _player_upgrades.money

	return money_value
