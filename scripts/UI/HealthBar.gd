extends Node2D

var healthBar:TextureProgressBar

@export_range(0,6)
var health:float=5
var maxHealth:float=6.0

var bar_red = preload("res://assets/gfx/UI/HealthBar/HealthBarRed.png")
var bar_yellow = preload("res://assets/gfx/UI/HealthBar/HealthBarYellow.png")
var bar_green = preload("res://assets/gfx/UI/HealthBar/HealthBarGreen.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	healthBar=get_node("TextureProgressBar")
	

func setHealth(_health:float, maxHealth:float):
	var value=_health/maxHealth
	healthBar.texture_progress = bar_green
	if(value < 1 * 0.7):
		healthBar.texture_progress = bar_yellow
	if(value < 1 * 0.35):
		healthBar.texture_progress = bar_red
	healthBar.value=value
	healthBar.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
