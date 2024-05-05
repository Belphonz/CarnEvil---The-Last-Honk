extends "res://scripts/Hazards/BaseHazard.gd"

var _damage : float
var _airTime:float
var _maxCurveHeight:float

var _startThrow:Vector2
var _endThrow:Vector2
var _timeInAir:float = 0

func Throw(start:Vector2, location:Vector2):
	_active = false
	_startThrow = start
	global_position = start
	_endThrow = location

func _process(delta):
	if(!_active):	#Being thrown
		_timeInAir += delta	
		if(_timeInAir > _airTime):	#Landed
			_active = true
			Place(_endThrow)
			return
			
		var pointInCurve:float = _timeInAir / _airTime	#How far in the curve from 0-1
		var position:Vector2 = lerp(_startThrow,_endThrow,pointInCurve)
		var yOffset:float = pointInCurve * -4.0 * _maxCurveHeight * (1.0 - pointInCurve)	#Calculate y offset to add for curve
		position.y += yOffset
		set_global_position(position)

func Place(location:Vector2):
	super.Place(location)

func Destroy():
	super.Destroy()

func collide(colliding:Node2D):
	if(!_active):
		return
	super.Collide(colliding)
	if(colliding.name == "PlayerCollider"):
		var Player:Node2D = colliding.get_parent()
		if(!Player._iFramesActive):
			Player._health -= _damage
			Player._iFramesActive = true
			Player.LastHitBy = "Nail"
	if(colliding.name=="EnemyCollider"):
		var Enemy:Node2D = colliding.get_parent()
		if !("Jester" in Enemy.name):
			Enemy._health-= _damage


func _on_area_entered(area):
	collide(area)
