extends Container

export var upgrade_key: String
export var upgrade_name: String
export var price_start: int
export var price_end: int
export var price_steps: int = 5

var _exp_a: float
var _exp_b: float

onready var label_name := $Name
onready var label_next_level := $NextLevel
onready var label_price := $Price
onready var _player_upgrades := get_node(@"/root/PlayerUpgrades")

func _ready() -> void:
	_exp_b = log(float(price_end) / float(price_start)) / log(price_steps - 1)
	_exp_a = float(price_start) / _exp_b

	var level := _player_upgrades.levels.get(upgrade_key) as int

	label_name.text = upgrade_name
	_update_for_level(level)

	var err = _player_upgrades.levels.connect("level_changed", self, "_on_upgrade_level_changed")
	assert(!err)

func _price_for_level(level: int) -> int:
	return int(floor(_exp_a * pow(_exp_b, level)))

func _update_for_level(level: int) -> void:
	label_next_level.text = str(level + 1)
	label_price.text = str(_price_for_level(level + 1))

func _on_UpgradeButton_pressed() -> void:
	var level := _player_upgrades.levels.get(upgrade_key) as int
	if level == null:
		return

	var price := _price_for_level(level + 1)
	if _player_upgrades.remove_money(price):
		_player_upgrades.levels.increment_by_key(upgrade_key)
	else:
		# TODO: use a popup or something to notify the user
		pass

func _on_upgrade_level_changed(key: String, level: int) -> void:
	if key == upgrade_key:
		_update_for_level(level)
