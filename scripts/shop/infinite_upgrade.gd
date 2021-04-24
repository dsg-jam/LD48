tool
extends Container

export var upgrade_name: String
onready var label_name := $Name
onready var label_current_level := $CurrentLevel

func _ready() -> void:
	label_name.text = upgrade_name
