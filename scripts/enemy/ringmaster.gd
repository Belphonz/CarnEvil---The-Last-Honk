extends "res://scripts/Enemy/BaseEnemy.gd"


@export var MAX_HEALTH:float = 1
@export var MOVE_SPEED:float = 90
var attacking:bool = false
var stunned:bool = false
var willAttack:bool = false

@export var PHYSICAL_DAMAGE:float = 3

var downtimeTimer:float = 0
var attackTimer:float = 0
var stunTimer:float = 0

var downtimeVal:float = 5.0
var attackLimit:float = 2.5
var stunLimit:float = 1.5

var _enemyID:float

func _process(delta):
	super._process(delta)
	if _health <= 0:
		OnDeath()

	
func start(player, enemyID):
	super.Start(player,MAX_HEALTH)
	_moveSpeed = MOVE_SPEED
	_enemyID = enemyID
	
func attack(delta):
	var spinColl = get_child(1) as CollisionPolygon2D
	var bodyColl = get_child(3) as CollisionShape2D
	var bodyColldelta = get_child(5).get_child(0) as CollisionShape2D
	if attacking == false:
		spinColl.disabled = true
		bodyColl.disabled = false
		bodyColldelta.disabled = false
		downtimeTimer+=delta
		name = "Enemy Ringmaster" + str(_enemyID) 
	if downtimeTimer >= downtimeVal && willAttack:
		attacking = true
		spinColl.disabled = false
		bodyColl.disabled = true
		bodyColldelta.disabled = true
		attackTimer += delta
		name = "RingmasterSpin Bouncy" + str(_enemyID) 
		if attackTimer > attackLimit:
			stunned = true
			stunTimer = 0
			downtimeTimer = 0
			attackTimer = 0
			spinColl.disabled = true
			bodyColl.disabled = false
			bodyColldelta.disabled = false
			willAttack = false
			attacking = false
	if stunned:
		stunTimer += delta
		if stunTimer >= stunLimit:
			stunTimer = 0
			downtimeTimer = 0
			stunned = false
		
	

@export var BOUNCEPOWER1 = 0.7
@export var DEGREES1 = 15
@export var BOUNCEHEIGHT1 = 3
@export var BOUNCEY1 = 0.1

@export var BOUNCEPOWER2 = 1.5
@export var DEGREES2 = 15
@export var BOUNCEHEIGHT2 = 3
@export var BOUNCEY2 = 0.1

func bounce(): 
	var animation = get_child(0) as Node2D
	var sprite = get_child(4) as Node2D
	# rotates only sprite and flips if over the limit
	sprite.rotate(BOUNCEPOWER1 * (PI/180))
	if sprite.rotation_degrees >= DEGREES1 or sprite.rotation_degrees <= -DEGREES1:
		BOUNCEPOWER1 = BOUNCEPOWER1 * -1
		rotate(BOUNCEPOWER1 * (PI/180))
	sprite.move_local_y(BOUNCEY1, false)
	if sprite.position.y >= BOUNCEHEIGHT1 or sprite.position.y <= -BOUNCEHEIGHT1:
		BOUNCEY1 = BOUNCEY1 * -1
		sprite.move_local_y(BOUNCEY1, false)
	
	animation.rotate(BOUNCEPOWER2 * (PI/180))
	if animation.rotation_degrees >= DEGREES2 or sprite.rotation_degrees <= -DEGREES2:
		BOUNCEPOWER2 = BOUNCEPOWER2 * -1
		rotate(BOUNCEPOWER2 * (PI/180))
	animation.move_local_y(BOUNCEY1, false)
	if animation.position.y >= BOUNCEHEIGHT2 or sprite.position.y <= -BOUNCEHEIGHT2:
		BOUNCEY2 = BOUNCEY2 * -1
		sprite.move_local_y(BOUNCEY2, false)

func move(delta):
	var animation = get_child(0) as AnimatedSprite2D
	var sprite = get_child(4) as AnimatedSprite2D
	
	var distFromPlayer:float=(_player.get_global_position().distance_to(get_global_position()))
	
	if distFromPlayer < 100:
		willAttack = true
	
	if stunned == false:
		if attacking == false:
			_moveSpeed = 60
			sprite.visible = true
			animation.visible = false
			var facingDirection = ((_player.global_position - global_position).normalized())
			if sprite.animation == "Idle":
				sprite.frame = EnemySpin(facingDirection) 
				if EnemySpin(facingDirection) in _leftDirection:
					sprite .flip_h = true
				else:
					sprite.flip_h = false
			sprite.play("Idle",0,false)
			
		if attacking == true:
			_moveSpeed = 90
			animation.play("Spin",1,false)
			sprite.visible = false
			animation.visible = true
		velocity=_playerDirection * _moveSpeed
		move_and_slide()
		bounce()
		
	if stunned == true:
		#animation.play("Stun",0,false)
		sprite.play("Idle",0,false)
		sprite.visible = true
		animation.visible = false
		
		sprite.rotation_degrees = 0
	
	

func _on_enemy_collider_area_entered(area):
	if "PlBullet" in area.owner.name:
		_health -= 1
		var Bullet:Node2D=area.get_parent()
		Bullet.death()
