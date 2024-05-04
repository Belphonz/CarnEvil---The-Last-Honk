extends Node2D

@export var MAX_HEALTH:float = 6
@export var MOVE_SPEED:float = 300.0
@export var BULLET_BOUNCE_COUNT:int = 3
@export var BULLET_DAMAGE:float = 3
@export var BULLET_SPEED:float = 400.0
@export var BULLET_TRAIL_FREQUENCY:float = 0.03
@export var FIRE_RATE:float = 0.4

var _currentFireRate = 0.0
var _moveDirection
var velocity : Vector2
var _lastSavedMoveDirection
var _bulletID = 0

@export var MOVEMENTBOUNCE_STRENGTH = 1.5
@export var MOVEMENTBOUNCE_ANGLE = 15
@export var MOVEMENTBOUNCE_MAX_HEIGHT = 1.5
@export var MOVEMENTBOUNCE_BOUNCE_Y_AXIS = 0.4

@export var IFRAME_DURATION:float = 0.25
var _iFramesActive:bool = false
var _iFramesTimer:float = 0

var _scoreBasedOnTime = 0
var _score : float= 0
var _health:float
var _alive = true
var LastHitBy : String


@export var DASH_SPEED_MULTIPLIER : float = 4
@export var DASH_DURATION : float = 0.3
var _currentDashduration : float = 0
var _isDashing : bool

var _usingController:bool = false
var isLeft : bool = false
var _rotationFrame : int
var _bouncingBackIntoStage : bool
var _bouncingBackIntoStageTimer : float

var HealthBar:Node2D

@export var STAGE_BOUNCE_STRENGTH = 15
@export var STAGE_BOUNCE_DURATION = 0.25
@export var STAGE_BOUNCE_FRICTION = 0.7
@export var STAGE_BOUNCES_UNTIL_DEATH = 2

@export var ENEMY_DO_PHSYICAL_KNOCKBACK : bool = true
@export var PHYSICAL_KNOCKBACK_STRENGTH = 1000
@export var PHYSICAL_KNOCKBACK_DURATION = IFRAME_DURATION / 2
@export var PHSYICAL_KNOCKBACK_FRICTION = 0.7

@export var BULLET_DO_KNOCKBACK : bool = true
@export var BULLET_KNOCKBACK_STRENGTH = 4
@export var BULLET_KNOCKBACK_DURATION = IFRAME_DURATION / 2
@export var BULLET_KNOCKBACK_FRICTION = 0.7

var _inKnockBack : bool = false
var _enemyKnockbackTimer : float
var _currentKnockBackFriction


func _ready():
	Highscore.Player = self
	_health = MAX_HEALTH
	HealthBar = get_node("HealthBar")

func Dash(delta):
	if Input.is_action_just_pressed("dash") and not _isDashing:
		_isDashing = true
	if _isDashing:
		_currentDashduration += delta
	if _currentDashduration > DASH_DURATION: 
		_currentDashduration = 0
		_isDashing = false
		
func Controller(delta):
	if not _isDashing and not _bouncingBackIntoStage:
		_moveDirection = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
		_lastSavedMoveDirection = _moveDirection
	Dash(delta)
	if _isDashing and not _bouncingBackIntoStage:
		velocity = _lastSavedMoveDirection * MOVE_SPEED * DASH_SPEED_MULTIPLIER
	elif not _bouncingBackIntoStage and not _inKnockBack:
		velocity = _moveDirection * MOVE_SPEED
	if _bouncingBackIntoStage:
		_bouncingBackIntoStageTimer -= delta
		velocity *= STAGE_BOUNCE_FRICTION
		if _bouncingBackIntoStageTimer <= 0:
			_bouncingBackIntoStage = false
			
	if _inKnockBack:
		_enemyKnockbackTimer -= delta
		velocity *= _currentKnockBackFriction
		if _enemyKnockbackTimer <= 0:
			_inKnockBack = false
			
	VelocityDeath()		
	Animate(delta)	
	global_position += velocity * delta

