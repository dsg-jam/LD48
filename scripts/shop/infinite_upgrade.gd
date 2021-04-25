extends Container

export var upgrade_key: String
export var upgrade_name: String
export var price_start: int
export var price_end: int
export var price_steps: int = 5

var _exp_a: float
var _exp_b: float

onready var _label_name := $Name
onready var _label_next_level := $NextLevel
onready var _price := $Price
onready var _player_upgrades := get_node(@"/root/PlayerUpgrades")

func _ready() -> void:
	assert(price_start and price_end)

	_exp_b = log(float(price_end) / float(price_start)) / log(price_steps - 1)
	_exp_a = float(price_start) / _exp_b

	_label_name.text = upgrade_name
	var level := _player_upgrades.levels.get(upgrade_key) as int
	_update_for_level(level, false)

	var err = _player_upgrades.levels.connect("level_changed", self, "_on_upgrade_level_changed")
	assert(!err)

func _price_for_level(level: int) -> int:
	return int(floor(_exp_a * pow(_exp_b, level)))

func _update_for_level(level: int, animate: bool) -> void:
	_label_next_level.text = str(level + 1)
	_price.set_money_value(_price_for_level(level + 1), animate)

func _on_UpgradeButton_pressed() -> void:
	if _player_upgrades.remove_money(_price.money_value):
		_player_upgrades.levels.increment_by_key(upgrade_key)
	else:
		# TODO: use a popup or something to notify the user
		pass

func _on_upgrade_level_changed(key: String, level: int) -> void:
	if key == upgrade_key:
		_update_for_level(level, true)
