extends Control

export var show_player_money := false
export var money_value: int setget set_money_value, _get_money_value

onready var _animation_player := $AnimationPlayer
onready var _timer := $Timer
onready var _label_value := $HBoxContainer/Value
onready var _texture_rect := $HBoxContainer/AspectRatioContainer/TextureRect
onready var _player_upgrades := get_node(@"/root/PlayerUpgrades")

func _ready() -> void:
	if show_player_money:
		_display_value(_player_upgrades.money, false)
		var err = _player_upgrades.connect("money_changed", self, "_on_money_changed")
		assert(!err)

func set_money_value(value: int, animate: bool = true) -> void:
	if show_player_money:
		_player_upgrades.money = value
		return

	_display_value(value, animate)
	money_value = value

func _display_value(value: int, animate: bool) -> void:
	_label_value.text = str(value)
	if animate:
		_animate_spin()

func _current_animation_loop(loop: bool) -> void:
	_animation_player.get_animation(_animation_player.current_animation).loop = loop

func _animate_spin() -> void:
	_texture_rect.rect_pivot_offset = _texture_rect.rect_size / 2
	_animation_player.play("spin")
	_current_animation_loop(true)
	_timer.start(0.5)

func _on_money_changed() -> void:
	_display_value(_player_upgrades.money, true)

func _get_money_value() -> int:
	if show_player_money:
		return _player_upgrades.money

	return money_value

func _on_Timer_timeout():
	_current_animation_loop(false)
