extends BaseButton

export var part_name: String
export var part_key: String
export var part_price: int

onready var _label_name := $VBoxContainer/Name
onready var _price := $VBoxContainer/Price
onready var _player_upgrades := get_node(@"/root/PlayerUpgrades")

func _ready() -> void:
	_label_name.text = part_name
	_price.set_money_value(part_price, false)

	var active := _player_upgrades.parts.get(part_key) as bool
	_set_buyable(!active)

	var err = _player_upgrades.parts.connect("part_changed", self, "_on_part_changed")
	assert(!err)

func _set_buyable(buyable: bool) -> void:
	self.disabled = !buyable
	_price.visible = buyable

func _on_buy_pressed() -> void:
	if _player_upgrades.remove_money(_price.money_value):
		_player_upgrades.parts.activate_by_key(part_key)
	else:
		# TODO: use a popup or something to notify the user
		pass

func _on_part_changed(key: String, active: bool) -> void:
	if key == part_key:
		_set_buyable(!active)
