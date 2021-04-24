extends Node

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
	
	static func from_dict(d: Dictionary) -> UpgradeLevels:
		var levels := UpgradeLevels.new()
		levels.speed = d.get("speed", 0)
		levels.hull_strength = d.get("hull_strength", 0)
		levels.fuel_tank_size = d.get("fuel_tank_size", 0)
		return levels
	
	func to_dict() -> Dictionary:
		return {
			"speed": self.speed,
			"hull_strength": self.hull_strength,
			"fuel_tank_size": self.fuel_tank_size,
		}

signal money_changed
const SAVE_FILEPATH := "user://upgrades.json"
var levels: UpgradeLevels
var money: int

func _ready() -> void:
	var err := load_from_file()
	if err:
		push_error("failed to load upgrade levels: %s" % err)

func _exit_tree() -> void:
	var err := save_to_file()
	if err:
		push_error("failed to save upgrade levels: %s" % err)

func remove_money(amount: int) -> bool:
	if money < amount:
		return false

	money -= amount
	emit_signal("money_changed")
	return true

func save_to_file() -> int:
	var content := to_json({
		"levels": levels.to_dict(),
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
	
	levels = UpgradeLevels.from_dict(content.get("levels", {}))
	money = content.get("money", 0)
	return OK
