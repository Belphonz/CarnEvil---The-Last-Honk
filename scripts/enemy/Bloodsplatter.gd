extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	rotation = randf_range(-180,180)
	play("Default",3,false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
