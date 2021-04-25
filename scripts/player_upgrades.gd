extends Node

class Parts:
	signal part_changed(key, active)

	var light: bool
	var harpoon: bool
	
	func activate_by_key(key: String) -> void:
		if self.get(key) == null:
			push_warning("tried activating non-existant key: %s" % key)
			return

		self.set(key, true)
		emit_signal("part_changed", key, true)

class UpgradeLevels:
	signal level_changed(key, level)

	var speed: int
	var hull_strength: int
	var fuel_tank_size: int

	func increment_by_key(key: String) -> void:
		var value := self.get(key) as int
		if value == null:
			push_warning("tried incrementing non-existant key: %s" % key)
			return

		value += 1
		self.set(key, value)
		emit_signal("level_changed", key, value)

signal money_changed

const SAVE_FILEPATH := "user://upgrades.json"

var levels := UpgradeLevels.new()
var parts := Parts.new()
var money: int = 0 setget _set_money

func _ready() -> void:
	var err := load_from_file()
	if err == ERR_FILE_NOT_FOUND:
		print("no save file to load yet")
	elif err:
		push_error("failed to load upgrade levels: %s" % err)

func _exit_tree() -> void:
	var err := save_to_file()
	if err:
		push_error("failed to save upgrade levels: %s" % err)

func remove_money(amount: int) -> bool:
	if money < amount:
		return false

	_set_money(money - amount)
	return true

func save_to_file() -> int:
	var content := to_json({
		"levels": _obj2dict(levels),
		"parts": _obj2dict(parts),
		"money": money,
	})
	var file := File.new()
	var err := file.open(SAVE_FILEPATH, File.WRITE)
	if err:
		return err
	file.store_string(content)
	file.close()
	return OK

func load_from_file() -> int:
	var file := File.new()
	var err := file.open(SAVE_FILEPATH, File.READ)
	if err:
		return err

	var raw_content := file.get_as_text()
	file.close()
	
	var content := parse_json(raw_content) as Dictionary
	
	_update_obj_from_dict(levels, content.get("levels", {}))
	_update_obj_from_dict(parts, content.get("parts", {}))
	money = content.get("money", 0)
	return OK


static func _obj2dict(obj: Object) -> Dictionary:
	var d := {}
	for prop in obj.get_property_list():
		if not prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			continue
		d[prop.name] = obj[prop.name]

	return d

static func _update_obj_from_dict(obj: Object, d: Dictionary) -> void:
	for prop in obj.get_property_list():
		if not prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			continue
		obj.set(prop.name, d.get(prop.name, false))


func _set_money(value: int) -> void:
	assert(value > 0)

	money = value
	emit_signal("money_changed")