func VelocityDeath():
	var VelocityDeathSpeedX = _lastSavedMoveDirection.abs().x * MOVE_SPEED * DASH_SPEED_MULTIPLIER * STAGE_BOUNCE_STRENGTH * STAGE_BOUNCES_UNTIL_DEATH
	var VelocityDeathSpeedY = _lastSavedMoveDirection.abs().y * MOVE_SPEED * DASH_SPEED_MULTIPLIER * STAGE_BOUNCE_STRENGTH * STAGE_BOUNCES_UNTIL_DEATH
	if (velocity.x != 0 or velocity.y != 0) && _bouncingBackIntoStage:
		if (velocity.abs().x > VelocityDeathSpeedX) and velocity.y == 0:
			_health = 0
			LastHitBy = "HighSpeed"
		if (velocity.abs().y > VelocityDeathSpeedY) and velocity.x == 0:
			_health = 0
			LastHitBy = "HighSpeed"
		if (velocity.abs().x > VelocityDeathSpeedX) and velocity.y != 0:
			if (velocity.abs().y > VelocityDeathSpeedY) and velocity.x != 0:
				_health = 0
				LastHitBy = "HighSpeed"
				
func Animate(delta):
	const leftDirection = [0,1,7]
	var animation = get_child(0) as AnimatedSprite2D
	animation.frame = _rotationFrame
	
	if _moveDirection:
		Bounce(delta)
		_rotationFrame = roundi(((_moveDirection.angle() + PI) * 4)/ PI);
		if _rotationFrame > 7:
			_rotationFrame -= 8
		if _rotationFrame in leftDirection:
			isLeft = true
		else:
			isLeft = false
	else:
		animation.rotation = 0
	animation.flip_h = isLeft
	animation.play("Default",0,false)
	
	
func Shoot(delta):
	var shootPoint = get_child(1) as Node2D
	var audioNoShoot = get_child(3) as AudioStreamPlayer2D
	
	_currentFireRate += delta
	
	var facingdirection:Vector2	#Get direction to fire
	if(Input.get_connected_joypads().size() > 0):	#Using controller
		facingdirection=Vector2(Input.get_joy_axis(0,JOY_AXIS_RIGHT_X),Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y))
		if(facingdirection.dot(facingdirection) < 0.1):	#If aiming no-where
			facingdirection=Vector2(1,0)
		else:
			facingdirection=facingdirection.normalized()	#Normalize facing direction so it's not affecting bullet velocity	
	else:					#Using mouse
		facingdirection = (get_global_mouse_position() - global_position).normalized()
		
	shootPoint.rotation = facingdirection.angle()
	if Input.is_action_just_pressed("shoot") and _currentFireRate < FIRE_RATE:
		audioNoShoot.play()
	if Input.is_action_pressed("shoot") and _currentFireRate > FIRE_RATE:
		Create_Bullet(delta,facingdirection,shootPoint)
		
func Create_Bullet(delta,facingdirection,shootPoint):
	var audioShoot = get_child(2) as AudioStreamPlayer2D
	audioShoot.play()
	var bulletInstance:Area2D = preload("res://elements/Bullets/PlayerBullet.tscn").instantiate()

	bulletInstance._damage = BULLET_DAMAGE
	bulletInstance._maxBounceCount = BULLET_BOUNCE_COUNT
	bulletInstance._confettiFrequency = BULLET_TRAIL_FREQUENCY
	bulletInstance.velocity = facingdirection * BULLET_SPEED
	
	_bulletID += 1
	bulletInstance.name = "PlBullet " + str(_bulletID)
	bulletInstance.global_position = shootPoint.global_position + (facingdirection * 35)
	get_parent().add_child(bulletInstance)
	_currentFireRate = 0
	
	
