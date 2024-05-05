extends "res://scripts/Enemy/BaseEnemy.gd"

@export var MAX_HEALTH:float = 1
@export var MOVE_SPEED:float = 40
@export var PHYSICAL_ATTACK_POWER:float = 3



@export var NAIL_DAMAGE:float = 3
@export var NAIL_THROW_DISTANCE:float = 128
@export var NAIL_AIR_TIME = 0.5
@export var NAIL_MAX_CURVE_HEIGHT = 50

@export var BELL_DAMAGE:float = 3
@export var BELL_THROW_DISTANCE:float = 180
@export var BELL_AIR_TIME = 0.8
@export var BELL_MAX_CURVE_HEIGHT = 70

@export var THROW_FREQUENCY:float = 0.8
@export_range (0,1) var NAIL_DROP_CHANCE:float = 0.15

@export var ZIGZAG_ANGLE:float = 30  	#1/6PI radians (30 degrees)
@export var ZIGZAG_FREQUENCY:float = 1	#How often it swaps between zig zag direction

var _nailHazard = preload("res://elements/Hazards/NailHazard.tscn")
var _bellBullet = preload("res://elements/Bullets/JesterBell.tscn")

var _zigLeft:bool = false	#Jester moves in a zig zag, are they zigging or zagging
var _zigzagTimer:float = 0.5	#Track how often zigLeft should swap

var _attackTimer:float = 0
var velocity

var _RNG = RandomNumberGenerator.new()

func start(_Player):
	super.Start(_Player,MAX_HEALTH)
	_moveSpeed = MOVE_SPEED
	ZIGZAG_ANGLE = deg_to_rad(ZIGZAG_ANGLE)

func _process(delta):
	super._process(delta)
	if(_health <= 0):
		OnDeath()

func Attack(delta):
	_attackTimer += delta
	if(_attackTimer > THROW_FREQUENCY):
		_attackTimer = 0
		var throwAngle:float = _RNG.randf()*2*PI
		var throwDirection:Vector2 = Vector2(cos(throwAngle),sin(throwAngle))
		if(_RNG.randf() < 0.15):
			#Throw trap
			var NailHazard = _nailHazard.instantiate()
			NailHazard._damage = NAIL_DAMAGE
			NailHazard._airTime = NAIL_AIR_TIME
			NailHazard._maxCurveHeight = NAIL_MAX_CURVE_HEIGHT
			NailHazard.Throw(get_global_position(),get_global_position() + throwDirection * NAIL_THROW_DISTANCE)
			get_node("../../SpikeNode").add_child(NailHazard)
		else:	
			#Throw bell
			var Bell = _bellBullet.instantiate()
			Bell._damage = BELL_DAMAGE
			Bell._airTime = BELL_AIR_TIME
			Bell._maxCurveHeight = BELL_MAX_CURVE_HEIGHT
			Bell.Throw(get_global_position(),get_global_position() + throwDirection * BELL_THROW_DISTANCE)
			get_node("../../BulletObject").add_child(Bell)
	
	
func Move(delta):
	var angle:float = ZIGZAG_ANGLE * (-1 if _zigLeft else 1)	
	var cosAngle:float=cos(angle)
	var sinAngle:float=sin(angle)
	var moveDirection = Vector2(cosAngle*_playerDirection.x-sinAngle*_playerDirection.y,sinAngle*_playerDirection.x+cosAngle*_playerDirection.y)
	Animate(moveDirection)
	velocity = moveDirection * _moveSpeed
	global_position += velocity * delta
		
	_zigzagTimer += delta	
	if(_zigzagTimer > ZIGZAG_FREQUENCY):
		_zigLeft =! _zigLeft
		_zigzagTimer=0
	

func Animate(moveDirection):
	var sprite = get_child(0) as Node2D
	if (sprite as AnimatedSprite2D).animation == "Idle":
		(sprite as AnimatedSprite2D).frame = EnemySpin(moveDirection) 
		if EnemySpin(moveDirection) in _leftDirection:
			(sprite as AnimatedSprite2D).flip_h = false
		else:
			(sprite as AnimatedSprite2D).flip_h = true
