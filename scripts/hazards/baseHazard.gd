extends Node2D

var _active:bool = false

func Place(location:Vector2):
	set_global_position(location)
	_active = true
	
func Destroy():
	pass
	
func Collide(colliding:Node2D):
	pass