func Bounce(delta): 
	var sprite = get_node("PlayerSprite") as Node2D
	# rotates only sprite and flips if over the limit
	sprite.rotate(MOVEMENTBOUNCE_STRENGTH * (PI/180))
	if sprite.rotation_degrees >= MOVEMENTBOUNCE_ANGLE or sprite.rotation_degrees <= -MOVEMENTBOUNCE_ANGLE:
		MOVEMENTBOUNCE_STRENGTH = MOVEMENTBOUNCE_STRENGTH * -1
		rotate(MOVEMENTBOUNCE_STRENGTH * (PI/180))
	sprite.move_local_y(MOVEMENTBOUNCE_BOUNCE_Y_AXIS, false)
	if sprite.position.y >= MOVEMENTBOUNCE_MAX_HEIGHT or sprite.position.y <= -MOVEMENTBOUNCE_MAX_HEIGHT:
		MOVEMENTBOUNCE_BOUNCE_Y_AXIS = MOVEMENTBOUNCE_BOUNCE_Y_AXIS * -1
		sprite.move_local_y(MOVEMENTBOUNCE_BOUNCE_Y_AXIS, false)
	
func Death():
	_score = floor(_scoreBasedOnTime) * 10
	Highscore.runscore = _score
	_alive = false
	ProcessDeath()
	var DeathScreen : Node2D = preload("res://scenes/DeathScreen.tscn").instantiate()
	(DeathScreen.get_node("Deathmessasage") as Label).text = LastHitBy
	get_tree().root.add_child(DeathScreen)
	get_tree().root.remove_child(get_tree().root.get_child(1))
	
func ProcessDeath():
	if "PlBullet" in LastHitBy :
		LastHitBy = "YOURSELF, IDIOT !"
	elif "EnBullet" in LastHitBy :
		LastHitBy = "THE AK CLOWN's NONSTOP SPRAY!"
	elif "ClownAK47" in LastHitBy :
		LastHitBy = "THE AK CLOWN's BELLYFLOP!"
	elif "Ringmaster" in LastHitBy :
		LastHitBy = "THE RINGMASTER's BELLYFLOP!"
	elif "HighSpeed" in LastHitBy :
		LastHitBy = "BOUNCING AROUND WAY TOO FASTTTT!"
	
func _physics_process(delta):
	Controller(delta)
	HealthBar.setHealth(_health,MAX_HEALTH)
	Shoot(delta)
	_scoreBasedOnTime += delta
	
	if(_iFramesActive):
		_iFramesTimer+=delta
		if(_iFramesTimer > IFRAME_DURATION):
			_iFramesTimer = 0
			_iFramesActive = false	
	if _health <= 0:
		Death()
	


func _on_player_collider_area_entered(area):
	if "Bullet" in area.name:
		if !_iFramesActive:
			LastHitBy = area.name
			_iFramesActive = true
			_health -= area._damage
		area.Destruction()
		
		_inKnockBack = true
		velocity = (area.velocity * BULLET_KNOCKBACK_STRENGTH) * int(BULLET_DO_KNOCKBACK)
		_enemyKnockbackTimer = BULLET_KNOCKBACK_DURATION  * int(BULLET_DO_KNOCKBACK)
		_currentKnockBackFriction = BULLET_KNOCKBACK_FRICTION
	elif  !_iFramesActive && "Enemy" in area.owner.name:
		LastHitBy = area.owner.name
		_iFramesActive = true
		var Enemy:Node2D = area.get_parent()
		_health -= Enemy.PHYSICAL_ATTACK_POWER
		
		_inKnockBack = true
		velocity = (Enemy._playerDirection * PHYSICAL_KNOCKBACK_STRENGTH) * int(ENEMY_DO_PHSYICAL_KNOCKBACK)
		_enemyKnockbackTimer = PHYSICAL_KNOCKBACK_DURATION  * int(ENEMY_DO_PHSYICAL_KNOCKBACK)
		_currentKnockBackFriction = PHSYICAL_KNOCKBACK_FRICTION
	
func _on_player_collider_area_exited(area):
	if "Stage" in area.name:
		_bouncingBackIntoStage = true
		velocity = - velocity * STAGE_BOUNCE_STRENGTH
		_bouncingBackIntoStageTimer = STAGE_BOUNCE_DURATION
		
