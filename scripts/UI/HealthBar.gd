extends Node2D

var _healthBar:TextureProgressBar
var _barRed = preload("res://assets/gfx/UI/HealthBar/HealthBarRed.png")
var _barYellow = preload("res://assets/gfx/UI/HealthBar/HealthBarYellow.png")
var _barGreen = preload("res://assets/gfx/UI/HealthBar/HealthBarGreen.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	_healthBar = get_node("TextureProgressBar")
	

func setHealth(_health:float, maxHealth:float):
	var value = _health/maxHealth
	_healthBar.texture_progress = _barGreen
	if(value < 1 * 0.7):
		_healthBar.texture_progress = _barYellow
	if(value < 1 * 0.35):
		_healthBar.texture_progress = _barRed
	_healthBar.value = value
	_healthBar.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
