extends "res://scripts/Enemy/BaseEnemy.gd"

@export var MAX_HEALTH:float = 1
@export var MOVE_SPEED:float = 150
@export var PHYSICAL_ATTACK_POWER:float = 3

@export var THROW_FREQUENCY:float = 2.0
@export var BOMB_DAMAGE:float = 3
@export var THROW_DISTANCE:float = 64.0
@export var CHANGE_DIRECTION_TIMING:float = 4

@export var EXPLOSION_RADIUS_MULTIPLIER:float = 5
@export var CAN_DAMAGE_ENEMIES:bool = false
@export var CAN_DAMAGE_SELF:bool = false
@export var AIR_TIME:float = 0.8
@export var MAX_CURVE_HEIGHT:float = 20
@export var FUSE_TIME:float = 3
@export var EXPLOSION_LIFETIME:float = 1.17

@export var MOVEMENTBOUNCE_STRENGTH = 0.5
@export var MOVEMENTBOUNCE_ANGLE = 10
@export var MOVEMENTBOUNCE_MAX_HEIGHT = 1.5
@export var MOVEMENTBOUNCE_BOUNCE_Y_AXIS = 0.2

var Grenade = preload("res://elements/Bullets/Grenade.tscn")
var _grenadeID = 0

var _attackTimer:float = 0
var _attackAnimationTimer : float = 0
var _isAttacking : bool = false
var _moveDirection:Vector2
var _changeDirectionTimer:float = 0
var velocity



var _RNG = RandomNumberGenerator.new()

func start(_Player):
	super.Start(_Player,MAX_HEALTH)
	_moveSpeed = MOVE_SPEED
	_movementBounceStrength = MOVEMENTBOUNCE_STRENGTH
	_movementBounceAngle = MOVEMENTBOUNCE_ANGLE
	_movementBounceMaxHeight = MOVEMENTBOUNCE_MAX_HEIGHT
	_movementBounceBounceYAxis = MOVEMENTBOUNCE_BOUNCE_Y_AXIS
	
	var startAngle = _RNG.randf() * 2 * PI	#Get move direction
	_moveDirection = Vector2(cos(startAngle),sin(startAngle))
	
func _process(delta):
	Attack(delta)
	Animate()
	if _isAttacking:
		_attackAnimationTimer += delta
	else:
		Move(delta)
	if _health <= 0:
		OnDeath()
		
func CreateGrenade():
	var throwAngle:float = _RNG.randf() * 2 * PI	#Get throw direction
	var throwDirection:Vector2 = Vector2(cos(throwAngle),sin(throwAngle))
	var grenadeI:Node2D = Grenade.instantiate()
	grenadeI._damage = BOMB_DAMAGE
	grenadeI._explosionRadiusMultiplier = EXPLOSION_RADIUS_MULTIPLIER
	grenadeI._canDamageEnemies = CAN_DAMAGE_ENEMIES
	grenadeI._canDamageSelf = CAN_DAMAGE_SELF
	grenadeI._airTime = AIR_TIME
	grenadeI._maxCurveHeight = MAX_CURVE_HEIGHT
	grenadeI._fuseTime = FUSE_TIME
	grenadeI._explosionLifeTime = EXPLOSION_LIFETIME
	grenadeI.Throw(get_global_position(),get_global_position() + throwDirection * THROW_DISTANCE)
	get_node("../../BulletObject").add_child(grenadeI)
	_isAttacking = true
	_grenadeID += 1
	
	
func Move(delta):
	_changeDirectionTimer += delta
	if(_changeDirectionTimer > CHANGE_DIRECTION_TIMING):
		_changeDirectionTimer = 0
		var startAngle = _RNG.randf() * 2 * PI #Get move direction
		var cosAngle = cos(startAngle)
		var sinAngle = sin(startAngle)
		_moveDirection = Vector2(cosAngle*_moveDirection.x-sinAngle*_moveDirection.y,sinAngle*_moveDirection.x+cosAngle*_moveDirection.y) #Rotate move direction
	velocity = _moveDirection * _moveSpeed
	global_position += velocity * delta
	
func Attack(delta):
	_attackTimer += delta
	if(_attackTimer > THROW_FREQUENCY):
		_attackTimer = 0
		CreateGrenade()	

func Animate():
	var animation = get_child(0) as AnimatedSprite2D
	if(_isAttacking and _attackAnimationTimer > 0.2): #Stop The Attack Animation
		_isAttacking = false
		_attackAnimationTimer = 0
	elif _isAttacking :
		animation.play("Attack",0,false)
	else:
		animation.frame = EnemySpin(_moveDirection) 
		if EnemySpin(_moveDirection) in _leftDirection:
			animation.flip_h = true
		else:
			animation.flip_h = false	
		animation.play("Idle",0,false)
		Bounce()


func _on_enemy_collider_area_exited(area):
	if "Stage" in area.name:
		_moveDirection = - _moveDirection 
