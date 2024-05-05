extends "res://scripts/Enemy/BaseEnemy.gd"

@export var MAX_HEALTH:float = 1
@export var MOVE_SPEED:float = 150
@export var PHYSICAL_ATTACK_POWER:float = 3
@export var POUNCE_SPEED_MULTIPLIER:float = 1.1
@export var ATTACK_DETECTION_RANGE:float = 120
@export var ATTACK_RANGE:float = 90

@export var BACK_TO_SIDE_SPEED_MULTIPLIER:float = 0.25
@export var LION_DISTANCE_TO_TAMER_OFFSET:Vector2 = Vector2(-50,0)

@export var MOVEMENTBOUNCE_STRENGTH = 0.5
@export var MOVEMENTBOUNCE_ANGLE = 10
@export var MOVEMENTBOUNCE_MAX_HEIGHT = 1.5
@export var MOVEMENTBOUNCE_BOUNCE_Y_AXIS = 0.2

var velocity
var LionTamer:Node2D = null
var _tamerAlive:bool = true

func SetTamer(Tamer:Node2D):
	LionTamer = Tamer

func start(player):
	super.Start(player,MAX_HEALTH)
	_moveSpeed = MOVE_SPEED
	_movementBounceStrength = MOVEMENTBOUNCE_STRENGTH
	_movementBounceAngle = MOVEMENTBOUNCE_ANGLE
	_movementBounceMaxHeight = MOVEMENTBOUNCE_MAX_HEIGHT
	_movementBounceBounceYAxis = MOVEMENTBOUNCE_BOUNCE_Y_AXIS
	
func FreeLion():
	LionTamer = null
	_tamerAlive = false

func _process(delta):
	Move(delta)
	Animate()
	if _health <= 0:
		OnDeath()
	
func Move(delta):
	var areaToReach:Vector2
	var finalMoveSpeed:float = _moveSpeed
	#For Player KnockBack
	_playerDirection =(_player.get_global_position() - get_global_position()).normalized()
	if(_tamerAlive):	#If the tamer is still alive
		var playerDist:float = _player.get_global_position().distance_to(LionTamer.get_global_position())
		if(playerDist > ATTACK_DETECTION_RANGE):	#Lion is too far away to chase player
			areaToReach = LionTamer.get_global_position() + LION_DISTANCE_TO_TAMER_OFFSET
			finalMoveSpeed *= BACK_TO_SIDE_SPEED_MULTIPLIER;
		elif(playerDist < ATTACK_DETECTION_RANGE && playerDist > ATTACK_RANGE):	#Lion can chase player, but cannot reach player
			areaToReach = get_global_position().direction_to(_player.get_global_position()) * ATTACK_RANGE + LionTamer.get_global_position()
		else:	#Lion can reach player
			areaToReach= _player.get_global_position()		
	else:	#Tamer has died
		rotation = 0
		areaToReach= _player.get_global_position()
		
	if(get_global_position().distance_to(_player.get_global_position())):	#If lion should pounce
		finalMoveSpeed *= POUNCE_SPEED_MULTIPLIER
		
	var directionToMove:Vector2 = get_global_position().direction_to(areaToReach)
	velocity = directionToMove * finalMoveSpeed
	global_position += velocity * delta

func Animate():
	var sprite = get_child(0) as Node2D
	var facingDirection = ((_player.global_position - global_position).normalized())
	if EnemySpin(facingDirection) in _leftDirection:
		(sprite as AnimatedSprite2D).flip_h = true
	else:
		(sprite as AnimatedSprite2D).flip_h = false
	if(_tamerAlive):	
		var playerDist:float=_player.get_global_position().distance_to(LionTamer.get_global_position())
		if(playerDist > ATTACK_DETECTION_RANGE):
			(sprite as AnimatedSprite2D).frame = EnemySpin(facingDirection) 
			(sprite as AnimatedSprite2D).play("Idle",0,false)
			Bounce()
		elif(playerDist < ATTACK_DETECTION_RANGE && playerDist > ATTACK_RANGE):
			rotation = 0
			(sprite as AnimatedSprite2D).frame = 1
			(sprite as AnimatedSprite2D).play("Attack",0,false)
	else:
		rotation = 0
		(sprite as AnimatedSprite2D).frame =  EnemySpin(facingDirection)  
		(sprite as AnimatedSprite2D).play("Attack",0,false)
	
func OnDeath():
	if LionTamer:
		LionTamer.FreeTamer()
	super.OnDeath()	

