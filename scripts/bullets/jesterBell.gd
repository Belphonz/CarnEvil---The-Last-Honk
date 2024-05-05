extends Node2D

var _damage : float
var _airTime:float
var _maxCurveHeight:float

var _startThrow:Vector2
var _endThrow:Vector2
var _timeInAir:float = 0

var _active:bool

func Throw(start:Vector2, location:Vector2):
	_active = true
	_startThrow = start
	global_position = start
	_endThrow = location


# Called when the node enters the scene tree for the first time.
func _ready():
	rotation = randf_range(-180,180)

func _process(delta):
	if(_active):	#Being thrown
		_timeInAir += delta	
		if(_timeInAir > _airTime):	#Landed
			_active = false
			set_global_position(_endThrow)
			return
			
		var pointInCurve:float = _timeInAir / _airTime	#How far in the curve from 0-1
		var position:Vector2 = lerp(_startThrow,_endThrow,pointInCurve)
		var yOffset:float = pointInCurve * -4.0 * _maxCurveHeight * (1.0 - pointInCurve)	#Calculate y offset to add for curve
		position.y += yOffset
		set_global_position(position)

func _on_area_entered(area):
	if(!_active):
		return
	if(area.name == "PlayerCollider"):
		var Player:Node2D = area.get_parent()
		if(!Player._iFramesActive):
			Player._health -= _damage
			Player._iFramesActive = true
			Player.LastHitBy = "Bell"
			
			var _playerDirection = (Player.get_global_position() - get_global_position()).normalized()	
			Player._inKnockBack = bool(int(true) * int(Player.BELL_DO_KNOCKBACK))
			Player.velocity = (_playerDirection * Player.BELL_KNOCKBACK_STRENGTH) * 1.5 * int(Player.BELL_DO_KNOCKBACK)
			Player._enemyKnockbackTimer = Player.BELL_KNOCKBACK_DURATION  * int(Player.BELL_DO_KNOCKBACK)
			Player._currentKnockBackFriction = Player.BELL_KNOCKBACK_FRICTION
