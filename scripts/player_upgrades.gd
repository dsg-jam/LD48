extends Node

class UpgradeLevels:
	var speed: int
	var hull_strength: int
	var fuel_tank_size: int
	
	static func from_dict(d: Dictionary) -> UpgradeLevels:
		var levels := UpgradeLevels.new()
		levels.speed = d["speed"]
		levels.hull_strength = d["hull_strength"]
		levels.fuel_tank_size = d["fuel_tank_size"]
		return levels
	
	func to_dict() -> Dictionary:
		return {
			"speed": self.speed,
			"hull_strength": self.hull_strength,
			"fuel_tank_size": self.fuel_tank_size,
		}

const SAVE_FILEPATH := "user://upgrades.json"
var levels: UpgradeLevels

func _ready() -> void:
	var err := load_levels()
	if err:
		print("ERROR: failed to load upgrade levels: ", err)

func _exit_tree() -> void:
	var err := save_levels()
	if err:
		print("ERROR: failed to save upgrade levels: ", err)

func save_levels() -> int:
	var content := to_json(levels.to_dict())
	var file := File.new()
	# TODO: handle error
	var err := file.open(SAVE_FILEPATH, File.WRITE)
	if err:
		return err
	file.store_string(content)
	file.close()
	return OK

func load_levels() -> int:
	var file := File.new()
	# TODO: handle error
	var err := file.open(SAVE_FILEPATH, File.READ)
	if err:
		return err
	var content := file.get_as_text()
	file.close()
	
	levels = UpgradeLevels.from_dict(parse_json(content))
	return OK
