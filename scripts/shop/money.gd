extends Label

onready var label_money := self
onready var _player_upgrades := get_node(@"/root/PlayerUpgrades")

func _ready() -> void:
	label_money.text = str(_player_upgrades.money)
	var err = _player_upgrades.connect("money_changed", self, "_on_money_changed")
	assert(!err)

func _on_money_changed() -> void:
	label_money.text = str(_player_upgrades.money)
