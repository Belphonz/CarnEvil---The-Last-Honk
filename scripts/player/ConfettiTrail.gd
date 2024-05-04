extends Sprite2D

@export var LIFESPAN : float = 10
var _lifespanTimer = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	rotation = randf_range(-180,180)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _lifespanTimer > LIFESPAN:
		queue_free()
	_lifespanTimer += delta
