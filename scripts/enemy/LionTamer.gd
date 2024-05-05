extends "res://scripts/Enemy/BaseEnemy.gd"

@export var MAX_HEALTH:float = 1
@export var MOVE_SPEED:float = 40
@export var PHYSICAL_ATTACK_POWER:float = 3

@export var MOVEMENTBOUNCE_STRENGTH = 0.5
@export var MOVEMENTBOUNCE_ANGLE = 10
@export var MOVEMENTBOUNCE_MAX_HEIGHT = 1.5
@export var MOVEMENTBOUNCE_BOUNCE_Y_AXIS = 0.2


var _lionAlive : bool = true
var Lion : Node2D = null
var velocity

func Start(player,enemyID):
	super.Start(player,MAX_HEALTH)
	_moveSpeed = MOVE_SPEED
	_movementBounceStrength = MOVEMENTBOUNCE_STRENGTH
	_movementBounceAngle = MOVEMENTBOUNCE_ANGLE
	_movementBounceMaxHeight = MOVEMENTBOUNCE_MAX_HEIGHT
	_movementBounceBounceYAxis = MOVEMENTBOUNCE_BOUNCE_Y_AXIS
	AddLion(enemyID)


func AddLion(enemyID):
	Lion = preload("res://elements/Enemies/Lion.tscn").instantiate()
	Lion.set_global_position(get_global_position() - Vector2(50,0))
	Lion.start(_player)
	Lion.SetTamer(self)
	Lion.name = "Enemy Lion" + str(enemyID)
	get_parent().add_child(Lion)	#Add Lion to enemy manager

func FreeTamer():	#Lion has died, do separate things for the tamer
	Lion = null
	_lionAlive = false

func _process(delta):
	super._process(delta)
	if _health <= 0:
		OnDeath()
	
	
func Move(delta):
	velocity = _moveSpeed * _playerDirection
	Animate()

	if(!_lionAlive):
		return
	global_position += velocity * delta
	
	
func Animate():
	var sprite = get_child(0) as Node2D
	if(!_lionAlive):
		(sprite as AnimatedSprite2D).play("Sad",0,false)
		return

	Bounce()
	var facingDirection = ((_player.global_position - global_position).normalized())
	if (sprite as AnimatedSprite2D).animation == "Idle":
		(sprite as AnimatedSprite2D).frame = EnemySpin(facingDirection) 
		if EnemySpin(facingDirection) in _leftDirection:
			(sprite as AnimatedSprite2D).flip_h = true
		else:
			(sprite as AnimatedSprite2D).flip_h = false
	(sprite as AnimatedSprite2D).play("Idle",0,false)

func OnDeath():
	if Lion: 
		Lion.FreeLion()
	super.OnDeath()	

